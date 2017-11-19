
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


testIPs1 <- c('74.125.18.1', '74.125.18.21', '74.125.41.2', '172.217.33.193', '173.194.100.4', '192.168.10.48')

lookup1 <- nbLookupIPaddrs(nbPtr1, testIPs1)
lookup1


## Bad data in lookup:

testIPs2 <- c('74.125.18.1', '74.125.18.21', '74.125.41.2', '172.217.33.193', '173.194.100.4', '192.168.10.48', 'aa.bb.JJ.dd.ee')

lookup2 <- nbLookupIPaddrs(nbPtr1, testIPs2)
lookup2


## When finished, remove pointer, and presumably the memory

rm(nbPtr1)



