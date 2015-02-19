/*  e_realloc() -- Error checking realloc. */

/*  Copyright 1992  Godfrey Paul, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ukcprog_realloc_sccsid[] = "@(#)e_realloc.c	1.8 30/5/93 UKC";

#ifndef __STDC__
#include <sys/types.h>	/* for size_t */
#endif

#include <stdio.h>	/* for NULL */
#include <stdlib.h>

#include "ukcprog.h"


voidptr
e_realloc(old, size)
voidptr old;
size_t size;
{
	char *new;

	if (old == NULL)
		return e_malloc(size);

	if (size == 0) {
		free(old);
		return NULL;
	}
		
	if ((new = realloc(old, (size_t)size)) == NULL)
		panic("realloc failed in e_realloc");

	return new;
}
