/* ao_text.h - public header file for ao_text.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_text.h	1.2 24 May 1995 (UKC) */

bool open_textfile PROTO((int fd, const char *textpath, taddr_t *p_data_addr));

bool text_dread PROTO((target_t *xp, taddr_t addr, char *buf, size_t nbytes));

#ifdef SYMTAB_H_INCLUDED
bool get_preamble PROTO((func_t *f, ao_preamble_t **p_pr));

#ifdef AO_EXECINFO_H_INCLUDED
bool scan_ao_symtab PROTO((const char *textpath, int fd, Execinfo *ei, 
                           taddr_t base_address, symtab_t **p_symtab, 
                           func_t **p_flist, const char **p_mainfunc_name));

void do_ao_postscan_stuff PROTO((symtab_t *st, func_t *flist, Execinfo *ei, 
				 func_t **p_mainfunc, 
				 const char *mainfunc_name, 
				 func_t **p_initfunc, 
				 const char *initfunc_name));
#endif /* EXECINFO_H_INCLUDED */

#endif /* SYMTAB_H_INCLUDED */
