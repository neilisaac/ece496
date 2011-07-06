/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/octio/RCS/octio.h,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:58:16 $
 *
 */
#ifndef OCTIO_H
#define OCTIO_H

#define SIS_PKG_NAME "oct/sis"

EXTERN int external_read_oct  ARGS((network_t **,int,char**));
EXTERN int external_write_oct ARGS((network_t **,int,char**));

extern char *optProgName;
#endif
