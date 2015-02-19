/* ao_symparse.h - public header file for ao_symparse.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_symparse.h	1.3 24 May 1995 (UKC) */

#ifndef ST_TE
type_t *TypeId PROTO((stf_t *stf, Symrec *sr, const char **p_s,
		      int eval, int prior_chr));
void Typenum PROTO((stf_t *stf, Symrec *sr, bool assume_paren,
		    const char **p_s, int *p_fnum, int *p_tnum));
type_t *Class PROTO((stf_t *stf, Symrec *sr, const char **p_s,
		     class_t *p_class));
int parse_num PROTO((stf_t *stf, Symrec *sr, const char **p_s));
void scheck PROTO((Symrec *sr, const char **p_s, int ch));
int field_scheck PROTO((Symrec *sr, const char **p_s, int ch));
void wrapup_types PROTO((stf_t *stf));
#endif /* !ST_TE */

