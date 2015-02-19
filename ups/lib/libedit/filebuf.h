/* filebuf.h - header file for filebuf.c */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)filebuf.h	1.2 31 Aug 1994 (UKC) */

#ifndef TEXT_BUFFER_DEFINED
typedef struct Text_buffer Text_buffer;
#define TEXT_BUFFER_DEFINED
#endif /* !TEXT_BUFFER_DEFINED */

bool edit_filebuf_visit_file PROTO((alloc_pool_t *ap,
				    const char *what, const char *path,
				    size_t maxblocks, size_t blocksize,
				    Text_buffer **p_buffer));
