/* e_malloc() -- error checking malloc */

/*  Copyright 1992  Godfrey Paul, University of Kent at Canterbury.
 *  
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ukcprog_malloc_sccsid[] = "@(#)e_malloc.c	1.9 30/5/93 UKC";

#ifndef __STDC__
#include <sys/types.h>	/* for size_t */
#endif

#include <stdio.h>	/* for NULL */
#include <stdlib.h>

#include "ukcprog.h"


voidptr
e_malloc(size)
size_t size;
{
	char *ptr;

	if ((ptr = malloc(size)) == NULL)
		panic("malloc failed in e_malloc");

	return ptr;
}
