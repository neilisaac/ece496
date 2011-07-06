/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/stamina/mimi/RCS/conf.c,v $
 * $Author: sis $
 * $Revision: 1.3 $
 * $Date: 1994/07/15 22:58:50 $
 *
 */
/* SCCSID%W% */

int merge();
int maximal_compatibles();
int prime_compatible();
int sm_setup();
int bound();

int disjoint();
int map();
int say_solution();
int iso_find();

null()
{
}

int (*method1[])()= {merge, disjoint, iso_find, maximal_compatibles,
	bound, 
	prime_compatible, sm_setup, map, say_solution, (int(*)()) 0};

make_null(id)
{
	method1[id] = null;
}
