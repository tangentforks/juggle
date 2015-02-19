/* ao_elfsym.h - header file for ao_elfsym.c */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_elfsym.h	1.2 04 Jun 1995 (UKC) */

void elf_handle_optsym PROTO((alloc_pool_t *ap, const char *opts,
			      language_t* language,
			      const char **p_global_prefix,
			      Compiler_type *p_compiler_type,
			      bool *p_has_debug_syms));

const char *elf_name_from_symtab_name PROTO((const char *prefix,
					     const char *symtab_name));

bool elf_scan_then_setup_symio PROTO((fil_t *fil, symio_t **p_symio));

#ifdef AO_ELFPRIV_H_INCLUDED
bool scan_elf_symtab PROTO((alloc_pool_t *target_ap,
			    const char *textpath, int fd,
			    Libdep *libdep,
			    struct func_s **p_mainfunc,
			    struct func_s **p_initfunc,
			    Solib **p_solibs));
#endif
