/* xc_load.h - header file for cx_load.c */

/*  Copyright 1992 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)xc_load.h	1.3 12/22/93 (UKC) */

#define XC_LOAD_H_INCLUDED

#define OCX_MAGIC	0x0cc0c0de
#define OCX_VERSION	1

/*  Header for an linker intermediate `.ocx' file.
 */
typedef struct {
	size_t cx_magic;
	size_t cx_version;
	size_t cx_bss_size;	/* Bss size in bytes */
	size_t cx_extbss_size;	/* External bss size in bytes */
	size_t cx_srcpath;	/* Offset of string hold source path */

	/*  Things appear in the .ocx file in the same order as these
	 *  structure members appear.
	 */
	size_t cx_nfuncrefs;	/* # references to external funcs */
	size_t cx_nvarrefs;	/* # references to external vars */
	size_t cx_nfuncs;	/* # external funcs defined */
	size_t cx_nvars;		/* # external vars defined */
	size_t cx_strings_size;	/* # bytes of string */
	size_t cx_extdata_size;	/* # bytes of external data */
	size_t cx_n_extdata_relocs;	/* # relocations in external data */
	size_t cx_n_extdata_funcrelocs;

	/*  The things described by the following counts are not read in
	 *  for linking - they are read in a single gulp when text is
	 *  loaded for execution.
	 */
	size_t cx_text_size;	/* Text size in bytes */
	size_t cx_data_size;	/* Data size in bytes */
	size_t cx_n_static_relocs;
	size_t cx_n_static_funcrelocs;
	size_t cx_n_ext_relocs;
	size_t cx_nfuncaddrs;	/* # entries in local funcaddrs table */

	/*  The symbol table is optional, and not required for execution.
	 *  It is used for debugging.  If cx_symtab_size is non-zero then
	 *  the symbol table is present and is described by the o_syminfo_t
	 *  structure (below).
	 */
	size_t cx_symtab_size;	/* Symbol table size in bytes (0 if stripped) */
} cx_header_t;

typedef struct o_syminfo_s {
	size_t os_strings_size;
	size_t os_nfuncs;
	size_t os_nvars;
	size_t os_types_offset;
	size_t os_ntypes;
	size_t os_symdata_nbytes;
	size_t os_letab_count;
	size_t os_letab_nbytes;
} o_syminfo_t;

/*  Header for the linker executable output file.
 */
typedef struct {
	char xh_intpath[128];	/* #! line for executer */
	size_t xh_magic;	
	size_t xh_version;
	size_t xh_cwd;
	size_t xh_n_libfuncs;
	size_t xh_n_libvars;

	size_t xh_main_sym;
	size_t xh_exit_sym;
	size_t xh_setjmp_sym;
	size_t xh_longjmp_sym;

	size_t xh_nfiles;
	size_t xh_nrefs;		/* # references to external names */
	size_t xh_extdata_size;
	size_t xh_extbss_size;
	size_t xh_n_extrefs;	/* # external reference entries */
	size_t xh_n_extdata_relocs;
	size_t xh_n_extdata_funcrelocs;

	/*  The following two fields describe symbol table information.
	 *  This is needed for debugging but not for execution.
	 */
 	size_t xh_nsymfuncs;
	size_t xh_nsymvars;
	size_t xh_symstrings_size;

	size_t xh_strings_size;
} x_header_t;

int ci_load PROTO((const char *path, size_t stack_size, bool want_opcounts,
			    char **argv, char **envp, machine_t **p_machine));

#ifdef XC_MACHINE_H_INCLUDED
int ci_read_symtab_bytes PROTO((alloc_pool_t *ap, const char *cwd,
				codefile_t *cf, char **p_symtab_buf,
				size_t *p_nbytes));
#endif
