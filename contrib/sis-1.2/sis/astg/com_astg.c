/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/sis/astg/RCS/com_astg.c,v $
 * $Author: sis $
 * $Revision: 1.4 $
 * $Date: 1992/05/06 18:50:07 $
 *
 */
/* -------------------------------------------------------------------------- *\
   com_astg.c -- Add commands for ASTG package.

	$Revision: 1.4 $
	$Date: 1992/05/06 18:50:07 $

   Package initialization and cleanup.
\* ---------------------------------------------------------------------------*/

#ifdef SIS
#include "sis.h"
#include "astg_int.h"
#include "si_int.h" 
#include "bwd_int.h"

void init_astg()
{
    astg_basic_cmds (ASTG_TRUE);
    si_cmds();
    bwd_cmds ();
}

void end_astg()
{
    astg_basic_cmds (ASTG_FALSE);
}
#endif /* SIS */
