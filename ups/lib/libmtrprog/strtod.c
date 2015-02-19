/* strtod.c - strtod, for machines that don't have it */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char utils_strtod_sccsid[] = "@(#)strtod.c	1.11 15/9/92 (UKC)";

#include <ifdefs.h>

#if HAVE_STRTOD
/* Have it. */
#else

#include <ctype.h>
#include <stdlib.h>
#include <local/ukcprog.h>

double
strtod(start, endp)
const char *start;
char **endp;
{
	double val;
	const char *s;
	
	val = atof(start);

	/* Now skip the characters that atof looked at.
	 */
	for (s = start; *s != '\0' && isspace(*s); ++s)
		;
	if (*s == '+' || *s == '-')
		++s;

	while (isdigit(*s))
		++s;
	if (*s == '.')
		++s;
	while (isdigit(*s))
		++s;
	
	if (*s == 'e' || *s == 'E')
		++s;
	while (isdigit(*s))
		++s;
	
	*endp = (char *)s;	/* ugh! */

	return val;
}

#endif /* ! HAVE_STRTOD */
