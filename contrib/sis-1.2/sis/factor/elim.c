/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/factor/RCS/elim.c,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:53:18 $
 *
 */
/*
 *  eliminate: selective collapsing 
 *  routines provided:
 *      eliminate();
 */

#include "sis.h"
#include "factor.h"
#include "factor_int.h"

/*
 *  eliminate all nodes with value less than or equal to thresh
 */

static int clp_est();
static int cmp_est();
static int cov_est();
static int cov_leaf_est();
static int cov_inv_est();
static int cov_and_est();
static int cov_or_est();

void
eliminate(network, thresh, limit)
network_t *network;
int thresh, limit;
{
    array_t *nodevec;
    int i, j;
    bool elimok, eliminating = TRUE;
    node_t *np, *fanout, *fanin;
    lsGen gen;
    st_table *dont_elim;
    char *dummy;
    int newlimit, tmplimit;
    extern array_t *order_nodes_elim();

    dont_elim = st_init_table(st_ptrcmp, st_ptrhash); 
    while (eliminating) {

    (void) network_cleanup(network);
    eliminating = FALSE;

    nodevec= order_nodes_elim(network);

    newlimit = 0;
    for(i = 0; i < array_n(nodevec); i++) {
        np = array_fetch(node_t *, nodevec, i);
        tmplimit= 2 * node_num_cube(np);
        if (newlimit < tmplimit)
            newlimit= tmplimit;
    }
    if (limit > newlimit)
        limit = newlimit;
    for(i = 0; i < array_n(nodevec); i++) {
        np = array_fetch(node_t *, nodevec, i);
        if (node_function(np) == NODE_PI)
          continue;
        elimok = TRUE;
        if(node_value(np) <= thresh){
        if(!st_lookup(dont_elim, (char *)np, &dummy)){
            foreach_fanout(np, gen, fanout) {
                if(node_function(fanout) == NODE_PO){
                    elimok = FALSE;
                    (void)st_insert(dont_elim, (char *)np,
                    (char *)1);
                    (void)lsFinish(gen);
                    break;
                }
                if(clp_est(fanout, np) > limit){
                    elimok = FALSE;
                    (void)st_insert(dont_elim, (char *)np,
                    (char *)1);
                    (void)lsFinish(gen);
                    break;
                }
            }
    
            /*    if collapsing np into any fanout could 
                potentially cause the fanout cover to explode
                then will not eliminate `np'
                also, will not eliminate if `np' fans out to a
                primary output
            */
    
            if(elimok){
                foreach_fanout(np, gen, fanout) {
                        if (node_collapse(fanout, np)) {
                        eliminating = TRUE;
                        foreach_fanin(fanout, j, fanin){
                        (void)st_delete(dont_elim, 
                        (char **)&fanin, &dummy);
                        }
                        (void)st_delete(dont_elim,
                        (char **) &fanout, &dummy);
                        }
                }
            }
        }
        }
    }
    array_free(nodevec);
    }
    st_free_table(dont_elim);
}

/*    this rotuine returns a quick (and rough) estimate of the size
    of the cover of `fanout' if `np' were to be collapsed into
    it.
*/
    
static int 
clp_est(fanout, np)
node_t *fanout, *np;
{
    int cmp_size;

    switch(node_input_phase(fanout, np)){
        case PHASE_UNKNOWN:
            return node_num_cube(fanout);
        case NEG_UNATE:
        case BINATE:
            cmp_size = cmp_est((ft_t *)np->factored);
            break;
        default:
            /*    will not need the complement so cmp_size 
            doesn't matter.
            */
            cmp_size = 0;
            break;
    }

    return(cov_est(fanout, np, (ft_t *)fanout->factored, cmp_size));
}

/*    recursive routine that estimates the size of the cover 
    using the factored form. called from clp_est.
*/
    
static int 
cov_est(fanout, np, root, cmp_size)
node_t *fanout, *np;
ft_t *root;
int cmp_size;
{
    switch(root->type){
        case FACTOR_LEAF :
            return(cov_leaf_est(fanout, np, root, cmp_size));
        case FACTOR_INV :
            return(cov_inv_est(fanout, np, root, cmp_size));
        case FACTOR_AND :
            return(cov_and_est(fanout, np, root, cmp_size));
        case FACTOR_OR :
            return(cov_or_est(fanout, np, root, cmp_size));
        default:
            /*    shouldn't happen    */
            return 0;
    }
}

/*    quick estimate of the cover size of the complement of a node, 
    based on the factored form.
*/

static int
cmp_est(f)
ft_t *f;
{
    int cmp_size;
    ft_t *p;

    switch(f->type){
        case FACTOR_1:
            return 0;
        case FACTOR_0:
        case FACTOR_LEAF:
        case FACTOR_INV:
            return 1;
        case FACTOR_AND:
            cmp_size = 0;
            for(p = f->next_level; p != NIL(ft_t); p =
            p->same_level){
                cmp_size += cmp_est(p);
            }
            break;
        case FACTOR_OR:
            cmp_size = 1;
            for(p = f->next_level; p != NIL(ft_t); p =
            p->same_level){
                cmp_size *= cmp_est(p);
            }
            break;
        default:
        /*    shouldn't reach here    */
            cmp_size = -1;
            break;
    }

    return cmp_size;
}

static int
cov_inv_est(fanout, np, root, cmp_size)
node_t *fanout, *np;
ft_t *root;
int cmp_size;
{
    if(np == node_get_fanin(fanout, root->next_level->index)){
        return cmp_size;
    } else {
        return 1;
    }
}

/*ARGSUSED*/
static int
cov_leaf_est(fanout, np, root, cmp_size)
node_t *fanout, *np;
ft_t *root;
int cmp_size;
{
    if(np == node_get_fanin(fanout, root->index)){
        return node_num_cube(np);
    } else {
        return 1;
    }
}

static int 
cov_and_est(fanout, np, root, cmp_size)
node_t *fanout, *np;
ft_t *root;
int cmp_size;
{
    int cov_size, sub_cover;
    ft_t *p;

    cov_size = 1;
    for(p = root->next_level; p != NIL(ft_t); p = p->same_level){
        switch(p->type){
            case FACTOR_LEAF:
                sub_cover = cov_leaf_est(fanout, np, p,
                cmp_size);
                break;
            case FACTOR_INV:
                sub_cover = cov_inv_est(fanout, np, p, 
                cmp_size);
                break;
            case FACTOR_OR:
                sub_cover = cov_or_est(fanout, np, p, 
                cmp_size);
                break;
            case FACTOR_AND:
                sub_cover = cov_and_est(fanout, np, p, 
                cmp_size);
                break;
            default:
                sub_cover = 0;    /*    shouldn't happen */
        }
        cov_size *= sub_cover;
    }
    return cov_size;

}

static int 
cov_or_est(fanout, np, root, cmp_size)
node_t *fanout, *np;
ft_t *root;
int cmp_size;
{
    int cov_size, sub_cover;
    ft_t *p;

    cov_size = 0;
    for(p = root->next_level; p != NIL(ft_t); p = p->same_level){
        switch(p->type){
            case FACTOR_LEAF:
                sub_cover = cov_leaf_est(fanout, np, p,
                cmp_size);
                break;
            case FACTOR_INV:
                sub_cover = cov_inv_est(fanout, np, p, 
                cmp_size);
                break;
            case FACTOR_OR:
                sub_cover = cov_or_est(fanout, np, p, 
                cmp_size);
                break;
            case FACTOR_AND:
                sub_cover = cov_and_est(fanout, np, p, 
                cmp_size);
                break;
            default:
                sub_cover = 1;    /*    shouldn't happen */
        }
        cov_size += sub_cover;
    }
    return cov_size;
}

