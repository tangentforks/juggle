/* xc_symparse.h - header file for xc_symparse.c  */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)xc_symparse.h	1.1 22/12/93 (UKC) */

typedef struct symdesc_s symdesc_t;

symdesc_t *make_symdesc PROTO((alloc_pool_t *ap, const char *typeptr,
			       const char *strings, size_t strings_size,
			       size_t ntypes,
			       char **varaddrs, taddr_t data_addr,
			       const char *iptr));

void free_symdesc PROTO((symdesc_t *sd));

block_t *unpack_one_block PROTO((symdesc_t *sd));
