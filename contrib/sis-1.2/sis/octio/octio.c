/*
 * Revision Control Information
 *
 * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/octio/RCS/octio.c,v $
 * $Author: sis $
 * $Revision: 1.2 $
 * $Date: 1992/05/06 18:58:16 $
 *
 */
#ifdef OCT
#include "copyright.h"
#endif
#include "sis.h"
#include "octio.h"

/*
 *  called when the program starts up
 */
init_octio()
{
#ifdef OCT
    com_add_command("write_oct", external_write_oct, 0);
    com_add_command("read_oct", external_read_oct, 1);
#endif
}

/*
 *  called just before the program terminates
 */
end_octio()
{
}





