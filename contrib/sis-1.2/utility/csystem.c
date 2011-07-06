/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/utility/RCS/csystem.c,v $
 * $Author: sis $
 * $Revision: 1.3 $
 * $Date: 22/.0/.1 .2:.2:.1 $
 *
 */
/* LINTLIBRARY */
#include "copyright.h"
#include "port.h"
#include <sys/wait.h>
#include "utility.h"

int
util_csystem(s)
char *s;
{
    register SIGNAL_FN (*istat)(), (*qstat)();
#if defined(_IBMR2) || defined(__osf__)
    int status;    
#else
    union wait status;
#endif
    int pid, w, retval;

    if ((pid = vfork()) == 0) {
	(void) execl("/bin/csh", "csh", "-f", "-c", s, 0);
	(void) _exit(127);
    }

    /* Have the parent ignore interrupt and quit signals */
    istat = signal(SIGINT, SIG_IGN);
    qstat = signal(SIGQUIT, SIG_IGN);

    while ((w = wait(&status)) != pid && w != -1)
	    ;
    if (w == -1) {		/* check for no children ?? */
	retval = -1;
    } else {
#if defined(_IBMR2) || defined(__osf__)
	retval = status;
#else
	retval = status.w_status;
#endif
    }

    /* Restore interrupt and quit signal handlers */
    (void) signal(SIGINT, istat);
    (void) signal(SIGQUIT, qstat);
    return retval;
}
