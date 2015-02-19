/* version.c - version number routine for the arg library */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char edit_version_sccsid[] = "@(#)version.c	1.1 6/8/94 (UKC)";

#include <local/ukcprog.h>

#include "edit.h"
#include "sccsdata.h"

/*  Return the version number of the arg library.
 */
const char *
edit_version()
{
	return edit__sccsdata[0];
}
