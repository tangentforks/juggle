/* failmesg.c - produce error messages for system call failures */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char utils_failmesg_sccsid[] = "@(#)failmesg.c	1.2 9/4/95 (UKC)";

#include <ifdefs.h>
#include <local/ukcprog.h>

#include "utils.h"

void
failmesg(mesg, what, path)
const char *mesg, *what, *path;
{
	const char *errno_str;

	errno_str = get_errno_str();
	
	if (what == NULL || *what == '\0')
		errf("%s %s: %s", mesg, path, errno_str);
	else
		errf("%s %s %s: %s", mesg, what, path, errno_str);
}

const char *
get_errno_str()
{
	return (strerror (errno));
}

/* Create an 'strerror()' routine to work round a problem in libukcprog.a
   with GCC 2.8.1 on SunOS 4.1.1 */
#if !HAVE_STRERROR && defined(__STDC__)
#undef strerror
char *strerror(n)
int n;
{
	return (((n) >= 0 && (n) < sys_nerr) ? sys_errlist[n] : "unknown error");
}
#endif

