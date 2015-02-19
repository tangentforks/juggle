/* ao_syms.h - a.out file symbol table definitions */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_syms.h	1.4 20 Jun 1995 (UKC) */

#if defined(OS_SUNOS) && defined(ARCH_SUN386)
#define COFF_SUN386
#define ST_COFF
#endif

/*  The DS3100 has it's own symbol table format, designed
 *  by Third Eye Software.  Set a cpp flag to indicate this.
 */
#if defined(ARCH_MIPS_MIPS) || defined(ARCH_ULTRIX_MIPS)
#define ST_TE
#define ST_COFF
#endif

#ifdef COFF_SUN386
typedef struct syment nlist_t;
#define SYMSIZE		SYMESZ
#else
#ifdef ST_TE
typedef SYMR nlist_t;
#else
typedef struct nlist nlist_t;
#endif
#define SYMSIZE		sizeof(nlist_t)
#endif /* !COFF_SUN386 */

/*  We fake N_DATA, N_TEXT and N_EXT in getsym and findsym, so define
 *  them here.
 */
#ifdef COFF_SUN386
#define N_UNDF		0x0
#define N_TEXT		0x4
#define N_DATA		0x6
#define N_BSS		0x8
#define N_EXT		1
#else
#ifndef AO_ELF
#define n_offset	n_un.n_strx
#endif
#define n_dbx_type	n_type
#endif

typedef struct fsyminfo {
	int fs_symno;		/* Start of syms in file for this func */
	
	fil_t *fs_initial_lno_fil;	/* fil that source lines start in */
	unsigned fs_initial_sline_offset; /* initial lnum offset (N_XLINE) */
	int fs_symlim;			/* ditto */
	long fs_cblist;			/* used only in st_cb.c */
#if defined(ARCH_SUN386) && defined(OS_SUNOS)
	long fs_coff_lno_start;		/* see ao_text.c */
	long fs_coff_lno_lim;		/* ditto */
#endif
#ifdef ST_TE
	/*  Fields for extracting line number information.
	 */
	int fs_lno_base;
	int fs_first_lnum;
	int fs_last_lnum;

	frame_t fs_frbuf;
#endif
} fsyminfo_t;

#define AO_FSYMDATA(f)		((fsyminfo_t *)(f)->fu_symdata)

#ifdef ST_TE
typedef struct extsymst {
	const char *es_name;
	taddr_t es_addr;
	struct stfst *es_stf;
	int es_symno;
} extsym_t;
#else
typedef struct Ftype Ftype;

typedef struct snlistst {
	int sn_symno;
	const char *sn_symtab_name;
/*	const char *sn_demangled_symtab_name;  // no longer needed(RCB) */
	const char *sn_name;
#ifdef ultrix
	taddr_t sn_addr;
#endif
	struct snlistst *sn_next;
} snlist_t;
#endif

typedef struct symio_s symio_t;		/* Defined in ao_symread.c */

#ifndef ELFINFO_TYPEDEFED
typedef struct Elfinfo Elfinfo;
#define ELFINFO_TYPEDEFED
#endif

#ifndef SOLIB_TYPEDEFED
typedef struct Solib Solib;
typedef struct Solib_addr Solib_addr;
#define SOLIB_TYPEDEFED
#endif

/*  Non-generic symbol table information for a.out files.  The st_data
 *  field of the generic symtab_t structure points at this structure for
 *  a.out files.
 *
 *  Sun's compiler leaves most debugging symbols in the .o files rather
 *  than copying them all to the a.out file, so we need multiple symio
 *  structures.  On other systems text_symio will be the only symio structure.
 */
typedef struct ao_stdata_t {
	int st_dynamic;			/* TRUE if dynamically linked */
	long st_base_address;		/* Addr shlib mapped rel to sym addrs */
	off_t st_addr_to_fpos_offset;	/* Core addr - textfile offset */
	int st_textfd;			/* Fd open for reading on textfile */
	symio_t *st_text_symio;		/* Symio for the a.out file itself */
	
#ifdef ST_TE
	extsym_t *st_exttab;		/* External symbols */
	int st_exttab_size;		/* # external symbols */
	char *st_lnotab;		/* The whole line number table */
	long st_lnotab_size;		/* Size of the table */
	strcache_id_t st_aux_strcache;	/* Aux symbols (TIRs etc) */
	struct stfst **st_stftab;	/* For rndx mapping */
	int st_stftab_size;		/* # entries in st_stftab */
#endif

#ifdef AO_ELF
	Solib *st_solib;
#else
	symtab_t *st_next;
#endif
} ao_stdata_t;

typedef struct {
	symio_t *symio;
	int symno;
} Symrec;

#define AO_STDATA(st)	((ao_stdata_t *)(st)->st_data)

#ifdef ARCH_386
/*  Max number of registers that can be saved on function entry.
 *  We are conservative here - the real number is probably 3 or 4.
 */
#define N_PUSHABLE_REGS	8
#endif

typedef struct ao_preamble_s {
	unsigned pr_bpt_offset;	/* offset from func addr of first bpt loc */
	unsigned pr_rsave_mask;	/* register save mask */
	int pr_rsave_offset;	/* offset from fp of start of reg save area */
#ifdef ARCH_CLIPPER
	int pr_frame_size;	/* frame size for functions with no fp */
#endif
#if defined(ARCH_MIPS) || defined(ARCH_CLIPPER) || defined(ARCH_SUN3)
	unsigned pr_fpreg_rsave_mask;	/* floating point reg rsave mask */
	int pr_fpreg_rsave_offset;	/* floating point reg save offset */
#endif
#ifdef ARCH_386
	char pr_regtab[N_PUSHABLE_REGS];/* which order regs saved */
#endif
} ao_preamble_t;

#define AO_PREDATA(f)	((ao_preamble_t *)(f)->fu_predata)

#ifdef ST_TE
typedef struct aggrlistst {
	type_t *al_type;
	int al_symno;
	struct aggrlistst *al_next;
} aggrlist_t;
#endif

#ifdef AO_ELF
enum { AR_DATA, AR_BSS, AR_RODATA, AR_NTYPES };

typedef struct Dataspace {
	taddr_t base;
	taddr_t lim;
} Addr_range;
#endif

typedef struct stf_s {
	const char *stf_name;
	language_t stf_language;
	Compiler_type stf_compiler_type;
	symtab_t *stf_symtab;
	fil_t *stf_fil;
	int stf_symno;
	int stf_symlim;
	taddr_t stf_addr;
	unsigned stf_flags;
#ifdef AO_ELF
	const char *stf_objpath_hint;
	const char *stf_objname;
	time_t stf_obj_mtime;
	const char *stf_global_prefix;
	symio_t *stf_symio;
	Addr_range stf_range[AR_NTYPES];
#endif
#ifdef ARCH_CLIPPER
	addrlist_t *stf_addrlist;
#endif
#ifdef ST_TE
	aggrlist_t *stf_aggrlist;
	long *stf_rfdtab;
	int stf_rfdtab_size;
	long stf_aux_base;
	long stf_strings_base;
	int stf_lno_base;
	int stf_lno_lim;
#else
	snlist_t *stf_snlist;
	Ftype *stf_ftypes;
	struct hfst **stf_fmap;
	int stf_mapsize;
	int stf_fnum;
#endif
} stf_t;

#define AO_FIDATA(fil)	((stf_t *)fil->fi_data)

/*  Flag bits in stf_flags.
 */
#define STF_LNOS_PRECEDE_FUNCS	0x01	/* for gcc */
#define STF_HIDE		0x02	/* don't show this under source files */
#define STF_NEED_SYMSCAN	0x04    /* need to get syms from .o file */
#define STF_NEED_PATCH		0x08    /* some types have internal type codes */
#define STF_FUNCS_REPEATED	0x10	/* two N_FUN syms for each function */

typedef struct hfst {
	stf_t *hf_stf;
	int hf_id;
	struct hfst *hf_next;
} hf_t;

/*  Shared library header on Suns.
 */
typedef struct shlibst {
	const char *sh_name;
	taddr_t sh_addr;
	struct shlibst *sh_next;
} shlib_t;

