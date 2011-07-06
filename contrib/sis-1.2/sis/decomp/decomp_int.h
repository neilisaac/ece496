/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/decomp/RCS/decomp_int.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:51:59 $
 *
 */
extern node_t 	*decomp_quick_kernel();
extern node_t 	*decomp_good_kernel();
extern array_t  *decomp_recur();
extern array_t  *my_array_append();
extern array_t  *decomp_tech_recur();
extern node_t   *dec_node_cube();
extern int      dec_block_partition();

extern sm_matrix *dec_node_to_sm();
extern node_t    *dec_sm_to_node();
