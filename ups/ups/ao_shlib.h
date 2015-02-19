/* ao_shlib.h - public header file for ao_shlib.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_shlib.h	1.2 24 May 1995 (UKC) */

int make_symtab_cache PROTO((const char *textpath, symtab_t **p_stcache));
symtab_t *get_symtab_cache_list PROTO((void));

bool aout_next_symtab PROTO((target_t *xp, symtab_t *st, bool load_new,
			     symtab_t **p_next_st));
			     
int load_shared_library_symtabs PROTO((target_t *xp, int adding_libs_only));
void unload_shared_library_symtabs PROTO((target_t *xp));
