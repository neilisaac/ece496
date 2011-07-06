/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/phase/RCS/phase.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:58:34 $
 *
 */
#ifndef PHASE_H
#define PHASE_H

EXTERN void add_inv_network ARGS((network_t *));
EXTERN int  add_inv_node ARGS((network_t *, node_t *));
EXTERN void phase_quick ARGS((network_t *));
EXTERN void phase_good ARGS((network_t *));
EXTERN void phase_random_greedy ARGS((network_t *, int));
EXTERN void phase_trace_set ARGS((void));
EXTERN void phase_trace_unset ARGS((void));

#endif
