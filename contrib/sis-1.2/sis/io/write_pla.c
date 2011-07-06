/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/io/RCS/write_pla.c,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:54:43 $
 *
 */
#include "sis.h"
#include "io_int.h"


void 
write_pla(fp, network)
FILE *fp;
network_t *network;
{
    pPLA PLA;

    PLA = network_to_pla(network);
    if (PLA == 0) return;

    /* Let espresso do the dirty work */
    if (PLA->D) {
	fprint_pla(fp, PLA, FD_type);
    }
    else {
	fprint_pla(fp, PLA, F_type);
    }
    discard_pla(PLA);
}
