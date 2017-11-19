#include <Rcpp.h>
using namespace Rcpp;

#include <arpa/inet.h>
#include <iostream>
#include <vector>
#include <string>
#include <map>

// [[Rcpp::interfaces(r, cpp)]]

static const u_int maskval_ipv4[33] = { 0x00000000,
					0x80000000, 0xc0000000, 0xe0000000, 0xf0000000,
					0xf8000000, 0xfc000000, 0xfe000000, 0xff000000,
					0xff800000, 0xffc00000, 0xffe00000, 0xfff00000,
					0xfff80000, 0xfffc0000, 0xfffe0000, 0xffff0000,
					0xffff8000, 0xffffc000, 0xffffe000, 0xfffff000,
					0xfffff800, 0xfffffc00, 0xfffffe00, 0xffffff00,
					0xffffff80, 0xffffffc0, 0xffffffe0, 0xfffffff0,
					0xfffffff8, 0xfffffffc, 0xfffffffe, 0xffffffff };


// The table of networks
struct nbTable {
  std::vector <u_int>       nb_base_as_uint;
  std::vector <int>         nb_mask, nb_unique_masks;
  std::vector <std::string> nb_base_and_mask, nb_base_as_string, nb_description;
  std::map <u_int, int>     nb_map;
};

//' Load netblock data into a table. Returns a pointer to the table.
//'
//' @export
// [[Rcpp::export]]
XPtr< nbTable > nbBuildNetblockTable (CharacterVector BaseAndMask, CharacterVector IPaddrStrings, IntegerVector Mask, CharacterVector Description) {
  struct sockaddr_in sa;
  const char* ipaddrstring;
  char descstring;
  unsigned int binIP;
  
  int n = IPaddrStrings.size();
  IntegerVector binIPvec(n);

  nbTable* nbt = new nbTable;

  for(int i = 0; i < n; ++i) {                            // Process each netblock
    ipaddrstring = IPaddrStrings[i];
    if (inet_pton(AF_INET, ipaddrstring, &sa.sin_addr)) { // Generate the unique index for each IPv4 net block
      binIP = htonl(sa.sin_addr.s_addr);
      binIP &= maskval_ipv4[Mask[i]];                     // Apply mask in case provided base address provided is not actual

      nbt->nb_base_and_mask.push_back(as<std::string>(BaseAndMask[i])); // Build the table
      nbt->nb_mask.push_back(Mask[i]);
      nbt->nb_base_as_string.push_back(ipaddrstring);
      nbt->nb_base_as_uint.push_back(binIP);
      nbt->nb_description.push_back(as<std::string>(Description[i]));
      nbt->nb_map.insert ( std::pair<u_int, int>(binIP, i) ); // Map of unique index to array index

    } else {                                                  // Log a warning if inet_pton fails
      std::string warning_ip_addr(ipaddrstring);              // so that netblock data can be fixed
      warning("nbBuildNetblockTablevBad format IP address: " + warning_ip_addr);   // This is Rcpp::warning()
    }
  }
  XPtr< nbTable > rptr(nbt, true); // Prevent garbage collection, table stays in scope until 'rm(rptr)' in R
  return(rptr);
}

// See:  https://www.r-bloggers.com/external-pointers-with-rcpp/

//' Add the unique netmasks to the table in the desired search order, usually largest netmask first to find shortest match
//'
//' @export
// [[Rcpp::export]]
void nbSetMaskOrder (XPtr< nbTable > nbt, IntegerVector Masks) { // Could do it in BuildNetblockTable
  for(int i = 0; i < Masks.size(); ++i) {                        //  but easier to do it with R help
    nbt->nb_unique_masks.push_back(Masks[i]);                    //  for now & provide user control
  }
}

//' Dumps netblock data table into a data frame
//'
//' @export
// [[Rcpp::export]]
DataFrame nbGetNetblockTable (XPtr< nbTable > nbt) { // Access to net block table from R

return DataFrame::create(Named("NetBlock")=nbt->nb_base_and_mask,
			       Named("Base")=nbt->nb_base_as_string,
			       Named("Mask")=nbt->nb_mask,
			       Named("BaseInt")=nbt->nb_base_as_uint,
			       Named("Description")=nbt->nb_description,
			       _["stringsAsFactors"] = false );			       			       
}

//' Lookup IPv4 address in a netblock table
//'
//' @export
// [[Rcpp::export]]
DataFrame nbLookupIPaddrs (XPtr< nbTable > nbt, CharacterVector IPaddrStrings) { // Lookup IP addresses provided in a vector
  struct sockaddr_in sa;
  const char* ipaddrstring;
  unsigned int binIP, t_binIP;
  int match_index;
  std::string match_string_network, match_string_description;
  std::vector <std::string> lu_base_and_mask, lu_description; // Lookup results
  std::string warning_string;
  
  for(int i = 0; i < IPaddrStrings.size(); i++) {
    match_string_network = "NotFound";
    match_string_description = "NotFound";

    ipaddrstring = IPaddrStrings[i];
    if (inet_pton(AF_INET, ipaddrstring, &sa.sin_addr)) {        // Presentation (dotted quad)
      binIP = htonl(sa.sin_addr.s_addr);                         //  to integer
    
      // Rcout << std::setprecision(11) << "Lookup: " << i  <<  "  " <<  ipaddrstring <<  "  " << '\n';
      
      for (int j = 0; j < nbt->nb_unique_masks.size(); j++) {    // Check each netmask possibility
	t_binIP = binIP & maskval_ipv4[nbt->nb_unique_masks[j]]; // Index to check for existence
      
	if (nbt->nb_map.count(t_binIP) > 0) {                    // Do we have that netblock in the table?
	  match_index = nbt->nb_map.find(t_binIP)->second;

	  if (nbt->nb_unique_masks[j] == nbt->nb_mask[match_index]) { // Check that tested mask is == to the actual mask
	    match_string_network     = nbt->nb_base_and_mask[match_index];
	    match_string_description = nbt->nb_description[match_index];
	
	    // Rcout << std::setprecision(11) << " LookupIPs: " <<  ipaddrstring <<  " t_binIP: " << t_binIP  <<  " match_index: " <<  match_index  << "  "  <<  match_string_description  << '\n';
	    break; // Get out on first match, usually shortest, depends on mask sort order provided to AddUniqueMasks
	  }
	  //      } else {
	  // Rcout << " LookupIPs: " <<  ipaddrstring << " with mask "  <<  nbt->nb_unique_masks[j] <<  " Not found\n";
	}
      }
    } else { // Log a warning if inet_pton fails, and will be a "NotFound"
      std::string warning_ip_addr(ipaddrstring);
      warning("nbLookupIPaddrs Bad format IP address: " + warning_ip_addr);
    }
    
    lu_base_and_mask.push_back(match_string_network);   // Collect results
    lu_description.push_back(match_string_description);	
  }
  return DataFrame::create(Named("IPaddr")=IPaddrStrings,
			   Named("NetBlock")=lu_base_and_mask,
			   Named("Description")=lu_description,
			   _["stringsAsFactors"] = false );
}

