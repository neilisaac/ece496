/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/main/RCS/sis.h,v $
 * $Author: sis $
 * $Revision: 1.3 $
 * $Date: 1992/05/06 18:55:42 $
 *
 */
#ifndef SIS_H
#define SIS_H

/* espresso brings in sparse.h, mincov.h, util.h */
#include "espresso.h"

#include "avl.h"
#include "enc.h"
#include "st.h"
#include "array.h"
#include "list.h"
#include "sat.h"
#include "spMatrix.h"
#include "var_set.h"
#ifdef SIS
#include "graph.h"
#include "graph_static.h"
#endif /* SIS */

#include "error.h"
#include "node.h"
#include "nodeindex.h"

#ifdef SIS
#include "stg.h"
#include "astg.h"
#endif /* SIS */
#include "network.h"
#include "command.h"
#include "io.h"

#include "factor.h"
#include "decomp.h"
#include "resub.h"	
#include "phase.h"	
#include "simplify.h"	
#include "minimize.h"
#include "graphics.h"

#include "extract.h"
#ifdef SIS
#include "clock.h"
#include "latch.h"
#include "retime.h"
#endif /* SIS */

#include "delay.h"
#include "library.h"
#include "map.h" 
#include "pld.h" 

#include "bdd.h"
#include "order.h"
#include "ntbdd.h"

#ifdef SIS
#include "seqbdd.h"
#endif /* SIS */

#include "gcd.h"
#include "maxflow.h"
#include "speed.h"

extern FILE *sisout;
extern FILE *siserr;
extern FILE *sishist;
extern array_t *command_hist;
extern char *program_name;
extern char *sis_version();
extern char *sis_library();

#define misout sisout
#define miserr siserr

#define INFINITY	(1 << 30)

#endif
