/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/sis/error/RCS/error.h,v $
 * $Author: sis $
 * $Revision: 1.3 $
 * $Date: 1993/05/28 22:42:39 $
 *
 */
EXTERN void error_init ARGS((void));
EXTERN void error_append ARGS((char *));
EXTERN char *error_string ARGS((void));
EXTERN void error_cleanup ARGS((void));
