/* ao_symscan.h - public header file for ao_symscan.c */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_symscan.h	1.2 20 Jun 1995 (UKC) */

language_t srctype PROTO((const char *name));

void parse_fname PROTO((alloc_pool_t *ap, const char *name,
			int modsepc, bool ext, 
                        const char **p_modname, const char **p_fname));

fsyminfo_t *make_fsyminfo PROTO((alloc_pool_t *ap, int symno));

stf_t *make_stf PROTO((alloc_pool_t *ap, const char *name, symtab_t *st,
		       int symno, language_t language, taddr_t addr));

fil_t *make_fil PROTO((stf_t *stf, block_t *parblock, const char *path_hint, 
                       fil_t *next));

void scan_symtab PROTO((symtab_t *st, const char *path, stf_t *stf,
			func_t **p_flist, const char **p_mainfunc_name));

void add_function_to_symtab PROTO((symtab_t *st, func_t **p_flist, 
                                   const char *namestr,
				   fil_t *fil, fil_t *solfil,
				   bool is_static, bool is_textsym,
				   int symno, taddr_t addr));

snlist_t *push_symname PROTO((Symrec *sr, alloc_pool_t *ap,  stf_t *stf,
			      const char *sym_name, int symno));

bool symtab_name_to_sn PROTO((snlist_t *snlist, const char *name, 
                              const char *prefix, const char *fname,
			      bool use_allnames, snlist_t **p_sn));

bool symtab_sym_name_to_sn PROTO((snlist_t *snlist, const char *name, 
                              snlist_t **p_sn, bool justone));

const char *parse_name PROTO((Symrec *sr, const char **p_s,
			      alloc_pool_t *ap, int func,
			      Compiler_type compiler, bool is_fortran));

bool parse_number PROTO((stf_t *stf, Symrec *sr, const char **p_s, int *p_val));
bool parse_typenum PROTO((stf_t *stf, Symrec *sr, bool assume_paren,
			  const char **p_s,
			  int *p_fnum, int *p_tnum));

bool char_to_utypecode PROTO((int c, typecode_t *p_typecode));

void change_base_address PROTO((symtab_t *st, taddr_t new_addr));

bool find_sol_fil PROTO((fil_t *sfiles, const char *path_hint, const char *name,
			 fil_t **p_fil));

const char bump_str PROTO((Symrec *sr, const char **p_s));
