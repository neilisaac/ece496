/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/mincov/RCS/mincov.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:57:09 $
 *
 */
/* exported */
EXTERN sm_row *sm_minimum_cover ARGS((sm_matrix *, int *, int, int));

EXTERN sm_row *sm_mat_bin_minimum_cover ARGS((sm_matrix *, int *, int, int, int, int, int (*)()
));
EXTERN sm_row *sm_mat_minimum_cover ARGS((sm_matrix *, int *, int, int, int, int, int (*)()));
