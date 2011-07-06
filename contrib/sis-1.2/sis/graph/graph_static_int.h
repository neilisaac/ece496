/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/graph/RCS/graph_static_int.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:54:12 $
 *
 */
/******************************** graph_static_int.h ********************/

typedef struct g_field_struct {
    int num_g_slots;
    int num_v_slots;
    int num_e_slots;
    gGeneric user_data;
} g_field_t;
