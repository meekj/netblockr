# netblockr

Builds tables of IPv4 networks with base address, netmask, a
description string, and a unique index. The table build
function returns a pointer to R that is used to reference
that table. A vector of IPv4 addresses can then be looked up
and returned in a data frame.

Only IPv4 is currently supported. Portions of the code were written with IPv6 in mind.

To install: 

    library(devtools)
    devtools::install_github("meekj/netblockr")

Test:

   library(stringr) # For str_split_fixed

   nb_txt_file1 <- 'data/google-dns-ipv4.txt'

   nb_raw_nets1 <- read.table(nb_txt_file1, header = TRUE, stringsAsFactors = FALSE)

   str(nb_raw_nets1)

   t <- str_split_fixed(nb_raw_nets1$NetBlock, '/', 2)
   nets1 <- nb_raw_nets1
   nets1$Base <- t[,1]
   nets1$Bits <- as.integer(t[,2])

   str(nets1)

   ## Build the netblock data table

   nbPtr1 <- nbBuildNetblockTable(nets1$NetBlock, nets1$Base, nets1$Bits, nets1$Description)
   nbSetMaskOrder(nbPtr1, sort(unique(nets1$Bits), decreasing = TRUE)) # Sort order to match smallest netblock

   typeof(nbPtr1) # Verify that we got a pointer from nbBuildNetblockTable

   nb1 <- nbGetNetblockTable(nbPtr1) # Dump the netblock data
   str(nb1)


   testIPs1 <- c('74.125.18.1', '74.125.18.21', '74.125.41.2', '172.217.33.193', '173.194.100.4', '192.168.15.48',
   '10.0.17.3', '10.0.40.1', '10.32.17.48', '10.32.28.17', '10.36.171.192', '10.37.241.14'
   )



   testIPs2 <- c('74.125.18.1', '74.125.18.21', '74.125.41.2', '172.217.33.193', '173.194.100.4', '192.168.15.48',
   '10.0.17.3', '10.0.40.1', '10.32.17.48', '10.32.28.17', '10.36.171.192', '10.37.241.14', 'aa.bb.JJ.dd.ee'
   )

   nbLookupIPaddrs(nbPtr1, testIPs1)





