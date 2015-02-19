/* fopen_new_file.c - fopen a file but refuse to overwrite an existing one */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char utils_fopen_new_file_sccsid[] = "@(#)fopnew.c	1.7 04 Jun 1995 (UKC)";

#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <ctype.h>

#include <errno.h>
#include <stdio.h>
#include <local/ukcprog.h>

#include "utils.h"

bool
fopen_new_file(what, name, overwrite, p_fp)
const char *what, *name;
bool overwrite;
FILE **p_fp;
{
	struct stat stbuf;
	FILE *fp;

	if (name == NULL) {
		*p_fp = stdout;
		return TRUE;
	}

	if (!overwrite) {
		if (stat(name, &stbuf) == 0) {
			errf("%c%s `%s' already exists",
			     toupper(*what), &what[1], name);
			return FALSE;
		}
	
		if (errno != ENOENT) {
			failmesg("Can't stat", what, name);
			return FALSE;
		}
	}

	if ((fp = fopen(name, "w")) == NULL) {
		failmesg("Can't create", what, name);
		return FALSE;
	}

	*p_fp = fp;
	return TRUE;
}

bool
fclose_new_file(what, name, ok, fp)
const char *name, *what;
bool ok;
FILE *fp;
{
	if (fp == stdout)
		name = "the standard output";

	if (ferror(fp) || fflush(fp) == EOF) {
		if (ok) {
			failmesg("Error writing to", what, name);
			ok = FALSE;
		}
	}

	if (fp != stdout && fclose(fp) == EOF && ok) {
		failmesg("Error closing", what, name);
		ok = FALSE;
	}

	return ok;
}
