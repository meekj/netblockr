% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/netblockr.R
\name{nbReadNetwork}
\alias{nbReadNetwork}
\title{Build a data frame from a network description file for later loading with nbLoadNetwork()
Used when multiple network description files need to be combined
Note that there is currently no check for duplicate NetBlocks, that can be done externally}
\usage{
nbReadNetwork(file, skip_lines = 0, quiet = FALSE)
}
\arguments{
\item{skip_lines}{Optional number of lines to skip, use if there is an uncommented header}
}
\value{
A data frame appropriate for nbLoadNetwork()
The input can contain empty rows. A '#' in the NetBlock field will cause that row to be ignored.
}
\description{
#' @param file Path to the input file
}
