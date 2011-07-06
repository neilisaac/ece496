/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.2/common/src/sis/astg/RCS/astg.h,v $
 * $Author: sis $
 * $Revision: 1.3 $
 * $Date: 1994/07/15 22:56:26 $
 *
 */
/* astg.h -- exported programming interface to ASTG package. */

#ifndef ASTG_H
#define ASTG_H

typedef char astg_t;

void	 init_astg ARGS(());
void	 end_astg ARGS(());
astg_t	*astg_dup ARGS((astg_t *));
void	 astg_free ARGS((astg_t *));

#endif /* ASTG_H */
