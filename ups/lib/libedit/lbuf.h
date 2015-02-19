/* lbuf.h - header file for lbuf.c */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)lbuf.h	1.3 09 Sep 1994 (UKC) */

#ifdef TEXTBUF_H_INCLUDED
Text_buffer *text_create_lbuf_buffer PROTO((alloc_pool_t *ap,
					    size_t maxblocks, size_t blocksize,
					    void *handle,
					    Text_info_func info_func,
					    Text_read_func read_func,
					    Text_close_func close_func));
#endif

#ifndef TEXT_BUFFER_DEFINED
typedef struct Text_buffer Text_buffer;
#define TEXT_BUFFER_DEFINED
#endif /* !TEXT_BUFFER_DEFINED */

Text_buffer *text_create_empty_lbuf_buffer PROTO((alloc_pool_t *ap,
						  size_t maxblocks,
						  size_t blocksize));

void text_get_buffer_modtime PROTO((Text_buffer *tb, long *mtime));
