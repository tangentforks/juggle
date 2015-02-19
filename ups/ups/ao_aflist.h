/* ao_aflist.h - header file for ao_aflist.c */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_aflist.h	1.1 24/5/95 (UKC) */

typedef struct Ambig_fil Ambig_fil;

fil_t *basename_to_maybe_ambig_fil PROTO((symtab_t *st, const char *name,
					  hashtab_t *ht, hashvalues_t *hv,
					  Ambig_fil **p_aflist));

void resolve_aflist PROTO((func_t *funclist, Ambig_fil *af));
