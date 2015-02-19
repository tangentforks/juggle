/* arg_version.c - version number routines for the arg library */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char arg_version_sccsid[] = "@(#)arg_version.c	1.6 16 Sep 1994 (UKC)";


#include <local/ukcprog.h>
#include "arg.h"
#include "sccsdata.h"

/*  Return the version number of the arg library.
 */
const char *
arg_version()
{
	return arg__sccsdata[0];
}
