/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/sim/RCS/sim_int.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 19:01:08 $
 *
 */
#define SIM_SLOT 			simulation
#define GET_VALUE(node)			((int) node->SIM_SLOT)
#define SET_VALUE(node, value)		(node->SIM_SLOT = (char *) value)

extern void simulate_node();
extern array_t *simulate_network();
extern array_t *simulate_stg();

extern int sim_verify_codegen();
