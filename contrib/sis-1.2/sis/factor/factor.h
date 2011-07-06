/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/factor/RCS/factor.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:53:18 $
 *
 */
#ifndef FACTOR_H
#define FACTOR_H

EXTERN void factor ARGS((node_t *));
EXTERN void factor_quick ARGS((node_t *));
EXTERN void factor_good ARGS((node_t *));

EXTERN void factor_free ARGS((node_t *));
EXTERN void factor_dup ARGS((node_t *, node_t *));
EXTERN void factor_alloc ARGS((node_t *));
EXTERN void factor_invalid ARGS((node_t *));

EXTERN void factor_print ARGS((FILE *, node_t *));
EXTERN int node_value ARGS((node_t *));
EXTERN int factor_num_literal ARGS((node_t *));
EXTERN int factor_num_used ARGS((node_t *, node_t *));

EXTERN void eliminate ARGS((network_t *, int, int));

EXTERN array_t *factor_to_nodes ARGS((node_t *));

#endif
