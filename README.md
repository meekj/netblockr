# netblockr

Builds tables of IPv4 networks with base address, netmask, a
description string, and a unique index. The table build
function returns a pointer to R that is used to reference
that table. A vector of IPv4 addresses can then be looked up
and returned in a data frame.

This package was inspired by the Perl Net::Netmask module which provides many more functions for dealing with IPv4 addresses.


To install: 

    library(devtools)
    devtools::install_github("meekj/netblockr")

Test:

	library(stringr) # For str_split_fixed

	nb_txt_file1 <- 'data/google-dns-ipv4.txt'

	nb_raw_nets1 <- read.table(nb_txt_file1, header = TRUE, stringsAsFactors = FALSE)

	str(nb_raw_nets1)

	'data.frame':	68 obs. of  2 variables:
	$ NetBlock   : chr  "74.125.18.0/26" "74.125.18.64/26" "74.125.18.128/26" "74.125.18.192/26" ...
	$ Description: chr  "iad" "iad" "syd" "lhr" ...


	t <- str_split_fixed(nb_raw_nets1$NetBlock, '/', 2)
	nets1 <- nb_raw_nets1
	nets1$Base <- t[,1]
	nets1$Bits <- as.integer(t[,2])

	str(nets1)

	'data.frame':	68 obs. of  4 variables:
	$ NetBlock   : chr  "74.125.18.0/26" "74.125.18.64/26" "74.125.18.128/26" "74.125.18.192/26" ...
	$ Description: chr  "iad" "iad" "syd" "lhr" ...
	$ Base       : chr  "74.125.18.0" "74.125.18.64" "74.125.18.128" "74.125.18.192" ...
	$ Bits       : int  26 26 26 26 24 24 24 24 24 24 ...


	## Build the netblock data table

	nbPtr1 <- nbBuildNetblockTable(nets1$NetBlock, nets1$Base, nets1$Bits, nets1$Description)
	nbSetMaskOrder(nbPtr1, sort(unique(nets1$Bits), decreasing = TRUE)) # Sort order to match smallest netblock

	typeof(nbPtr1) # Verify that we got a pointer from nbBuildNetblockTable

	## Test address lookup
	testIPs1 <- c('74.125.18.1', '74.125.18.21', '74.125.41.2', '172.217.33.193', '173.194.100.4', '192.168.10.48')

	lookup1 <- nbLookupIPaddrs(nbPtr1, testIPs1)
	lookup1

	IPaddr                    NetBlock Description
	1    74.125.18.1    74.125.18.0/26         iad
	2   74.125.18.21    74.125.18.0/26         iad
	3    74.125.41.2    74.125.41.0/24         tpe
	4 172.217.33.193 172.217.33.192/26         fra
	5  173.194.100.4  173.194.100.0/24         mrn
	6  192.168.10.48          NotFound    NotFound



	## Bad data in lookup
	testIPs2 <- c('74.125.18.1', '74.125.18.21', '74.125.41.2', '172.217.33.193', '173.194.100.4', '192.168.10.48', 'aa.bb.JJ.dd.ee')

	lookup2 <- nbLookupIPaddrs(nbPtr1, testIPs2)
	Warning message:
	In .Primitive(".Call")(<pointer: 0x7f51d52f3940>, nbt, IPaddrStrings) :
	nbLookupIPaddrs Bad format IP address: aa.bb.JJ.dd.ee

	lookup2

	IPaddr                    NetBlock Description
	1    74.125.18.1    74.125.18.0/26         iad
	2   74.125.18.21    74.125.18.0/26         iad
	3    74.125.41.2    74.125.41.0/24         tpe
	4 172.217.33.193 172.217.33.192/26         fra
	5  173.194.100.4  173.194.100.0/24         mrn
	6  192.168.10.48          NotFound    NotFound
	7 aa.bb.JJ.dd.ee          NotFound    NotFound



	## Dump the netblock data
	nb1 <- nbGetNetblockTable(nbPtr1)
	str(nb1)

	'data.frame':	68 obs. of  5 variables:
	$ NetBlock   : chr  "74.125.18.0/26" "74.125.18.64/26" "74.125.18.128/26" "74.125.18.192/26" ...
	$ Base       : chr  "74.125.18.0" "74.125.18.64" "74.125.18.128" "74.125.18.192" ...
	$ Mask       : int  26 26 26 26 24 24 24 24 24 24 ...
	$ BaseInt    : num  1.25e+09 1.25e+09 1.25e+09 1.25e+09 1.25e+09 ...
	$ Description: chr  "iad" "iad" "syd" "lhr" ...


	## When finished, remove pointer, and presumably the memory

	rm(nbPtr1)

Only IPv4 is currently supported. Portions of the code were written with IPv6 in mind.
