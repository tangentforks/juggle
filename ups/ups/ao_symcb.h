/* ao_symcb.h - public header file for ao_symcb.c */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_symcb.h	1.1 24/5/95 (UKC) */

bool ao_cblocks_match PROTO((char *data, char *newdata, bool same_func));
void ao_set_cblock_data PROTO((char **p_data, char *data, bool append));
void ao_free_cblock_data PROTO((char *data));
bool ao_cblock_has_var PROTO((char *data, const char *name));
var_t *ao_get_cblock_vars PROTO((symtab_t *st, char *data, taddr_t addr));
int push_common_block PROTO((symtab_t *st, stf_t *stf, func_t *f,
			     symio_t *symio, int symno));
