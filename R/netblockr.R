## Copyright (C) 2023  Jon Meek
##
## This file is part of netblockr.
##
## netblockr is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 2 of the License, or
## (at your option) any later version.
##
## netblockr is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with netblockr.  If not, see <http://www.gnu.org/licenses/>.

#' Read a file with netblocks in CIDR format and a free form description
#' of the netblock, then build a table of the network with an index
#' for fast lookup of IPv4 addresses with nbLookupIPaddrs
#'
#' @param file Path to the input file
#' @param skip_lines Optional number of lines to skip, use if there is an uncommented header
#' @return An external pointer to the table data structure in C++ space
#'
nbReadAndLoadNetwork <- function(file, skip_lines = 0, quiet = FALSE) { # Updated to add /32 to bare IP addresses
    ## From O'Reilly Regular Expressions Cookbook by Jan Goyvaerts and Steven Levithan
    ipv4_match <- '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'

    lines <- readr::read_lines(file, skip = skip_lines) # Skip non-commented / non-indented header line(s) if needed
    t <- stringr::str_split_fixed(lines, '\\s+', 2)     # Split on first whitespace

    nets <- as.data.frame(t, stringsAsFactors = FALSE)
    names(nets) <- c('NetBlock', 'Description')
    nets <- nets %>% dplyr::filter(!stringr::str_detect(NetBlock, '#') & stringr::str_length(NetBlock) > 0) # Drop comments, empty & indented lines

    ## Validate the network data, avoid a spectacular crash due to missing or bad netmask
    nets <- nets %>% dplyr::mutate(Base = stringr::str_extract(NetBlock, ipv4_match),
                                   Bits = as.integer(stringr::str_extract(NetBlock, '(\\d+)$')))

    nets <- nets %>% dplyr::mutate(Bits = ifelse(stringr::str_detect(NetBlock, '/'),  Bits, 32)) # No /, assume /32
    nets <- nets %>% dplyr::mutate(Bits = ifelse(Bits <  0, NA, Bits))                           # Base ifelse coerces types
    nets <- nets %>% dplyr::mutate(Bits = ifelse(Bits > 32, NA, Bits))                           # Can't use if_else with NA
##    nets <- nets %>% dplyr::mutate(Bits = ifelse(stringr::str_detect(NetBlock, '/'),  Bits, NA)) # No / is also missing mask

    bad_data <- nets %>% dplyr::filter(  is.na(Base) | (is.na(Bits)))
    nets     <- nets %>% dplyr::filter(!(is.na(Base) | (is.na(Bits))))

    if (!quiet & nrow(bad_data)) {        # Report IPv4 syntax errors, should go to STDERR for CLI?
        cat('IPv4 CIDR Syntax Errors\n')
        print(bad_data)
    }

    nb_ptr <- nbBuildNetblockTable(nets$NetBlock, nets$Base, nets$Bits, nets$Description) # Call C++ function to build netblock table
    nbSetMaskOrder(nb_ptr, sort(unique(nets$Bits), decreasing = TRUE))                    # Add mask search order - Required
    return(nb_ptr)
}

#' Build a network description table from a data frame.
#'
#' @param nets_df A data frame with columns named 'NetBlock' & 'Description'
#' @return An external pointer to the table data structure in C++ space
#' The input can contain empty rows. A '#' in the NetBlock field will cause that row to be ignored.
#'
nbLoadNetwork <- function(nets, quiet = FALSE) {
    ## From O'Reilly Regular Expressions Cookbook by Jan Goyvaerts and Steven Levithan
    ipv4_match <- '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'

    nets <- nets %>% dplyr::filter(!stringr::str_detect(NetBlock, '#') & stringr::str_length(NetBlock) > 0) # Drop comments, empty & indented lines

    ## Validate the network data, avoid a spectacular crash due to missing netmask
    nets <- nets %>% dplyr::mutate(Base = stringr::str_extract(NetBlock, ipv4_match),
                                   Bits = as.integer(stringr::str_extract(NetBlock, '(\\d+)$')))

    nets <- nets %>% dplyr::mutate(Bits = ifelse(Bits <  0, NA, Bits))                           # Base ifelse coerces types
    nets <- nets %>% dplyr::mutate(Bits = ifelse(Bits > 32, NA, Bits))                           # Can't use if_else with NA
    nets <- nets %>% dplyr::mutate(Bits = ifelse(stringr::str_detect(NetBlock, '/'),  Bits, NA)) # No / is also missing mask

    bad_data <- nets %>% dplyr::filter(  is.na(Base) | (is.na(Bits)))
    nets     <- nets %>% dplyr::filter(!(is.na(Base) | (is.na(Bits))))

    if (!quiet & nrow(bad_data)) {        # Report IPv4 syntax errors
        cat('IPv4 CIDR Syntax Errors\n')
        print(bad_data)
    }

    nb_ptr <- nbBuildNetblockTable(nets$NetBlock, nets$Base, nets$Bits, nets$Description) # Call C++ function to build netblock table
    nbSetMaskOrder(nb_ptr, sort(unique(nets$Bits), decreasing = TRUE))                    # Add mask search order - Required
    return(nb_ptr)
}

#' Build a data frame from a network description file for later loading with nbLoadNetwork()
#' Used when multiple network description files need to be combined
#' Note that there is currently no check for duplicate NetBlocks, that can be done externally
#'
#' #' @param file Path to the input file
#' @param skip_lines Optional number of lines to skip, use if there is an uncommented header
#' @return A data frame appropriate for nbLoadNetwork()
#' The input can contain empty rows. A '#' in the NetBlock field will cause that row to be ignored.
#'
nbReadNetwork <- function(file, skip_lines = 0, quiet = FALSE) { # New, Feb 2020
    ## From O'Reilly Regular Expressions Cookbook by Jan Goyvaerts and Steven Levithan
    ipv4_match <- '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'

    lines <- readr::read_lines(file, skip = skip_lines) # Skip non-commented / non-indented header line(s) if needed

    t <- stringr::str_split_fixed(lines, '\\s+', 2)     # Split on first whitespace

    nets <- as.data.frame(t, stringsAsFactors = FALSE)
    names(nets) <- c('NetBlock', 'Description')
    nets <- nets %>% dplyr::filter(!stringr::str_detect(NetBlock, '#') & stringr::str_length(NetBlock) > 0) # Drop comments, empty & indented lines

    ## Validate the network data, avoid a spectacular crash due to missing netmask
    nets <- nets %>% dplyr::mutate(Base = stringr::str_extract(NetBlock, ipv4_match),
                                   Bits = as.integer(stringr::str_extract(NetBlock, '(\\d+)$')))

    nets <- nets %>% dplyr::mutate(Bits = ifelse(Bits <  0, NA, Bits))                           # Base ifelse coerces types
    nets <- nets %>% dplyr::mutate(Bits = ifelse(Bits > 32, NA, Bits))                           # Can't use if_else with NA
    nets <- nets %>% dplyr::mutate(Bits = ifelse(stringr::str_detect(NetBlock, '/'),  Bits, NA)) # No / is also missing mask

    bad_data <- nets %>% dplyr::filter(  is.na(Base) | (is.na(Bits)))
    nets     <- nets %>% dplyr::filter(!(is.na(Base) | (is.na(Bits))))

    if (!quiet & nrow(bad_data)) {        # Report IPv4 syntax errors
        cat('IPv4 CIDR Syntax Errors\n')
        print(bad_data)
    }
    return(nets)
}

#' Validate a network description file
#'
#' Note that there is currently no check for duplicate NetBlocks, that can be done externally
#' Avoid a spectacular crash due to missing netmask
#' @param file Path to the input file
#' @param skip_lines Optional number of lines to skip, use if there is an uncommented header
#' @quiet if TRUE do not report data issues, just silently drop bad data
#' @return A list of data frames, validatedNets and bad_data
#' The input can contain empty rows. A '#' in the NetBlock field will cause that row to be ignored.
#'
nbReadAndValidate <- function(file, skip_lines = 0, quiet = FALSE) { # New, Nov 2022

    ## From O'Reilly Regular Expressions Cookbook by Jan Goyvaerts and Steven Levithan
    ipv4_match <- '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
    lines <- readr::read_lines(file, skip = skip_lines)               # Skip non-commented / non-indented header line(s) if needed

    t <- stringr::str_split_fixed(lines, '\\s+', 2)                   # Split on first whitespace
    nets <- as.data.frame(t, stringsAsFactors = FALSE)
    names(nets) <- c('NetBlock', 'Description')
    nets <- nets %>% dplyr::filter(!stringr::str_detect(NetBlock, '#') & stringr::str_length(NetBlock) > 0) # Drop comments, empty & indented lines

    ## Validate the network data, avoid a spectacular crash due to missing netmask
    nets <- nets %>% dplyr::mutate(Base = stringr::str_extract(NetBlock, ipv4_match),
                                   Bits = as.integer(stringr::str_extract(NetBlock, '(\\d+)$')))

    nets <- nets %>% dplyr::mutate(Bits = ifelse(Bits <  0, NA, Bits))                           # Base ifelse coerces types
    nets <- nets %>% dplyr::mutate(Bits = ifelse(Bits > 32, NA, Bits))                           # Can't use if_else with NA
    nets <- nets %>% dplyr::mutate(Bits = ifelse(stringr::str_detect(NetBlock, '/'),  Bits, NA)) # No / is also missing mask

    bad_data <- nets %>% dplyr::filter(  is.na(Base) | (is.na(Bits)))
    nets     <- nets %>% dplyr::filter(!(is.na(Base) | (is.na(Bits))))

    if (!quiet & nrow(bad_data)) {        # Report IPv4 syntax errors
        cat('IPv4 CIDR Syntax Errors\n')
        print(bad_data)
    }
    ## attr(nets, 'problems') <- bad_data # Want something like the readr problems(). Must have a problems attribute that is an external pointer.
    ## return(nets)

    return(list(validatedNets = nets, badData =  bad_data))
}
