/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/command/RCS/undo.c,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:51:44 $
 *
 */
#include "sis.h"
#include "com_int.h"


/* ARGSUSED */
com_undo(network, argc, argv)
network_t **network;
int argc;
char **argv;
{
    network_t *temp;

    if (argc != 1) {
	(void) fprintf(miserr, "usage: undo\n");
	return 1;
    }

    if (backup_network == NIL(network_t)) {
	(void) fprintf(miserr, "undo: no network currently saved\n");
	return 1;
    } else {
	temp = *network;
	*network = backup_network;
	backup_network = temp;
	return 0;
    }
}
