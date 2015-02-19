/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)srcpath.h	1.2 20 Jun 1995 (UKC) */

typedef struct pathlist_s {
	const char *path;
	struct pathlist_s *next;
} Pathentry;

void srcpath_add_path PROTO((const char *path));

void srcpath_ignore_path_hints PROTO((void));

bool srcpath_resolve_path PROTO((const char *what, const char *path_hint,
				 const char *name, const char **p_fullpath));

struct Srcbuf *srcpath_visit_file PROTO((alloc_pool_t *ap,
					 const char *path_hint,
					 const char *name));

bool srcpath_file_exists PROTO((const char *path_hint, const char *name));

Pathentry *get_source_path_root PROTO((void));

Pathentry *get_source_path_tail PROTO((void));

void srcpath_check_and_add_path PROTO((const char *ro_paths));
