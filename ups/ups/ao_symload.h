/* ao_symload.h - public header file for ao_symload.c */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_symload.h	1.5 24 May 1995 (UKC) */

void push_typedefs_and_aggrs PROTO((alloc_pool_t *ap, block_t *hdrbl, 
                                    block_t *bl));
bool ao_fil_may_have_matching_globals PROTO((fil_t *fil, const char *pat, 
                                             matchfunc_t matchf));
var_t *ao_get_fi_vars PROTO((fil_t *fil));
block_t *ao_get_fu_blocks PROTO((func_t *f));
lno_t *ao_get_fu_lnos PROTO((func_t *f));
Compiler_type ao_compiler PROTO((fil_t *fil, bool compiler_found,
				 Compiler_type compiler));
				
void set_compiler_version(double ver);
double get_compiler_version();
