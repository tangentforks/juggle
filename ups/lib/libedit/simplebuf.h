/* simplebuf.h - header file for simplebuf.c */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)simplebuf.h	1.3 09 Sep 1994 (UKC) */

#ifndef TEXT_BUFFER_DEFINED
typedef struct Text_buffer Text_buffer;
#define TEXT_BUFFER_DEFINED
#endif /* !TEXT_BUFFER_DEFINED */

Text_buffer *text_create_simple_buffer PROTO((void));

Text_buffer *text_create_readonly_buffer PROTO((const char *text, size_t len));
