/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/util/RCS/stub.c,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 19:03:25 $
 *
 */
/* LINTLIBRARY */

#ifdef LACK_SYS5

char *
memcpy(s1, s2, n)
char *s1, *s2;
int n;
{
    extern bcopy();
    bcopy(s2, s1, n);
    return s1;
}

char *
memset(s, c, n)
char *s;
int c;
int n;
{
    extern bzero();
    register int i;

    if (c == 0) {
	bzero(s, n);
    } else {
	for(i = n-1; i >= 0; i--) {
	    *s++ = c;
	}
    }
    return s;
}

char *
strchr(s, c)
char *s;
int c;
{
    extern char *index();
    return index(s, c);
}

char *
strrchr(s, c)
char *s;
int c;
{
    extern char *rindex();
    return rindex(s, c);
}


#endif

#ifndef UNIX
#include <stdio.h>

/*ARGSUSED*/
FILE *
popen(string, mode)
char *string;
char *mode;
{
    (void) fprintf(stderr, "popen not supported on your operating system\n");
    return NULL;
}


/*ARGSUSED*/
int
pclose(fp)
FILE *fp;
{
    (void) fprintf(stderr, "pclose not supported on your operating system\n");
    return -1;
}
#endif

/* put something here in case some compilers abort on empty files ... */
util_do_nothing()
{
    return 1;
}
