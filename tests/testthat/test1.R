library(netblockr)
library(dplyr)
library(readr)
library(stringr)
library(testthat)



## A sample network description file included in the package
organization_net_file <- system.file("extdata", "org-net.txt", package = "netblockr")

## Build the network table in C++ space and get a pointer to the table
nbPtrOrg <- nbReadAndLoadNetwork(organization_net_file)


testAddrs <- c('10.10.10.1', '10.20.10.18', '10.16.3.28', '10.16.8.50', '10.16.9.50',
               '10.16.18.18', '10.16.18.35', '10.48.17.32', '10.50.17.32', '192.168.55.47')

lookup_result <- nbLookupIPaddrs(nbPtrOrg, testAddrs)


test_that("IP address can be looked up", {

    expect_equal(lookup_result[1, 1], '10.10.10.1')
    expect_equal(lookup_result[1, 2], 'NotFound')


    expect_equal(lookup_result[3, 1], '10.16.3.28')
    expect_equal(lookup_result[3, 2], '10.16.0.0/22')

})

rm(nbPtrOrg)

