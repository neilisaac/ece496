/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/resub/RCS/resub.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 19:00:06 $
 *
 */
#ifndef RESUB_H
#define RESUB_H

EXTERN int resub_alge_node ARGS((node_t *, int));
EXTERN void resub_alge_network ARGS((network_t *, int));
EXTERN void resub_bool_node ARGS((node_t *));
EXTERN void resub_bool_network ARGS((network_t *));

#endif
