/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/resub/RCS/bresub.c,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 19:00:06 $
 *
 */
#include "sis.h"
#include "resub.h"
#include "resub_int.h"

void
resub_bool_node(f)
node_t *f;
{
    (void) fprintf(miserr, "Warning!: Boolean resub has not been ");
    (void) fprintf(miserr, "implemented, algebraic resub is used.\n");
    (void) resub_alge_node(f, 1);
}

void
resub_bool_network(network)
network_t *network;
{
    (void) fprintf(miserr, "Warning!: Boolean resub has not been ");
    (void) fprintf(miserr, "implemented, algebraic resub is used.\n");
    resub_alge_network(network, 1);
}
