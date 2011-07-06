/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/options/RCS/dflttap.c,v $
 * $Author: sis $
 * $Revision: 1.3 $
 * $Date: 1994/07/15 22:53:38 $
 *
 */
#include "copyright.h"
#include "port.h"
#include "utility.h"
#include "options.h"

/*
 * This gets linked in if the program doesn't use tap
 *	It always returns NIL(char) so the rest of `options' can tell
 *	it is the bogus one
 */

#ifndef lint

/*ARGSUSED*/
char *tapRootDirectory(new)
char *new;
{
    return(NIL(char));
}

#endif /*lint*/
