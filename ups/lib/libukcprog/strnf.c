/* strnf.c -- like sprintf, but with a buffer size argument */

/*  Copyright 1992  Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ukcprog_strnf_sccsid[] = "@(#)strnf.c	1.7 25/10/93 UKC";

#ifdef __STDC__
#include <stdarg.h>
#else
#include <varargs.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef __STDC__
#include <memory.h>
#endif

#include "ukcprog.h"


#ifdef __STDC__
void
strnf(char *buf, size_t bufsize, const char *fmt, ...)
{

#else /* !__STDC__ */
void
strnf(va_alist)
va_dcl
{
	char *buf;
	int bufsize;
	char *fmt;
#endif /* !__STDC__ */
	va_list args;
	char *s;

#ifdef __STDC__
	va_start(args, fmt);
#else
	va_start(args);
	buf = va_arg(args, char *);
	bufsize = va_arg(args, size_t);
	fmt = va_arg(args, char *);
#endif

	s = formf(buf, (int)bufsize, fmt, args);

	va_end(args);

	/*  If formf had to allocate a buffer then the supplied buf
	 *  was too small.  Copy what will fit and free the formf buffer.
	 */
	if (s != buf) {
		memcpy(buf, s, (size_t)(bufsize - 1));
		buf[bufsize - 1] = '\0';
		free(s);
	}
}
