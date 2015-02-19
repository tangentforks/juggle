/* io.h - header file for read/write type utility functions */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)io.h	1.1 24/5/95 (UKC) */

bool read_chunk PROTO((const char *path, const char *what, int fd,
		       const char *chunkname,
		       off_t offset, void *buf, size_t nbytes));

bool open_for_reading PROTO((const char *path, const char *what, int *p_fd));
