/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/sis/atpg/RCS/atpg_int.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1994/07/15 23:00:23 $
 *
 */
#include "atpg.h"

#define ALL_ZERO 0
#define ALL_ONE ~0
#define WORD_LENGTH 32
#define ATPG_DEBUG 0

#define EXTRACT_BIT(word,pos) (((word) & (1 << (pos))) != 0)

/* fault list data structures */
#define foreach_fault(faults, gen, f)  			     \
    for(gen = lsStart(faults);                               \
	(lsNext(gen, (lsGeneric *) &f, LS_NH) == LS_OK)      \
		    || ((void) lsFinish(gen), 0); )


