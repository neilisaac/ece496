/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/maxflow/RCS/maxflow_int.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:57:02 $
 *
 */
/*
 * functions that will be used internal to the package
 */
extern  void mf_error();
extern  char *MF_calloc();
extern  void get_cutset();

#define LABELLED   1
#define MARKED     2
#define FICTITIOUS 4
#define CUR_TRACE  8

#define MAX_FLOW    100000000
#define MF_HASHSIZE 399
#define MF_MAXSTR 256

/*
 * miscellaneous marcos 
 */
#define MF_ALLOC(num,type) 						\
	((type *)MF_calloc((int)(num), sizeof(type)))

