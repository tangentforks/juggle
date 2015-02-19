/* cx_wsym.h - header file for cx_wsym.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)cx_wsym.h	1.1 22/12/93 (UKC) */

typedef struct syminfo_s syminfo_t;

syminfo_t *make_syminfo PROTO((alloc_pool_t *ap, FILE *fp, ebuf_t *eb));
int write_block PROTO((syminfo_t *si, block_t *bl));
int write_types PROTO((syminfo_t *si, size_t *p_ntypes));
