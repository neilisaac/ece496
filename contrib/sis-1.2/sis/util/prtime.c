/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/util/RCS/prtime.c,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 19:03:25 $
 *
 */
/* LINTLIBRARY */

#include <stdio.h>
#include "util.h"


/*
 *  util_print_time -- massage a long which represents a time interval in
 *  milliseconds, into a string suitable for output 
 *
 *  Hack for IBM/PC -- avoids using floating point
 */

char *
util_print_time(t)
long t;
{
    static char s[40];

    (void) sprintf(s, "%ld.%02ld sec", t/1000, (t%1000)/10);
    return s;
}
