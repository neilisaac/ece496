/*****************************************************************************
 *
 * Filename:    pldm_delay_estimate.c
 *
 * Description: Interface for 3rd party EDA vendors to access placer delay matrix information
 * on Altera devices.  Please see pldm_delay_estimate.h for more information.
 *
 * Copyright © 2002 Altera Corporation. All rights reserved.  Altera Proprietary.
 * Altera products and services are protected under numerous U.S. and foreign patents,
 * maskwork rights, copyrights and other intellectual property laws.  Altera assumes no
 * responsibility or liability arising out of the application or use of this information
 * and code. This notice must be retained and reprinted on any copies of this information
 * and code that are permitted to be made."
 *
 *****************************************************************************/

#ifndef GCC_PEDANTIC_WARNINGS
static char *Version = "$Header: //acds/rel/9.0/quartus/tsm/pldm/pldm_delay_estimate.c#1 $";
#endif

#include <stdio.h>
#include <string.h>

#include "pldm_delay_estimate.h"
#if PLDM_USE_QUARTUS_MEMORY_ALLOCATION
#include "pldm_qi_mem_interface.h"
#define l_malloc(X) pldm_qi_mem_malloc(X)
#define l_free(X) pldm_qi_mem_free(X)
#else
#include <stdlib.h>
#define l_malloc(X) malloc(X)
#define l_free(X) free(X)
#endif

/****************** Types and defines local to this module *******************/

typedef enum {
   CACHED_DELAY_LAB_LINE = 0, 
   CACHED_DELAY_LE_BUFFER, 
   CACHED_DELAY_TSUNAMI_SUPER_SNEAK, 
   CACHED_DELAY_IO_DATA_OUT,
   NUM_CACHED_DELAY_TYPES
} e_aa_delay_cache_delay_types;


typedef enum {
   XYMAP_DELAY_LAB_LINE = 0,
   XYMAP_DELAY_OUTPUT_BUFFER,
   XYMAP_DELAY_LOCAL_LINE,
   NUM_DELAYS_WITH_XY_MAP
} e_aa_delay_cache_xymap_delay;

typedef enum {
   END_POINT_DEFAULT = 0,
   END_POINT_VIO,
   END_POINT_HIO,
   NUM_END_POINTS
} e_aa_delay_cache_characteristic_end_points;

#define PHYS_LOC_IO_IS_INPUT_ONLY		0x00000001
#define PHYS_LOC_IO_IS_CLOCK_PAD		0x00000002
#define PHYS_LOC_INTERFACE_LIKE_HIO	0x00000004
#define PHYS_LOC_INTERFACE_LIKE_VIO	0x00000008

#define PLDM_SUPPORTED_VERSION (4.0)

#define PLDM_MAX_DIMENSION (256)
#define PLDM_BUFFER_LENGTH (512)

/********************* Variables local to this module ************************/

static int g_nx = 0;
static int g_ny = 0;

static char *g_delay_cache_version = NULL;
static char *g_arch_type = NULL;
static char *g_sub_arch_type = NULL;

/* Have all of the cached delay values been loaded ? */
static int g_cache_is_loaded = PLDM_FALSE;

/* A set of flag bits that give extra information about this (x, y, sublocation).
 * [0..m_nx-1][0..m_ny-1]
 */
static int **g_phys_loc_flags0 = NULL;

/* The worst case net delay involved in travelling a distance (dx, dy)
 * [0..NUM_END_POINTS -1][0..NUM_END_POINTS-1][0..m_nx-1][0..m_ny-1]
 */
static int ****g_cache_wire_delay = NULL;

/* The precise wire delays for each wire type at each (x, y) position.
 * [0 .. NUM_DELAYS_WITH_XY_MAP - 1][0 .. nx - 1][0 .. ny - 1]
 */
static int ***g_cache_xymap_of_wire_delays = NULL;

/* The precise average wire delays for each wire type. The average is computed over
 * full length wires of each type.
 * [0 .. NUM_CACHED_DELAY_TYPES - 1]
 */
static int *g_cache_precise_average_wire_delays = NULL;

/* The precise switch delays between the first wire type and the second wire type.
 * [0 .. NUM_CACHED_DELAY_TYPES - 1][0 .. NUM_CACHED_DELAY_TYPES - 1]
 */
static int **g_cache_precise_switch_delays = NULL;

/********************* Local Subroutine Declarations *************************/

static char *l_fgets(char *string, int n, FILE *stream);

static void *l_malloc_array(int nxmin, int nxmax, size_t el_size);
static void l_free_array(void *vptr, int nxmin, size_t el_size);
static void **l_malloc_matrix(int nxmin, int nxmax, int nymin, int nymax, size_t el_size);
static void l_free_matrix(void *vptr, int nxmin, int nxmax, int nymin, size_t el_size);
static void ***l_malloc_matrix3(int nxmin, int nxmax, int nymin, int nymax, int nzmin, int nzmax, size_t el_size);
static void l_free_matrix3(void *vptr, int nxmin, int nxmax, int nymin, int nymax, int nzmin, size_t el_size);
static void ****l_malloc_matrix4(int nwmin, int nwmax, int nxmin, int nxmax, int nymin, int nymax, int nzmin, int nzmax, size_t el_size);
static void l_free_matrix4(void *vptr, int nwmin, int nwmax, int nxmin, int nxmax, int nymin, int nymax, int nzmin, size_t el_size);

static int l_load_int(FILE *fp, int *ptr);
static int l_load_int_array(FILE *fp, int *iptr, int nxmin, int nxmax);
static int l_load_int_matrix(FILE *fp, int **iptr, int nxmin, int nxmax, int nymin, int nymax);
static int l_load_int_matrix3(FILE *fp, int ***iptr, int nxmin, int nxmax, int nymin, int nymax, int nzmin, int nzmax);
static int l_load_int_matrix4(FILE *fp, int ****iptr, int nwmin, int nwmax, int nxmin, int nxmax, int nymin, int nymax, int nzmin, int nzmax);
#if 0
static int l_load_float_matrix(FILE *fp, float **fptr, int nxmin, int nxmax, int nymin, int nymax);
static int l_load_float_matrix3(FILE *fp, float ***fptr, int nxmin, int nxmax, int nymin, int nymax, int nzmin, int nzmax);
static int l_load_float_matrix4(FILE *fp, float ****fptr, int nwmin, int nwmax, int nxmin, int nxmax, int nymin, int nymax, int nzmin, int nzmax);
#endif

static int l_estimate_point_to_point_delay_without_obstacles(int isrc_x, int isrc_y, int idst_x, int idst_y);

/************************ Global Subroutine Definitions **********************/


int alloc_and_load_device_info(const char *filename, const char *device, const char *speed)
{
	/* Sets up all delay cache variables from a file.  For an example of a REF
	 * file, please look in eda_toolkit.tar.gz, specifically stratix.ref.  Returns
	 * PLDM_TRUE for SUCCESS/PLDM_FALSE for ERROR.
	 */

	int ilength, iresult;
	float fversion;
	char *ctemp, *cdevice;
	FILE *fp;

	if (filename == NULL || device == NULL || speed == NULL)
	{
		return PLDM_FALSE;
	}

	fp = fopen(filename, "r");

	if (fp == NULL)
	{
		return PLDM_FALSE;
	}

	if (g_cache_is_loaded == PLDM_TRUE)
	{
		free_device_info();
	}

	ctemp = (char *)l_malloc_array(0, PLDM_BUFFER_LENGTH, sizeof(char));

	l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

	ilength = (int)strlen(ctemp) - 1;
	g_delay_cache_version = (char *)l_malloc_array(0, ilength + 1, sizeof(char));
	strcpy(g_delay_cache_version, &ctemp[1]);

	l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

	fversion = 0.0f;

	sscanf(ctemp, "#Version %f", &fversion);

	/* Check version compability */
	if (fversion < PLDM_SUPPORTED_VERSION)
	{
		l_free_array(ctemp, 0, sizeof(char));
		free_device_info();
		return PLDM_FALSE;
	}

	/* #<device>-<speed> */
	ilength = (int)strlen(device) + (int)strlen(speed) + 2;
	cdevice = (char *)l_malloc_array(0, ilength + 1, sizeof(char));

	sprintf(cdevice, "#%s-%s", device, speed);

	l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

	/* Loop through devices to find correct device */
	while (strcmp(cdevice, ctemp) != 0)
	{
		if (l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp) == NULL)
		{
			l_free_array(cdevice, 0, sizeof(char));
			l_free_array(ctemp, 0, sizeof(char));
			free_device_info();
			return PLDM_FALSE;
		}
	}

	l_free_array(cdevice, 0, sizeof(char));

	iresult = PLDM_TRUE;

	/* Start loading device info */
	if (iresult)
	{
		l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

		if (strcmp("arch_type", ctemp) != 0)
		{
			iresult = PLDM_FALSE;
		}
	}

	if (iresult)
	{
		l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

		ilength = (int)strlen(ctemp);
		g_arch_type = (char *)l_malloc_array(0, ilength + 1, sizeof(char));
		strcpy(g_arch_type, ctemp);
	}

	if (iresult)
	{
		l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

		if (strcmp("sub_arch_type", ctemp) != 0)
		{
			iresult = PLDM_FALSE;
		}
	}

	if (iresult)
	{
		l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

		ilength = (int)strlen(ctemp);
		g_sub_arch_type = (char *)l_malloc_array(0, ilength + 1, sizeof(char));
		strcpy(g_sub_arch_type, ctemp);
	}

	if (iresult)
	{
		l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

		if (strcmp("nx", ctemp) != 0)
		{
			iresult = PLDM_FALSE;
		}
	}

	if (iresult)
	{
		iresult = l_load_int(fp, &g_nx);

		if (iresult && (g_nx < 0 || g_nx > PLDM_MAX_DIMENSION))
		{
			iresult = PLDM_FALSE;
		}
	}

	if (iresult)
	{
		l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

		if (strcmp("ny", ctemp) != 0)
		{
			iresult = PLDM_FALSE;
		}
	}

	if (iresult)
	{
		iresult = l_load_int(fp, &g_ny);

		if (iresult && (g_ny < 0 || g_ny > PLDM_MAX_DIMENSION))
		{
			iresult = PLDM_FALSE;
		}
	}

	if (iresult)
	{
		l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

		if (strcmp("phys_loc", ctemp) != 0)
		{
			iresult = PLDM_FALSE;
		}
	}

	if (iresult)
	{
		g_phys_loc_flags0 = (int **)l_malloc_matrix(
			0, g_nx - 1, 0, g_ny - 1, sizeof(int));
		iresult = l_load_int_matrix(fp, g_phys_loc_flags0,
			0, g_nx - 1, 0, g_ny - 1);

	}

	if (iresult)
	{
		l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

		if (strcmp("cache_wire_delay", ctemp) != 0)
		{
			iresult = PLDM_FALSE;
		}
	}

	if (iresult)
	{
		g_cache_wire_delay = (int ****)l_malloc_matrix4(
			0, NUM_END_POINTS - 1,
			0, NUM_END_POINTS - 1,
			0, g_nx - 1, 0, g_ny - 1, sizeof(float));
		iresult = l_load_int_matrix4(fp, g_cache_wire_delay,
			0, NUM_END_POINTS - 1,
			0, NUM_END_POINTS - 1,
			0, g_nx - 1, 0, g_ny - 1);
	}

	if (iresult)
	{
		l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

		if (strcmp("cache_xymap_of_wire_delays", ctemp) != 0)
		{
			iresult = PLDM_FALSE;
		}
	}

	if (iresult)
	{
		g_cache_xymap_of_wire_delays = (int ***)l_malloc_matrix3(
			0, NUM_DELAYS_WITH_XY_MAP - 1,
			0, g_nx - 1, 0, g_ny - 1, sizeof(int));
		iresult = l_load_int_matrix3(fp, g_cache_xymap_of_wire_delays,
			0, NUM_DELAYS_WITH_XY_MAP - 1,
			0, g_nx - 1, 0, g_ny - 1);
	}

	if (iresult)
	{
		l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

		if (strcmp("cache_precise_average_wire_delays", ctemp) != 0)
		{
			iresult = PLDM_FALSE;
		}
	}

	if (iresult)
	{
		g_cache_precise_average_wire_delays = (int *)l_malloc_array(
			0, NUM_CACHED_DELAY_TYPES - 1,
			sizeof(int));
		iresult = l_load_int_array(fp, g_cache_precise_average_wire_delays,
			0, NUM_CACHED_DELAY_TYPES - 1);
	}

	if (iresult)
	{
		l_fgets(ctemp, PLDM_BUFFER_LENGTH, fp);

		if (strcmp("cache_precise_switch_delays", ctemp) != 0)
		{
			iresult = PLDM_FALSE;
		}
	}

	if (iresult)
	{
		g_cache_precise_switch_delays = (int **)l_malloc_matrix(
			0, NUM_CACHED_DELAY_TYPES - 1,
			0, NUM_CACHED_DELAY_TYPES - 1,
			sizeof(int));
		iresult = l_load_int_matrix(fp, g_cache_precise_switch_delays,
			0, NUM_CACHED_DELAY_TYPES - 1,
			0, NUM_CACHED_DELAY_TYPES - 1);
	}

	l_free_array(ctemp, 0, sizeof(char));

	fclose(fp);

	if (iresult)
	{
		g_cache_is_loaded = PLDM_TRUE;
	}
	else
	{
		g_cache_is_loaded = PLDM_FALSE;
	}

	return g_cache_is_loaded;
}


void free_device_info()
{
	/* Frees memory of all the local data structures. */

	if (g_cache_is_loaded == PLDM_TRUE)
	{
		/* Free the delay cache. */

		l_free_array(g_delay_cache_version, 0, sizeof(char));
		g_delay_cache_version = NULL;
		l_free_array(g_arch_type, 0, sizeof(char));
		g_arch_type = NULL;
		l_free_array(g_sub_arch_type, 0, sizeof(char));
		g_sub_arch_type = NULL;

		l_free_matrix(g_phys_loc_flags0,
			0, g_nx - 1,
			0, sizeof(int));
		g_phys_loc_flags0 = NULL;

		l_free_matrix4(g_cache_wire_delay,
			0, NUM_END_POINTS - 1,
			0, NUM_END_POINTS - 1,
			0, g_nx - 1,
			0, sizeof(int));
		g_cache_wire_delay = NULL;

		l_free_matrix3(g_cache_xymap_of_wire_delays,
			0, NUM_DELAYS_WITH_XY_MAP - 1,
			0, g_nx - 1,
			0, sizeof(int));
		g_cache_xymap_of_wire_delays = NULL;

		l_free_array(g_cache_precise_average_wire_delays, 0, sizeof(int));
		g_cache_precise_average_wire_delays = NULL;

		l_free_matrix(g_cache_precise_switch_delays,
			0, NUM_CACHED_DELAY_TYPES - 1,
			0, sizeof(int));
		g_cache_precise_switch_delays = NULL;

		g_nx = 0;
		g_ny = 0;

		g_cache_is_loaded = PLDM_FALSE;
	}
}


int get_x_dimension()
{
	/* Gets device metrics for x coordinate. */

	if (g_cache_is_loaded == PLDM_TRUE)
		return g_nx;
	else
		return 0;
}


int get_y_dimension()
{
	/* Gets device metrics for y coordinate. */

	if (g_cache_is_loaded == PLDM_TRUE)
		return g_ny;
	else
		return 0;
}


const char *get_device_info_version()
{
	/* Get device info version string. */

	if (g_cache_is_loaded == PLDM_TRUE)
		return g_delay_cache_version;
	else
		return NULL;
}


int get_point_to_point_delay(int x1, int y1, int x2, int y2)
{
	/* Point to point delay between two points <x1,y1> and <x2,y2>.
	 *
	 * This is *the* delay estimator for placement.  Given 2 points in
	 * coordinates, return delay (in pico sec) between them.
	 *
	 * The estimator assumes a worst case delay between the two points.
	 */

	int result = PLDM_DELAY_ERROR;

	if (g_cache_is_loaded == PLDM_TRUE)
	{
		if (x1 < 0 || x1 >= g_nx || y1 < 0 || y1 >= g_ny ||
			x2 < 0 || x2 >= g_nx || y2 < 0 || y2 >= g_ny)
		{
			return result;
		}

		result = l_estimate_point_to_point_delay_without_obstacles(x1, y1, x2, y2);
	}

	return result;
}


/************************ Local Subroutine Definitions ***********************/


static char *l_fgets(char *string, int n, FILE *stream)
{
	/* Same as fgets, but removes annoying CR's and LF's. */

	char *c;

	if (fgets(string, n, stream) == NULL)
		return NULL;

	/* Remove any CR's */
	c = strrchr(string, '\015');

	if (c != NULL)
	{
		*c = '\000';
	}
	else
	{
		/* Remove any LF's */
		c = strrchr(string, '\012');

		if (c != NULL)
		{
			*c = '\000';
		}
	}

	/* String is EOL, try again. */
	if ((strlen(string) == 0) || (strcmp(string, " ") == 0))
	{
		l_fgets(string, n, stream);
	}

	return string;
}


static void *l_malloc_array(int nxmin, int nxmax, size_t el_size)
{
	/* Allocates an array with nxmax - nxmin + 1 elements, with each element
	 * of size el_size.  i.e. returns a pointer to a storage block [nxmin..nxmax].
	 * Simply cast the returned array pointer to the proper type.
	 */

	char *cptr;

	cptr = (char *)l_malloc((nxmax - nxmin + 1) * el_size);

	cptr -= nxmin * el_size / sizeof(char);

	return (void *)cptr;
}


static void l_free_array(void *vptr, int nxmin, size_t el_size)
{
	/* Frees array created by l_malloc_array(). */

	char *cptr;

	if (vptr == NULL)
	{
		return;
	}

	cptr = (char *)vptr;

	cptr += nxmin * el_size / sizeof(char);

	l_free(cptr);
}


static void **l_malloc_matrix(int nxmin, int nxmax, int nymin, int nymax, size_t el_size)
{
	/* Allocates a matrix with nxmax - nxmin + 1 rows and nymax - nymin
	 * + 1 columns, with each element of size el_size. i.e. returns a pointer to
	 * a storage block [nxmin..nxmax][nymin..nymax].  Simply cast the returned
	 * array pointer to the proper type.
	 */

	int i;
	char **cptr;

	cptr = (char **)l_malloc((nxmax - nxmin + 1) * sizeof(char *));

	cptr -= nxmin;

	for (i = nxmin; i <= nxmax; ++i)
	{
		cptr[i] = (char *)l_malloc((nymax - nymin + 1) * el_size);

		cptr[i] -= nymin * el_size / sizeof(char);
	}

	return (void **)cptr;
}


static void l_free_matrix(void *vptr, int nxmin, int nxmax, int nymin, size_t el_size)
{
	/* Frees matrix created by l_malloc_matrix(). */

	int i;
	char **cptr;

	if (vptr == NULL)
	{
		return;
	}

	cptr = (char **)vptr;

	for (i = nxmin; i <= nxmax; ++i)
	{
		cptr[i] += nymin * el_size / sizeof(char);

		l_free(cptr[i]);
	}

	cptr += nxmin;

	l_free(cptr);
}


static void ***l_malloc_matrix3(
	int nxmin, int nxmax, int nymin, int nymax, int nzmin, int nzmax, size_t el_size)
{
	/* Allocates a 3D generic matrix with nxmax - nxmin + 1 rows, nymax -
	 * ncmin + 1 columns, and a depth of nzmax - nzmin + 1, with each element
	 * of size el_size. i.e. returns a pointer to a storage block [nxmin..nxmax]
	 * [nymin..nymax][nzmin..nzmax].  Simply cast the returned array pointer
	 * to the proper type.
	 */

	int i, j;
	char ***cptr;

	cptr = (char ***)l_malloc((nxmax - nxmin + 1) * sizeof(char **));

	cptr -= nxmin;

	for (i = nxmin; i <= nxmax; i++)
	{
		cptr[i] = (char **)l_malloc((nymax - nymin + 1) * sizeof(char *));

		cptr[i] -= nymin;

		for (j = nymin; j <= nymax; j++)
		{
			cptr[i][j] = (char *)l_malloc((nzmax - nzmin + 1) * el_size);

			cptr[i][j] -= nzmin * el_size / sizeof(char);
		}
	}

	return (void ***)cptr;
}


static void l_free_matrix3(void *vptr,
	int nxmin, int nxmax, int nymin, int nymax, int nzmin, size_t el_size)
{
	/* Frees 3D matrix created by l_malloc_matrix3(). */

	int i, j;
	char ***cptr;

	if (vptr == NULL) {
		return;
	}

	cptr = (char ***)vptr;

	for (i = nxmin; i <= nxmax; i++)
	{
		for (j = nymin; j <= nymax; j++)
		{
			cptr[i][j] += nzmin * el_size / sizeof (char);

			l_free(cptr[i][j]);
		}

		cptr[i] += nymin;

		l_free(cptr[i]);
	}

	cptr += nxmin;

	l_free(cptr);
}


static void ****l_malloc_matrix4(
	int nwmin, int nwmax, int nxmin, int nxmax, int nymin, int nymax, int nzmin, int nzmax, size_t el_size)
{
	/* Allocates a 4D generic matrix with nwmax - nwmin + 1, nxmax - nxmin + 1
	 * rows, nymax - ncmin + 1 columns, and a depth of nzmax - nzmin + 1, with
	 * each element of size el_size. i.e. returns a pointer to a storage block
	 * [nwmin..nwmax][nxmin..nxmax][nymin..nymax][nzmin..nzmax].  Simply cast
	 * the returned array pointer to the proper type.
	 */

	int i, j, k;
	char ****cptr;

	cptr = (char ****)l_malloc((nwmax - nwmin + 1) * sizeof(char ***));

	cptr -= nwmin;

	for (i = nwmin; i <= nwmax; i++)
	{
		cptr[i] = (char ***)l_malloc((nxmax - nxmin + 1) * sizeof(char **));

		cptr[i] -= nxmin;

		for (j = nxmin; j <= nxmax; j++)
		{
			cptr[i][j] = (char **)l_malloc((nymax - nymin + 1) * sizeof(char *));

			cptr[i][j] -= nymin;

			for (k = nymin; k <= nymax; k++)
			{
				cptr[i][j][k] = (char *)l_malloc((nzmax - nzmin + 1) * el_size);

				cptr[i][j][k] -= nzmin * el_size / sizeof(char);
			}
		}
	}

	return (void ****)cptr;
}


static void l_free_matrix4(void *vptr,
	int nwmin, int nwmax, int nxmin, int nxmax, int nymin, int nymax, int nzmin, size_t el_size)
{
	/* Frees 4D matrix created by l_malloc_matrix4(). */

	int i, j, k;
	char ****cptr;

	if (vptr == NULL) {
		return;
	}

	cptr = (char ****)vptr;

	for (i = nwmin; i <= nwmax; i++)
	{
		for (j = nxmin; j <= nxmax; j++)
		{
			for (k = nymin; k <= nymax; k++)
			{
				cptr[i][j][k] += nzmin * el_size / sizeof (char);

				l_free(cptr[i][j][k]);
			}

			cptr[i][j] += nymin;

			l_free(cptr[i][j]);
		}

		cptr[i] += nxmin;

		l_free(cptr[i]);
	}

	cptr += nwmin;

	l_free(cptr);
}


static int l_load_int(FILE *fp, int *iptr)
{
	/* Reads an integer from the file stream. */

	int itemp;

	if (fscanf(fp, "%d", &itemp) != 1)
	{
		return PLDM_FALSE;
	}
	*iptr = itemp;

	return PLDM_TRUE;
}


static int l_load_int_array(FILE *fp, int *iptr, int nxmin, int nxmax)
{
	/* Reads an integer array from the file stream. */

	int idx, itemp;

	for (idx = nxmin; idx <= nxmax; ++idx)
	{
		if (fscanf(fp, "%d", &itemp) != 1)
		{
			return PLDM_FALSE;
		}
		iptr[idx] = itemp;
	}

	return PLDM_TRUE;
}


static int l_load_int_matrix(FILE *fp, int **iptr, int nxmin, int nxmax, int nymin, int nymax)
{
	/* Reads an integer matrix from the file stream. */

	int idx, idy;
	int itemp;

	for (idy = nymax; idy >= nymin; --idy)
	{
		for (idx = nxmin; idx <= nxmax; ++idx)
		{
			if (fscanf(fp, "%d", &itemp) != 1)
			{
				return PLDM_FALSE;
			}
			iptr[idx][idy] = itemp;
		}
	}

	return PLDM_TRUE;
}


static int l_load_int_matrix3(FILE *fp, int ***iptr,
	int nimin, int nimax, int nxmin, int nxmax, int nymin, int nymax)
{
	/* Reads a 3D integer matrix from the file stream. */

	int idi, idx, idy, itemp;

	for (idi = nimin; idi <= nimax; ++idi)
	{
		for (idy = nymax; idy >= nymin; --idy)
		{
			for (idx = nxmin; idx <= nxmax; ++idx)
			{
				if (fscanf(fp, "%d ", &itemp) != 1)
				{
					return PLDM_FALSE;
				}
				iptr[idi][idx][idy] = itemp;
			}
		}
	}

	return PLDM_TRUE;
}


static int l_load_int_matrix4(FILE *fp, int ****iptr,
	int nimin, int nimax, int njmin, int njmax, int nxmin, int nxmax, int nymin, int nymax)
{
	/* Reads a 4D integer matrix from the file stream. */

	int idi, idj, idx, idy, itemp;

	for (idi = nimin; idi <= nimax; ++idi)
	{
		for (idj = njmin; idj <= njmax; ++idj)
		{
			for (idy = nymax; idy >= nymin; --idy)
			{
				for (idx = nxmin; idx <= nxmax; ++idx)
				{
					if (fscanf(fp, "%d ", &itemp) != 1)
					{
						return PLDM_FALSE;
					}
					iptr[idi][idj][idx][idy] = itemp;
				}
			}
		}
	}

	return PLDM_TRUE;
}


#if 0
static int l_load_float_matrix(FILE *fp, float **fptr, int nxmin, int nxmax, int nymin, int nymax)
{
	/* Reads a float matrix from the file stream. */

	int idx, idy;
	float ftemp;

	for (idy = nymax; idy >= nymin; --idy)
	{
		for (idx = nxmin; idx <= nxmax; ++idx)
		{
			if (fscanf(fp, "%f", &ftemp) != 1)
			{
				return PLDM_FALSE;
			}
			fptr[idx][idy] = ftemp;
		}
	}

	return PLDM_TRUE;
}


static int l_load_float_matrix3(FILE *fp, float ***fptr,
	int nimin, int nimax, int nxmin, int nxmax, int nymin, int nymax)
{
	/* Reads a 3D float matrix from the file stream. */

	int idi, idx, idy;
	float ftemp;

	for (idi = nimin; idi <= nimax; ++idi)
	{
		for (idy = nymax; idy >= nymin; --idy)
		{
			for (idx = nxmin; idx <= nxmax; ++idx)
			{
				if (fscanf(fp, "%f ", &ftemp) != 1)
				{
					return PLDM_FALSE;
				}
				fptr[idi][idx][idy] = ftemp;
			}
		}
	}

	return PLDM_TRUE;
}


static int l_load_float_matrix4(FILE *fp, float ****fptr,
	int nimin, int nimax, int njmin, int njmax, int nxmin, int nxmax, int nymin, int nymax)
{
	/* Reads a 4D float matrix from the file stream. */

	int idi, idj, idx, idy;
	float ftemp;

	for (idi = nimin; idi <= nimax; ++idi)
	{
		for (idj = njmin; idj <= njmax; ++idj)
		{
			for (idy = nymax; idy >= nymin; --idy)
			{
				for (idx = nxmin; idx <= nxmax; ++idx)
				{
					if (fscanf(fp, "%f ", &ftemp) != 1)
					{
						return PLDM_FALSE;
					}
					fptr[idi][idj][idx][idy] = ftemp;
				}
			}
		}
	}

	return PLDM_TRUE;
}
#endif


static int l_estimate_point_to_point_delay_without_obstacles(
	int isrc_x, int isrc_y, int idst_x, int idst_y)
{
	/* Return the expected connection delay between source and destination.
	 * Ignore any obstacles, and assume you can go straight there.
	 */

	int idx, idy;
	int isrc_end_point, idst_end_point;

	idx = idst_x - isrc_x;
	if (idx < 0)
	{
		idx = -idx;
	}

	idy = idst_y - isrc_y;
	if (idy < 0)
	{
		idy = -idy;
	}

	/* All of the blocks at an (x, y) location have the same INTERFACE flags,
	* so we can just look at sub_location 0.
	*/
	isrc_end_point = END_POINT_DEFAULT;

	if (g_phys_loc_flags0[isrc_x][isrc_y] & PHYS_LOC_INTERFACE_LIKE_VIO) {
		isrc_end_point = END_POINT_VIO;
	} else if (g_phys_loc_flags0[isrc_x][isrc_y] & PHYS_LOC_INTERFACE_LIKE_HIO) {
		isrc_end_point = END_POINT_HIO;
	}

	idst_end_point = END_POINT_DEFAULT;

	if (g_phys_loc_flags0[idst_x][idst_y] & PHYS_LOC_INTERFACE_LIKE_VIO) {
		idst_end_point = END_POINT_VIO;
	} else if (g_phys_loc_flags0[idst_x][idst_y] & PHYS_LOC_INTERFACE_LIKE_HIO) {
		idst_end_point = END_POINT_HIO;
	}

	/* Source and dest in the same LAB ? */
	if (idx == 0 && idy == 0 && isrc_end_point == END_POINT_DEFAULT && idst_end_point == END_POINT_DEFAULT)
	{
		return (g_cache_xymap_of_wire_delays[XYMAP_DELAY_LOCAL_LINE][idst_x][idst_y]);
	}

	/* Tsunami super sneak connection between a LAB and adjacent IO ? */
	if ((strcmp(g_arch_type, "Stratix") == 0) && (strcmp(g_sub_arch_type, "MAX II") == 0))
	{
		if(isrc_end_point == END_POINT_DEFAULT
			&& ((idst_end_point == END_POINT_HIO && idy == 0 && idx == 1)
			|| (idst_end_point == END_POINT_VIO && idx == 0 && idy == 1)))
		{
			return (g_cache_precise_average_wire_delays[CACHED_DELAY_TSUNAMI_SUPER_SNEAK]
				+ g_cache_xymap_of_wire_delays[XYMAP_DELAY_OUTPUT_BUFFER][isrc_x][isrc_y]);
		}
	}

	/* Sneak connection between adjacent LABs or HIOs ? */
	if (idx == 1 && idy == 0)
	{
		return (g_cache_xymap_of_wire_delays[XYMAP_DELAY_LAB_LINE][idst_x][idst_y]
			+ g_cache_precise_switch_delays[CACHED_DELAY_LE_BUFFER][CACHED_DELAY_LAB_LINE]
			+ g_cache_xymap_of_wire_delays[XYMAP_DELAY_OUTPUT_BUFFER][isrc_x][isrc_y]);
	}

	/* Normal case.  Any switch delays are already included in
	 * Cache_wire_delay.
	 */
      return(g_cache_wire_delay[isrc_end_point][idst_end_point][idx][idy]
      		+ g_cache_xymap_of_wire_delays[XYMAP_DELAY_LAB_LINE][idst_x][idst_y]
      		+ g_cache_xymap_of_wire_delays[XYMAP_DELAY_OUTPUT_BUFFER][isrc_x][isrc_y]);
}
