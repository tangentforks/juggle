/* onpath.c - search for a file on a path */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char utils_onpath_sccsid[] = "@(#)onpath.c	1.7 30/5/93 UKC";

#include <ifdefs.h>
#include <local/ukcprog.h>
#include "utils.h"

/*  Returns the path to a file by looking in a list of directories.
 *  The name of the file is in the 'name' parameter.
 *  The list of directories is in 'dirs', seperated by 'seps',  
 *  e,g. "/lib:/usr/lib" and ":".
 *
 *  Returns NULL if the file was not found in any directory.
 *
 *  The returned string is malloc'ed storage - when it is finished with
 *  it should be passed to free() to release its storage.
 */
char *
onpath(dirs, seps, name)
const char *dirs, *seps, *name;
{
	char **dirvec, **dp;

	if ((dirs == NULL) || (name == NULL))
		return NULL;

	dirvec = ssplit(dirs, seps);

	for (dp = dirvec; *dp != NULL; ++dp) {
		char *path;
		
		path = strf("%s/%s", *dp, name);

		if (access(path, F_OK) == 0) {
			free(dirvec);
			return path;
		}

		free(path);
	}

	free(dirvec);
	return NULL;
}

