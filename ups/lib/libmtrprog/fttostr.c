/* filetype_to_string.c - convert a file mode to an ls type string */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char utils_filetype_to_string_sccsid[] = "@(#)fttostr.c	1.5 17 Apr 1994 (UKC)";

#define UKC_WANT_COMMON_UNIX_EXTENSIONS

#include <sys/types.h>
#include <sys/stat.h>

#include <stdio.h>
#include <local/ukcprog.h>

#include "utils.h"

const char *
filetype_to_string(mode)
int mode;
{
	static char buf[100];

	if (S_ISREG(mode))
		return "regular file";
	if (S_ISDIR(mode))
		return "directory";
	if (S_ISCHR(mode))
		return "character special file";
	if (S_ISBLK(mode))
		return "block special file";
	if (S_ISFIFO(mode))
		return "named pipe";
#ifdef S_ISSOCK
	if (S_ISSOCK(mode))
		return "socket";
#endif
#ifdef S_ISLNK
	if (S_ISLNK(mode))
		return "symbolic link";
#endif
	
	sprintf(buf, "file with unknown mode 0%o", mode);
	return buf;
}
