/* tops-native.c - ups using the native target driver for binaries */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ups_tops_native_c_sccsid[] = "@(#)tops-native.c	1.2 24 May 1995 (UKC)";

#include <mtrprog/ifdefs.h>
#include <local/ukcprog.h>

#include "ups.h"
#include "symtab.h"
#include "target.h"
#include "ao.h"		/* for Ao_ops */
#include "ao_ifdefs.h"
#include "xc.h"		/* for Xc_ops and Cc_ops */
#include "gd.h"		/* for Gd_ops */

xp_ops_t **
get_target_drivers()
{
	static xp_ops_t *drivers[] = {
		&Xc_ops,
		&Cc_ops,
#ifdef AO_TARGET
		&Ao_ops,
#endif
#ifdef GDB_TARGET
		&Gd_ops,
#endif
		NULL
	};

	return drivers;
}
