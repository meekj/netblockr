
static const u_int maskval_ipv4[33] = { 0x00000000,
					0x80000000, 0xc0000000, 0xe0000000, 0xf0000000,
					0xf8000000, 0xfc000000, 0xfe000000, 0xff000000,
					0xff800000, 0xffc00000, 0xffe00000, 0xfff00000,
					0xfff80000, 0xfffc0000, 0xfffe0000, 0xffff0000,
					0xffff8000, 0xffffc000, 0xffffe000, 0xfffff000,
					0xfffff800, 0xfffffc00, 0xfffffe00, 0xffffff00,
					0xffffff80, 0xffffffc0, 0xffffffe0, 0xfffffff0,
					0xfffffff8, 0xfffffffc, 0xfffffffe, 0xffffffff };


// Data structure for the table of networks

struct nbTable {
  std::vector <u_int>       nb_base_as_uint;
  std::vector <int>         nb_mask, nb_unique_masks;
  std::vector <std::string> nb_base_and_mask, nb_base_as_string, nb_description;
  std::map <u_int, int>     nb_map;
};

