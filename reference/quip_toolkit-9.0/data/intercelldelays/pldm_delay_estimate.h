/*****************************************************************************
 *
 * Filename:    pldm_delay_estimate.h
 *
 * Copyright © 2002 Altera Corporation. All rights reserved.  Altera Proprietary.
 * Altera products and services are protected under numerous U.S. and foreign patents,
 * maskwork rights, copyrights and other intellectual property laws.  Altera assumes no
 * responsibility or liability arising out of the application or use of this information
 * and code. This notice must be retained and reprinted on any copies of this information
 * and code that are permitted to be made."
 *
 *****************************************************************************/

/*
 * $Header: //acds/rel/9.0/quartus/tsm/pldm/pldm_delay_estimate.h#1 $
 */

#ifdef __cplusplus
extern "C" {
#endif

/*****************************************************************************
 *
 * This interface provides an interface for 3rd party EDA vendors to access cell delays on Altera
 * devices.  Altera chip information must first be loaded from a file before
 * get_point_to_point_delay() can be called.  For example device EP1S10B672C7 would be
 * loaded by calling alloc_and_load_device_info("stratix.ref", "EP1S10", "7");.  Note that the
 * data file is package independent, but still depends on the speed grade.
 *
 * Memory usage is approximately 80K for a EP1S10 and 500K for a EP1S80.
 *
 * Load time for alloc_and_load_device_info() is approximately 10ms for a EP1S10 and 60ms
 * for a EP1S80.
 *
 * Access time for get_point_to_point_delay() is approximately 0ms for both a EP1S10 and
 * a EP1S80.
 *
 *****************************************************************************/

#ifndef INC_PLDM_DELAY_ESTIMATE_H
#define INC_PLDM_DELAY_ESTIMATE_H

/***************** Types and defines exported by this file *************/

#define PLDM_DELAY_ERROR (-1)

#define PLDM_TRUE (1)
#define PLDM_FALSE (0)

/******************* Subroutines exported by this file *****************/

/* Loads device info from file.  Returns true if successful and false if it cannot find or open
 * the device file.
 */
int alloc_and_load_device_info(const char *filename, const char *device, const char *speed);
/* Frees device info from memory. */
void free_device_info();

/* The dimensions returned are a strict upper bound on the coordinate system.  The
 * x-dimension ranges from [0, x - 1] and the y-dimension ranges from [0, y - 1].  These
 * coordinates are the same as the ones used in FLED.
 */

/* Gets device metrics for x coordinate. */
int get_x_dimension();
/* Gets device metrics for y coordinate. */
int get_y_dimension();

/* Gets device info version. */
const char *get_device_info_version();

/* Point to point delay between two points <x1,y1> and <x2,y2> in pico seconds.
 *
 * This is an optimistic estimate for block to block delays.  It takes into account the
 * following:
 *        1)  Local lines (ie. x1==x2 and y1==y2), but not quick feedback or lut cascade
 *        2)  Input and output buffers for all blocks
 *        3)  Nearest nieghbors
 *
 * It does not take into account the following, but it does provide an estimate of the delay to/from:
 *        1)  IOs, RAMS and DSPs (to or from)
 *
 * Delays given are optimistic estimates of the route.  The following are reasons why they
 * may inaccurate:
 *        1)  Non-linear effects in final timing signoff
 *        2)  Router selects slower route for non-critical signal
 *        3)  Congestion
 *        4)  RAMs and DSPs are different from LABs
 *        5)  Assumes regular routing, wrong for global routes such as clocks and ACLR
 *
 * Lastly, to expand on point 3 under inaccuracies, the reason why this delay  is optimistic
 * is that it may differ from the final delay seen by Quartus delay annotator since it is only
 * a worst case placement delay.  There is no way of knowing which lines/wires the router
 * will take to make a successful fit especially in times of congestion.
 *
 * Returns delay if successful and PLDM_DELAY_ERROR if any of the following
 * should occur:
 *        1)  Device coordinates do not belong to chip (ie. negative or greater than dimensions)
 *
 * It is also the callers responsibility to check if the points in question are valid (ie. corner of chip,
 * inside a MRAM or DSP, etc.)
 */
int get_point_to_point_delay(int x1, int y1, int x2, int y2);

#endif  /* INC_PLDM_DELAY_ESTIMATE_H */

#ifdef __cplusplus
}
#endif

