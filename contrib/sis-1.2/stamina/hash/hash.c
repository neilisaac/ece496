/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/stamina/hash/RCS/hash.c,v $
 * $Author: sis $
 * $Revision: 1.3 $
 * $Date: 1994/07/15 22:58:45 $
 *
 */
/************************************************************
 *  hash(s) --- The hashing function which forms hash value *
 *              for string s .                              *
 ************************************************************/

#include <stdio.h>
#include "hash.h"


int hash(s, hash_size)
char *s;
int hash_size;
{
	int hashval;		/* hash value of string s */


	for ( hashval = 0; *s != '\0'; )  {
	    hashval += *s;
	    s++ ;
	}

	return ( hashval % hash_size );

}

	


