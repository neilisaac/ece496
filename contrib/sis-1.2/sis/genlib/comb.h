/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/genlib/RCS/comb.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:53:42 $
 *
 */
/* file @(#)comb.h	1.1                      */
/* last modified on 5/29/91 at 12:35:20   */
typedef struct partition_struct partition_t;
struct partition_struct {
    int *value;
    int nvalue;
    int non_zero;
    int sum;
    int maxsum;
};


typedef struct combination_struct combination_t;
struct combination_struct {
    int *value;
    int *state;
    int n;
};



combination_t *gl_init_gen_combination();
int gl_next_combination(), gl_next_nondecreasing_combination();
void gl_free_gen_combination();

partition_t *gl_init_gen_partition();
int gl_next_partition_less_than(), gl_next_partition();
void gl_free_gen_partition();
