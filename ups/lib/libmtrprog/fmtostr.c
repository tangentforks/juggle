/* filemode_to_string.c - convert a file mode to an ls type string */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char utils_filemode_to_string_sccsid[] = "@(#)fmtostr.c	1.6 30 May 1994 (UKC)";

/*  Want S_ISLNK(), S_ISSOCK() and S_ISVTX
 */
#define UKC_WANT_COMMON_UNIX_EXTENSIONS 1

#include <sys/types.h>
#include <sys/stat.h>

#include <local/ukcprog.h>

#include "utils.h"

const char *
filemode_to_string(mode)
int mode;
{
#define OWNER	1
#define GROUP	4
#define OTHER	7
#define RPERM	0
#define WPERM	1
#define XPERM	2
#define ANYEXEC	(S_IXUSR | S_IXGRP | S_IXOTH)
	static char perms[10];
	int tch;

	perms[OWNER + RPERM] = (mode & S_IRUSR) ? 'r' : '-';
	perms[OWNER + WPERM] = (mode & S_IWUSR) ? 'w' : '-';
	perms[OWNER + XPERM] = (mode & S_IXUSR) ? 'x' : '-';
	perms[GROUP + RPERM] = (mode & S_IRGRP) ? 'r' : '-';
	perms[GROUP + WPERM] = (mode & S_IWGRP) ? 'w' : '-';
	perms[GROUP + XPERM] = (mode & S_IXGRP) ? 'x' : '-';
	perms[OTHER + RPERM] = (mode & S_IROTH) ? 'r' : '-';
	perms[OTHER + WPERM] = (mode & S_IWOTH) ? 'w' : '-';
	perms[OTHER + XPERM] = (mode & S_IXOTH) ? 'x' : '-';
	
	if (mode & S_ISUID)
		perms[OWNER+XPERM] = (mode & S_IXUSR) ? 's' : 'S';
	if (mode & S_ISGID)
		perms[GROUP+XPERM] = (mode & S_IXGRP) ? 's' : 'S';
	if (mode & S_ISVTX)
		perms[OTHER+XPERM] = (mode & ANYEXEC) ? 't' : 'T';

	if (S_ISREG(mode))
		tch = '-';
	else if (S_ISDIR(mode))
		tch = 'd';
	else if (S_ISCHR(mode))
		tch = 'c';
	else if (S_ISBLK(mode))
		tch = 'b';
	else if (S_ISFIFO(mode))
		tch = 'p';
#ifdef S_ISSOCK
	else if (S_ISSOCK(mode))
		tch = 's';
#endif
#ifdef S_ISLNK
	else if (S_ISLNK(mode))
		tch = 'l';
#endif
	else
		tch = '?';
	
	*perms = tch;
	return perms;
}
