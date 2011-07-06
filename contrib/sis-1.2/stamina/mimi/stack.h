/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/stamina/mimi/RCS/stack.h,v $
 * $Author: sis $
 * $Revision: 1.3 $
 * $Date: 1994/07/15 22:58:50 $
 *
 */

/* SCCSID %W% */
typedef struct stack STACK;

struct stack {
	int status;
	int **ptr;
};

#define STACKLIMIT 1000
#define EMPTY NIL(STACK)

STACK *pop();
extern STACK *xstack;
