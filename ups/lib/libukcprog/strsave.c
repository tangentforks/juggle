/* strsave.c -- allocate memory and save a copy of a string */

/*  Copyright 1992  Godfrey Paul, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ukcprog_strsave_sccsid[] = "@(#)strsave.c	1.7 30/5/93 UKC";

#include <string.h>
#include <stdlib.h>	/* for malloc() */

#include "ukcprog.h"


char *
strsave(s)
const char *s;
{
	char *str;

	str = e_malloc(strlen(s) + 1);

	return strcpy(str, s);
}
