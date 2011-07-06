/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/stamina/hash/RCS/lookup.c,v $
 * $Author: sis $
 * $Revision: 1.3 $
 * $Date: 1994/07/15 22:58:45 $
 *
 */
/************************************************************
 *  lookup(s,hashtab,hash_size) --- Look for s in hashtab.  *
 *                If lookup finds the entry already present,*
 *                it returns a pointer to it;               *
 *                if not, it returns NULL.                  *
 ************************************************************/

#include <stdio.h>
#include "hash.h"


NLIST *lookup(s, hashtab, hash_size)
char *s;
NLIST *hashtab[];
int hash_size;
{
	NLIST *np;	/* a pointer to nlist */
	int hash_index;

	hash_index = hash(s, hash_size);
	for (np = hashtab[hash_index]; np != NIL(NLIST); np = np->next)  {
	    if ( strcmp(s, np->name) == 0 )  {
		return(np);	/* found it */
	    }
	}

	return (NIL(NLIST));		/* not found */

}
