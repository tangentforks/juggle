/* ao_te.h - public header file for ao_te.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_te.h	1.1 22/12/93 (UKC) */

#ifdef ST_TE
int skim_te_symtab PROTO((symtab_t *st, int fd,
			  off_t syms_offset, off_t addr_to_fpos_offset,
			  taddr_t first_addr, taddr_t last_addr,
			  block_t *rootblock,
			  bool *p_have_common_blocks, fil_t **p_sfiles,
			  functab_id_t *p_functab_id, cblist_id_t *p_cblist_id));
#endif
