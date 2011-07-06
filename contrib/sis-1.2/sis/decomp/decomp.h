/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/decomp/RCS/decomp.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:51:59 $
 *
 */
#ifndef DECOMP_H
#define DECOMP_H

EXTERN void decomp_quick_network ARGS((network_t *));
EXTERN void decomp_quick_node ARGS((network_t *, node_t *));
EXTERN array_t *decomp_quick ARGS((node_t *));

EXTERN void decomp_good_network ARGS((network_t *));
EXTERN void decomp_good_node ARGS((network_t *, node_t *));
EXTERN array_t *decomp_good ARGS((node_t *));

EXTERN void decomp_disj_network ARGS((network_t *));
EXTERN void decomp_disj_node ARGS((network_t *, node_t *));
EXTERN array_t *decomp_disj ARGS((node_t *));

EXTERN void decomp_tech_network ARGS((network_t *, int, int));

#endif
