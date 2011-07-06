/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/util/RCS/strsav.c,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 19:03:25 $
 *
 */
/* LINTLIBRARY */

#include <stdio.h>
#include "util.h"


/*
 *  util_strsav -- save a copy of a string
 */
char *
util_strsav(s)
char *s;
{
    return strcpy(ALLOC(char, strlen(s)+1), s);
}
