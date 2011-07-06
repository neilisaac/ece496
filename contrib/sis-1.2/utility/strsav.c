/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/utility/RCS/strsav.c,v $
 * $Author: sis $
 * $Revision: 1.3 $
 * $Date: 1994/07/15 22:55:23 $
 *
 */
/* LINTLIBRARY */
#include "copyright.h"
#include "port.h"
#include "utility.h"

/*
 *  util_strsav -- save a copy of a string
 */
char *
util_strsav(s)
char *s;
{
    return strcpy(ALLOC(char, strlen(s)+1), s);
}
