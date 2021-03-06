## Copyright (C) 2017  Jon Meek
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
nbReadAndLoadNetwork <- function(file, skip_lines = 0) {

    lines <- readr::read_lines(file, skip = skip_lines) # Skip non-commented / non-indented header line(s) if needed

    t <- stringr::str_split_fixed(lines, '\\s+', 2)                   # Split on first whitespace

    nets <- as.data.frame(t, stringsAsFactors = FALSE)
    names(nets) <- c('NetBlock', 'Description')
    nets <- nets %>% dplyr::filter(!stringr::str_detect(NetBlock, '#') & stringr::str_length(NetBlock) > 0) # Drop comments, empty & indented lines

    t <- stringr::str_split_fixed(nets$NetBlock, '/', 2)              # Breakout base IP address and number of bits in mask
    nets$Base <- t[,1]
    nets$Bits <- as.integer(t[,2])

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
nbLoadNetwork <- function(nets) {

    nets <- nets %>% dplyr::filter(!stringr::str_detect(NetBlock, '#') & stringr::str_length(NetBlock) > 0) # Drop comments, empty & indented lines

    t <- stringr::str_split_fixed(nets$NetBlock, '/', 2)              # Breakout base IP address and number of bits in mask
    nets$Base <- t[,1]
    nets$Bits <- as.integer(t[,2])

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
nbReadNetwork <- function(file, skip_lines = 0) { # New, Feb 2020

    lines <- readr::read_lines(file, skip = skip_lines) # Skip non-commented / non-indented header line(s) if needed

    t <- stringr::str_split_fixed(lines, '\\s+', 2)     # Split on first whitespace

    nets <- as.data.frame(t, stringsAsFactors = FALSE)
    names(nets) <- c('NetBlock', 'Description')
    nets <- nets %>% dplyr::filter(!stringr::str_detect(NetBlock, '#') & stringr::str_length(NetBlock) > 0) # Drop comments, empty & indented lines

    t <-  stringr::str_split_fixed(nets$NetBlock, '/', 2) # Breakout base IP address and number of bits in mask
    nets$Base <- t[,1]
    nets$Bits <- as.integer(t[,2])
    return(nets)
}

