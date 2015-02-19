/* cx_symio.h - header file for cx_symio.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)cx_symio.h	1.1 22/12/93 (UKC) */

int save_string PROTO((ebuf_t *str_eb, const char *s, FILE *fp));
size_t note_string PROTO((ebuf_t *str_eb, const char *s));
int write_strings PROTO((ebuf_t *eb, FILE *fp, size_t *p_nbytes));

int fp_write PROTO(( FILE *fp, const char *buf, size_t count));
int readfp PROTO((FILE *fp, const char *path, char *buf, size_t nbytes));

#ifdef XC_LOAD_H_INCLUDED
int write_symtab PROTO((FILE *fp, const char *path, ebuf_t *str_eb,
				       linkinfo_t *li, long *p_symtab_size));
int read_symtab PROTO((FILE *fp, const char *path, size_t symtab_size,
							     linkinfo_t *li));
int get_symtab_size PROTO((o_syminfo_t *os));

int fp_write_val PROTO((FILE *fp, size_t val));
#endif
