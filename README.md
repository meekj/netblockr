# netblockr

Builds tables of IPv4 networks with base address, netmask, a
description string, and a unique index. The table build
function returns a pointer to R that is used to reference
that table. A vector of IPv4 addresses can then be looked up
and returned in a data frame.

This package was inspired by the Perl Net::Netmask module which provides many more functions for dealing with IPv4 addresses.

### Applications:

* Classify IP addresses by subnet, geographic location, ISP netblock, etc

* Add company location data to utilization or security reports

* Summarize data by netblock / subnet, or company location, or AS number, etc

* Identify 'unknown' IP addresses

* Aid IP address management using data from logs, packet capture, etc

  * Identify active and in-active subnets based on observed traffic

  * Compute DHCP range utilization

  * Report unexpected IP addresses


### To install: 

    library(devtools)
    devtools::install_github("meekj/netblockr")
	

### Example network description file:

	# Organization network example  (a comment line)
	#  empty lines are ignored and can be used for human readability
	Netblock  Region Code More info (indented lines are comments)

	10.16.0.0/12    NOAM xxx North America Supernet
	10.16.0.0/22    NOAM PTN Princeton NJ Data Center Servers
	10.16.4.0/24    NOAM PTN Princeton NJ Data Center Network
	10.16.5.0/24    NOAM PTN Princeton NJ Data Center Management
	10.16.6.0/23    NOAM PTN Princeton NJ West Wing Floor #1 '#' in data
	10.16.8.0/23    NOAM PTN Princeton NJ West Wing Floor #2
	10.16.10.0/23   NOAM PTN Princeton NJ Administration Building
	10.16.15.0/24   NOAM PTN Princeton NJ Environmental Controls
	10.16.18.0/28   NOAM PTN Princeton NJ VPN Routers
	10.16.18.16/28  NOAM PTN Princeton NJ DMZ
	10.18.10.0/23   NOAM TOL Tolchester Beach MD
	10.18.12.0/23   NOAM SCV Sarah Creek VA

	10.32.0.0/12    SOAM xxx South America Supernet
	10.33.1.0/20    SOAM RIO Brazil

    255.255.1.0/24  SOAM ANA Antarctica Near the other edge
    0.0.1.0/24      NOAM ART Arctic Near one edge

	10.48.0.0/12    EMEA xxx EMEA Supernet
	10.48.10.0/23   EMEA LBS London Berkeley Square
	10.48.12.0/23   EMEA PSS Portsmouth Southsea
	10.48.14.0/23   EMEA IOW Cowes Isle of Wight
	10.48.16.0/23   EMEA ZUR Zürich Wasserschöpfi

	10.64.0.0/12    APAC xxx APAC Supernet
	10.64.10.0/23   APAC SNG Singapore
	10.64.12.0/23   APAC TOK Tokyo Heiwajima


### Basic usage:

	library(dplyr)
	library(readr)
	library(stringr)
	library(netblockr)

	## A sample network description file included in the package
	organization_net_file <- system.file("extdata", "org-net.txt", package = "netblockr")

	## Build the network table in C++ space and get a pointer to the table
	nbPtrOrg <- nbReadAndLoadNetwork(organization_net_file)

	## Dump the network table, just for verification, etc.
	nb <- nbGetNetblockTable(nbPtrOrg)

    ## Use BlockKey value to sort the netblocks
    nb %>% arrange(BlockKey)

             NetBlock        Base Mask     BlockKey                                          Description
	1      0.0.1.0/24     0.0.1.0   24        16408                        NOAM ART Arctic Near one edge
	2    10.16.0.0/12   10.16.0.0   12  10804527116                      NOAM xxx North America Supernet
	3    10.16.0.0/22   10.16.0.0   22  10804527126            NOAM PTN Princeton NJ Data Center Servers
	4    10.16.4.0/24   10.16.4.0   24  10804592664            NOAM PTN Princeton NJ Data Center Network
	5    10.16.5.0/24   10.16.5.0   24  10804609048         NOAM PTN Princeton NJ Data Center Management
	6    10.16.6.0/23   10.16.6.0   23  10804625431 NOAM PTN Princeton NJ West Wing Floor #1 '#' in data
	7    10.16.8.0/23   10.16.8.0   23  10804658199             NOAM PTN Princeton NJ West Wing Floor #2
	8   10.16.10.0/23  10.16.10.0   23  10804690967        NOAM PTN Princeton NJ Administration Building
	9   10.16.15.0/24  10.16.15.0   24  10804772888         NOAM PTN Princeton NJ Environmental Controls
	10  10.16.18.0/28  10.16.18.0   28  10804822044                    NOAM PTN Princeton NJ VPN Routers
	11 10.16.18.16/28 10.16.18.16   28  10804823068                            NOAM PTN Princeton NJ DMZ
	12  10.18.10.0/23  10.18.10.0   23  10813079575                         NOAM TOL Tolchester Beach MD
	13  10.18.12.0/23  10.18.12.0   23  10813112343                              NOAM SCV Sarah Creek VA
	14   10.32.0.0/12   10.32.0.0   12  10871635980                      SOAM xxx South America Supernet
	15   10.33.1.0/20   10.33.1.0   20  10875830292                                      SOAM RIO Brazil
	16   10.48.0.0/12   10.48.0.0   12  10938744844                               EMEA xxx EMEA Supernet
	17  10.48.10.0/23  10.48.10.0   23  10938908695                      EMEA LBS London Berkeley Square
	18  10.48.12.0/23  10.48.12.0   23  10938941463                         EMEA PSS Portsmouth Southsea
	19  10.48.14.0/23  10.48.14.0   23  10938974231                         EMEA IOW Cowes Isle of Wight
	20  10.48.16.0/23  10.48.16.0   23  10939006999                        EMEA ZUR Zürich Wasserschöpfi
	21   10.64.0.0/12   10.64.0.0   12  11005853708                               APAC xxx APAC Supernet
	22  10.64.10.0/23  10.64.10.0   23  11006017559                                   APAC SNG Singapore
	23  10.64.12.0/23  10.64.12.0   23  11006050327                             APAC TOK Tokyo Heiwajima
	24 255.255.1.0/24 255.255.1.0   24 274873729048              SOAM ANA Antarctica Near the other edge


	## Some IP addresses to lookup
	testAddrs <- c('10.10.10.1', '10.20.10.18', '10.16.3.28', '10.16.8.50', '10.16.9.50',
	               '10.16.18.18', '10.16.18.35', '10.48.17.32', '10.50.17.32', '192.168.55.47')

	## Which netblock contains the IP address?
	nbLookupIPaddrs(nbPtrOrg, testAddrs)

    ## Which netblock contains the IP address?
    lookup_result <- nbLookupIPaddrs(nbPtrOrg, testAddrs)
    lookup_result

              IPaddr       NetBlock                               Description
	1     10.10.10.1       NotFound                                  NotFound
	2    10.20.10.18   10.16.0.0/12           NOAM xxx North America Supernet
	3     10.16.3.28   10.16.0.0/22 NOAM PTN Princeton NJ Data Center Servers
	4     10.16.8.50   10.16.8.0/23  NOAM PTN Princeton NJ West Wing Floor #2
	5     10.16.9.50   10.16.8.0/23  NOAM PTN Princeton NJ West Wing Floor #2
	6    10.16.18.18 10.16.18.16/28                 NOAM PTN Princeton NJ DMZ
	7    10.16.18.35   10.16.0.0/12           NOAM xxx North America Supernet
	8    10.48.17.32  10.48.16.0/23             EMEA ZUR Zürich Wasserschöpfi
	9    10.50.17.32   10.48.0.0/12                    EMEA xxx EMEA Supernet
	10 192.168.55.47       NotFound                                  NotFound


### IP address management examples

	## How many of the test IP addresses are in each netblock?
	lookup_result %>% count(NetBlock) %>% arrange(desc(n))
	
	# A tibble: 7 x 2
	        NetBlock     n
	           <chr> <int>
	1   10.16.0.0/12     2
	2   10.16.8.0/23     2
	3       NotFound     2
	4   10.16.0.0/22     1
	5 10.16.18.16/28     1
	6   10.48.0.0/12     1
	7  10.48.16.0/23     1


	## Active Subnets - which netblocks contain the test IP addresses?
	inner_join(nb, lookup_result %>% count(NetBlock), by = 'NetBlock') %>% select(n, NetBlock, Description)
	
      n       NetBlock                               Description
	1 2   10.16.0.0/12           NOAM xxx North America Supernet
	2 1   10.16.0.0/22 NOAM PTN Princeton NJ Data Center Servers
	3 2   10.16.8.0/23  NOAM PTN Princeton NJ West Wing Floor #2
	4 1 10.16.18.16/28                 NOAM PTN Princeton NJ DMZ
	5 1   10.48.0.0/12                    EMEA xxx EMEA Supernet
	6 1  10.48.16.0/23             EMEA ZUR Zürich Wasserschöpfi


	## In-active Subnets, based on the list of test addresses
	anti_join(nb, lookup_result, by = 'NetBlock') %>% select(NetBlock, Description)
	
             NetBlock                                          Description
	1      0.0.1.0/24                        NOAM ART Arctic Near one edge
	2    10.16.4.0/24            NOAM PTN Princeton NJ Data Center Network
	3    10.16.5.0/24         NOAM PTN Princeton NJ Data Center Management
	4    10.16.6.0/23 NOAM PTN Princeton NJ West Wing Floor #1 '#' in data
	5   10.16.10.0/23        NOAM PTN Princeton NJ Administration Building
	6   10.16.15.0/24         NOAM PTN Princeton NJ Environmental Controls
	7   10.16.18.0/28                    NOAM PTN Princeton NJ VPN Routers
	8   10.18.10.0/23                         NOAM TOL Tolchester Beach MD
	9   10.18.12.0/23                              NOAM SCV Sarah Creek VA
	10   10.32.0.0/12                      SOAM xxx South America Supernet
	11   10.33.1.0/20                                      SOAM RIO Brazil
	12  10.48.10.0/23                      EMEA LBS London Berkeley Square
	13  10.48.12.0/23                         EMEA PSS Portsmouth Southsea
	14  10.48.14.0/23                         EMEA IOW Cowes Isle of Wight
	15   10.64.0.0/12                               APAC xxx APAC Supernet
	16  10.64.10.0/23                                   APAC SNG Singapore
	17  10.64.12.0/23                             APAC TOK Tokyo Heiwajima
	18 255.255.1.0/24              SOAM ANA Antarctica Near the other edge



	## Addresses from unknown address space
	lookup_result %>% filter(Description == 'NotFound')
	
	         IPaddr NetBlock Description
	1    10.10.10.1 NotFound    NotFound
	2 192.168.55.47 NotFound    NotFound


	## Unknown subnets within a supernet
	lookup_result %>% filter(str_detect(Description, 'xxx') & str_detect(Description, 'Supernet'))
	
	       IPaddr     NetBlock                     Description
	1 10.20.10.18 10.16.0.0/12 NOAM xxx North America Supernet
	2 10.16.18.35 10.16.0.0/12 NOAM xxx North America Supernet
	3 10.50.17.32 10.48.0.0/12          EMEA xxx EMEA Supernet


### Cleanup

    ## When finished, remove pointer, and presumably free the memory

    rm(nbPtrOrg)


### Notes:

BlockKey is a unique value computed by anding the mask value with the
integer form of netblock base IP address, shifting left 6 bits and
then adding the mask bit count. BlockKey is an unsigned 64 bit number in C++ and a num after being passed back to R.

nbReadAndLoadNetwork() provides a convenient method to read an ASCII
network description and build the netblock table in C++ space, but
users can choose to build the table from vectors, or data.frame columns, using
nbBuildNetblockTable() and nbSetMaskOrder().

Only IPv4 is currently supported but portions of the code were written with IPv6 in mind.

