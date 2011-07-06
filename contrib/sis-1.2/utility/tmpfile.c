/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/utility/RCS/tmpfile.c,v $
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
 *  util_tmpfile -- open an unnamed temporary file
 *
 *  This is the ANSI C standard routine; we have hacks here because many
 *  compilers/systems do not have it yet.
 */

#ifdef unix

extern char *mktemp();

FILE *
util_tmpfile()
{
    FILE *fp;
    char *filename, *junk;

    junk = util_strsav("/usr/tmp/tempXXXXXX");
    filename = mktemp(junk);
    if ((fp = fopen(filename, "w+")) == NULL) {
	(void) fprintf(stderr, "Could not open the temporary file (%s)\n", filename);
	FREE(junk);
	return NULL;
    }
    (void) unlink(filename);
    FREE(junk);
    return fp;
}

#else

FILE *
util_tmpfile()
{
    return fopen("utiltmp", "w+");
}

#endif
