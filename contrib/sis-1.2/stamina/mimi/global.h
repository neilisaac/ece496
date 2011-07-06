/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/stamina/mimi/RCS/global.h,v $
 * $Author: sis $
 * $Revision: 1.3 $
 * $Date: 1994/07/15 22:58:50 $
 *
 */
/*******************************************************************
 *                                                                 *
 *  Global.h   ---- this header file contains all global variables *
 *                   which are used by encoding program.           *
 *                                                                 *
 *  All global variables will be initially declared in main.c.     *
 *  So global.h won't be included in main.c.                       *
 *                                                                 *
 *******************************************************************/

/*************************Global Variables**************************/

extern STATE **states;		/* array of pointers to states. */
extern EDGE  **edges;		/* array of pointers to edges.  */
extern char b_file[];

extern int num_pi;		/* number of primary inputs     */
extern int num_po;		/* number of primary outputs    */
extern int num_product; 	/* number of product terms      */
extern int num_st;		/* number of states             */
/* extern int code_length;		/* the encoding length. The dufault 
				   value is the minimum encoding 
				   length. User can specify the 
				   encoding length by using the option
				   -l following an integer      */
