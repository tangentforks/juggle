/* ao_symscan.c - do initial symbol table scan */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ups_ao_symscan_c_sccsid[] = "@(#)ao_symscan.c	1.3 20 Jun 1995 (UKC)";

#include <mtrprog/ifdefs.h>
#include "ao_ifdefs.h"

#ifdef AO_TARGET

#include <sys/types.h>
#include <time.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#ifdef AO_ELF
#	include "elfstab.h"
#else
#	include <a.out.h>
#	ifndef OS_RISCOS
#		include <stab.h>
#	endif
#endif

#include <local/ukcprog.h>

#include "ups.h"
#include "symtab.h"
#include "ci.h"
#include "st.h"
#include "ao_syms.h"
#include "ao_symload.h"
#include "ao_symscan.h"
#include "ao_symread.h"
#include "ao_elfsym.h"
#include "ao_symcb.h"
#include "util.h"
#include "state.h"  /* RCB: for demangling_enabled() */

#if HAVE_CPLUS_DEMANGLE
#include <demangle.h>
#if HAVE_CPLUS_DEMANGLE_NORET
#define sunpro_cplus_demangle cplus_demangle_noret
#else
#define sunpro_cplus_demangle cplus_demangle
#endif
#endif

/* Options passed to gnu_cplus_demangle (in 2nd parameter). */

#define DMGL_NO_OPTS	0		/* For readability... */
#define DMGL_PARAMS	(1 << 0)	/* Include function args */
#define DMGL_ANSI	(1 << 1)	/* Include const, volatile, etc */

#define DMGL_AUTO	(1 << 8)
#define DMGL_GNU	(1 << 9)
#define DMGL_LUCID	(1 << 10)
#define DMGL_ARM	(1 << 11)
#define DMGL_HP		(1 << 12)
#define DMGL_EDG	(1 << 13)
/* If none of these are set, use 'current_demangling_style' as the default. */
#define DMGL_STYLE_MASK (DMGL_AUTO|DMGL_GNU|DMGL_LUCID|DMGL_ARM)

/* Enumeration of possible demangling styles.

   Lucid and ARM styles are still kept logically distinct, even though
   they now both behave identically.  The resulting style is actual the
   union of both.  I.E. either style recognizes both "__pt__" and "__rf__"
   for operator "->", even though the first is lucid style and the second
   is ARM style. (FIXME?) */

extern enum demangling_styles
{
  unknown_demangling = 0,
  auto_demangling = DMGL_AUTO,
  gnu_demangling = DMGL_GNU,
  lucid_demangling = DMGL_LUCID,
  arm_demangling = DMGL_ARM,
  hp_demangling = DMGL_HP,
  edg_demangling = DMGL_EDG,
} current_demangling_style;

/* Define string names for the various demangling styles. */

#define AUTO_DEMANGLING_STYLE_STRING	"auto"
#define GNU_DEMANGLING_STYLE_STRING	"gnu"
#define LUCID_DEMANGLING_STYLE_STRING	"lucid"
#define ARM_DEMANGLING_STYLE_STRING	"arm"

/* Some macros to test what demangling style is active. */

#define CURRENT_DEMANGLING_STYLE current_demangling_style
#define AUTO_DEMANGLING (((int) CURRENT_DEMANGLING_STYLE) & DMGL_AUTO)
#define GNU_DEMANGLING (((int) CURRENT_DEMANGLING_STYLE) & DMGL_GNU)
#define LUCID_DEMANGLING (((int) CURRENT_DEMANGLING_STYLE) & DMGL_LUCID)
#define ARM_DEMANGLING (CURRENT_DEMANGLING_STYLE & DMGL_ARM)
#define HP_DEMANGLING (CURRENT_DEMANGLING_STYLE & DMGL_HP)
#define EDG_DEMANGLING (CURRENT_DEMANGLING_STYLE & DMGL_EDG)

static char *gnu_cplus_demangle PROTO((const char *mangled, int options));

static void wrapup_stf PROTO((stf_t *stf, hf_t **fmap, int mapsize));
static hf_t *lookup_hf PROTO((hf_t *headers, int id));
static void build_symset PROTO((char *aout_symset, char *ofile_symset));
static bool is_fortran_void PROTO((const char *cptr));
static void reverse_stf_funclist PROTO((stf_t *stf));
static void adjust_fil_vars_addr_base PROTO((fil_t *flist, long delta));
static fil_t *add_sol_fil PROTO((stf_t *stf, alloc_pool_t *ap, fil_t *sfiles,
				 fil_t *sofil, const char *name));
static void add_to_fil_funclist PROTO((alloc_pool_t *ap, fil_t *fil, 
                                       func_t *f));
#ifdef AO_ELF
static func_t *note_ofile_function PROTO((alloc_pool_t *ap,
					  alloc_pool_t *tmp_ap, stf_t *stf,
					  const char *path,
					  fil_t *solfil, unsigned sline_offset,
					  const char *namestr, int symno,
					  funclist_t** p_fl));
#endif

void display_message PROTO((const char *mesg));

const char
bump_str(sr, p_s)
Symrec *sr;
const char **p_s;
{
  char c;

  if (**p_s == '\\')
    *p_s = get_cont_symstring(sr);
  c = **p_s;
  (*p_s)++;
  if (**p_s == '\\')
    *p_s = get_cont_symstring(sr);
  return c;
}

#ifndef ST_TE
/*  Deduce language of source file from name.
 *  *.c is C, *.f is f77, *.f90 is f90, anything else is unknown.
 *
 *  BUG: dubious way of getting language.
 */
language_t
srctype(name)
const char *name;
{
	char *suf;

	if ((suf = strrchr(name, '.')) == NULL)
		return LANG_UNKNOWN;
	else
		++suf;

	if (strcmp(suf, "c") == 0)
		return LANG_C;

	if (strcmp(suf, "f") == 0)
		return LANG_F77;

	if (strcmp(suf, "f90") == 0)
		return LANG_F90;

	if (strcmp(suf, "cc") == 0 || strcmp(suf, "C") == 0 ||
	    strcmp(suf, "CC") == 0 || strcmp(suf, "c++") == 0 ||
	    strcmp(suf, "cpp") == 0 || strcmp(suf, "cxx") == 0 ||
	    strcmp(suf, "H") == 0 || strcmp(suf, "hh") == 0)
	  return LANG_CC;	

	return LANG_UNKNOWN;
}

/*  Called when we have finished with an stf structure.  Create space
 *  for the map and copy the stuff to it.
 */
static void
wrapup_stf(stf, orig_fmap, mapsize)
stf_t *stf;
hf_t **orig_fmap;
int mapsize;
{
	hf_t **fmap;
	int i;

	if (mapsize == 0)
		panic("mapsize 0 in wrapup_stf");

	fmap = (hf_t **)alloc(stf->stf_symtab->st_apool,
			      mapsize * sizeof(hf_t *));
	memcpy((char *)fmap, (char *)orig_fmap, mapsize * sizeof(hf_t *));

	for (i = 0; i < mapsize; ++i) {
		stf_t *hstf;

		hstf = fmap[i]->hf_stf;

		if (hstf->stf_fmap == NULL) {
			hstf->stf_fmap = fmap;
			hstf->stf_mapsize = mapsize;
		}
	}
}

static void
reverse_stf_funclist(stf)
stf_t *stf;
{
	funclist_t *fl, *next, *newlist;

	newlist = NULL;
	for (fl = stf->stf_fil->fi_funclist; fl != NULL; fl = next) {
		next = fl->fl_next;
		fl->fl_next = newlist;
		newlist = fl;
	}

	stf->stf_fil->fi_funclist = newlist;
}

/*  Look up the header file entry with id id in the headers list headers.
 *
 *  Used when we find a N_EXCL symbol meaning a header file excluded
 *  because it has already been encountered.
 */
static hf_t *
lookup_hf(headers, id)
hf_t *headers;
int id;
{
	hf_t *hf;

	for (hf = headers; hf != NULL; hf = hf->hf_next)
		if (hf->hf_id == id)
			return hf;
	panic("id not found in lookup_hf");
	/* NOTREACHED */
	return NULL;	/* to keep gcc happy */

}

/*  Parse a name (NAME in the grammar).
 *  If save is non zero, return a pointer to a saved copy of the name,
 *  otherwise return NULL.  Names are saved via an alloc() on ap.
 *
 *  (IDE) added 'is_fortran' to get correct names generated by GNU Fortran
 *  (g77) in the typedefs it generates.
 */
const char *
parse_name(sr, p_s, ap, func, compiler, is_fortran)
Symrec *sr;
const char **p_s;
alloc_pool_t *ap;
int func;
Compiler_type compiler;
bool is_fortran;
{
	register const char *s, *sub;
	char *name;
	register int dots = 0;
/* RCB ADD: */
        int in_template = 0;
	size_t len = 0;

	s = *p_s;


	/*  Gcc 2.3.3 seems to put out spaces in names, so skip them.
	 */
	while (isspace(*s))
		++s;


	/*  The test for ':' is needed because gcc 2.3.1 puts out symbol
	 *  table entries containing empty names (i.e. nothing before the
	 *  ':') for unnamed enums.  SunOS f77 emits `block.data' as a
	 *  symbol, so we allow dots in names.  I don't remember why `$'
	 *  is allowed (Fortran ?).
	 */
	/*  RGA The test for '?' is needed because Pure-link puts out bad */ 
	/*  names apparently */
	if (*s != ':' && *s != '?' && !isalpha(*s) && *s != '_' && *s != '$' && *s != '.')
		panic("bad name in parse_name");

	while (    in_template
		|| isalnum(*s)
		|| *s == '_'
		|| *s == '$'
		|| *s == '.'
		|| *s == '<'    /*  RCB, for C++ templates */
		|| *s == '>'
		|| *s == '\\'
		|| (*s == ' ' && is_fortran)
		|| (*s == '*' && is_fortran)
	)
	{
	  len++;
	  if ( *s == '<')
	    in_template++;
	  else if ( *s == '>')
	    in_template--;
	  else if (*s == '.')
	    dots++;
	  else if ( *s == '\\')
	  {
	      char *s1, *s2;
	      int new_len;

	      len--;
	      s1 = (char *)get_cont_symstring(sr);
	      new_len = strlen(s1);
	      s2 = alloc(ap, s - *p_s + new_len + 1);
	      memcpy(s2, *p_s, len);
	      *p_s = s2;
	      memcpy(s2+len, s1, new_len);
	      s2[len+new_len] = 0;
	      s = s2+len-1;
	  }
	  ++s;
	}

	/* RGA SC4 static data is of the form $prefix.damangled_func_name.static_data */
	/* RCB gnu static members may be of the form mangled_class_name.name
	*/
	if (compiler != CT_GNU_CC && dots )
	  for (sub = s; sub != *p_s; sub--)
	    if (*sub == '.')
	    {
	      sub++;
	      len = s - sub;
	      *p_s = sub;
	      break;
	    }

	if (ap != NULL)
	  demangle_name((char *)*p_s, len, ap, &name, func == 1, compiler);
	else 
	  name = NULL;

	*p_s = s;
	return name;
}

/*  Return a pointer to a munged saved copy of fname.  Ext is true
 *  if name is an external symbol generated by the linker.  These
 *  symbols are expected to have an underscore prepended - if it
 *  is there it is stripped, otherwise the returned name is
 *  enclosed in brackets (e.g. "[name]").
 *
 *  If modsepc is not NUL, and it occurs in the name, we split the name
 *  into a module name and function name at the seperator character.
 *
 *  We use alloc() to get the space.
 *
 *  NOTE: this routine is not used on the DECstation 3100.
 */
void
parse_fname(ap, name, modsepc, ext, p_modname, p_fname)
alloc_pool_t *ap;
const char *name;
int modsepc;
bool ext;
const char **p_modname, **p_fname;
{
	const char *modname;
	char *fname;

#ifdef COFF_SUN386
	/*  On the 386i, external symbols don't seem to
	 *  have underscores prepended, so we force ext
	 *  to false.
	 */
	ext = FALSE;
#endif

	if (ext && *name != '_') {
		modname = NULL;
		fname = alloc(ap, strlen(name) + 3);
		sprintf(fname, "[%s]", name);
	}
	else {
		const char *cptr;
		char *pos;
		size_t len;

		if (ext)
			name++;

		for (cptr = name; *cptr != '\0' && *cptr != ':'; cptr++)
			;

		len = cptr - name;
		fname = alloc(ap, len + 1);
		memcpy(fname, name, len);
		fname[len] = '\0';

		if (modsepc == '\0' || (pos = strchr(fname, modsepc)) == NULL) {
			modname = NULL;
		}
		else {
			modname = fname;
			*pos++ = '\0';
			fname = pos;
		}
	}

	*p_modname = modname;
	*p_fname = fname;
}
#endif /* !ST_TE */

fsyminfo_t *
make_fsyminfo(ap, symno)
alloc_pool_t *ap;
int symno;
{
	fsyminfo_t *fs;

	fs = (fsyminfo_t *)alloc(ap, sizeof(fsyminfo_t));
	fs->fs_initial_lno_fil = NULL;
	fs->fs_initial_sline_offset = 0;
	fs->fs_symno = symno;
	fs->fs_cblist = 0;
#if defined(ARCH_SUN386) && defined(OS_SUNOS)
	fs->fs_coff_lno_start = 0;
	fs->fs_coff_lno_lim = 0;
#endif
	return fs;
}

/*  Allocate a new stf_t structure with alloc() and fill in the fields.
 */
stf_t *
make_stf(ap, name, st, symno, language, addr)
alloc_pool_t *ap;
const char *name;
symtab_t *st;
int symno;
language_t language;
taddr_t addr;
{
#ifdef AO_ELF
	int ar;
#endif
	stf_t *stf;

	stf = (stf_t *)alloc(ap, sizeof(stf_t));
	stf->stf_name = name;
	stf->stf_language = language;
	/*	stf->stf_compiler_type = CT_UNKNOWN;*/
	stf->stf_compiler_type = ao_compiler(NULL, FALSE, CT_UNKNOWN);
	stf->stf_symtab = st;
	stf->stf_symno = symno;
	stf->stf_addr = addr;
	stf->stf_flags = 0;
	stf->stf_fmap = NULL;
	stf->stf_mapsize = 0;
#ifdef ARCH_CLIPPER
	stf->stf_addrlist = NULL;
#endif
#ifndef ST_TE
	stf->stf_snlist = NULL;
	stf->stf_ftypes = NULL;
#endif
#ifdef AO_ELF
	stf->stf_objpath_hint = NULL;
	stf->stf_objname = NULL;
	stf->stf_obj_mtime = 0;
	stf->stf_global_prefix = NULL;
	stf->stf_symio = NULL;

	for (ar = 0; ar < AR_NTYPES; ++ar) {
		stf->stf_range[ar].base = 0;
		stf->stf_range[ar].lim = 0;
	}
#endif
	return stf;
}

/*  Allocate a new fil_t structure with alloc() and fill in the fields.
 */
fil_t *
make_fil(stf, parblock, path_hint, next)
stf_t *stf;
block_t *parblock;
const char *path_hint;
fil_t *next;
{
	fil_t *fil;
	alloc_pool_t *ap;

	ap = stf->stf_symtab->st_apool;

	fil = ci_make_fil(ap, stf->stf_name, (char *)stf,
			  ci_make_block(ap, parblock), next);

	fil->fi_path_hint = path_hint;
	fil->fi_source_path = (char *)path_hint;
	fil->fi_language = stf->stf_language;
	fil->fi_symtab = stf->stf_symtab;

	return fil;
}

bool
find_sol_fil(sfiles, path_hint, name, p_fil)
fil_t *sfiles;
const char *path_hint, *name;
fil_t **p_fil;
{
	fil_t *fil;
	bool abspath;

	abspath = *name == '/';

	for (fil = sfiles; fil != NULL; fil = fil->fi_next) {
	  if ((abspath || same_string(fil->fi_path_hint, path_hint)) &&
	      strcmp(fil->fi_name, name) == 0) {
			*p_fil = fil;
			return TRUE;
		}
	}

	return FALSE;
}

static fil_t *
add_sol_fil(stf, ap, sfiles, sofil, name)
stf_t *stf;			/* RGA */
alloc_pool_t *ap;
fil_t *sfiles, *sofil;
const char *name;
{
	fil_t *fil;
	const char *path_hint;

	path_hint = (*name != '/') ? sofil->fi_path_hint : NULL;

	if (find_sol_fil(sfiles, path_hint, name, &fil))
		return fil;

	fil = ci_make_fil(ap, alloc_strdup(ap, name), (char *)stf,
			  ci_make_block(ap, (block_t *)NULL), sofil->fi_next);

	fil->fi_path_hint = path_hint;
	fil->fi_source_path = (char *)path_hint;
	fil->fi_language = srctype(fil->fi_name_only);

	/*  The only thing these entries are used for is displaying
	 *  source code, but we need fi_symtab because things like
	 *  open_source_file() go via it to get an alloc pool.
	 */
	fil->fi_symtab = sofil->fi_symtab;

	fil->fi_flags |= FI_DONE_VARS | FI_DONE_TYPES;

	sofil->fi_next = fil;

	return fil;
}

#ifndef ST_TE
#define SYMSET_SIZE	256

/*  Build the map of interesting symbols for scan_symtab.  We could do this
 *  at compile time with some effort, but it's much less hassle to do it at
 *  run time like this.
 */
static void
build_symset(aout_symset, ofile_symset)
char *aout_symset, *ofile_symset;
{
	static int common_syms[] = {
		N_BCOMM, N_STSYM, N_GSYM, N_LCSYM, N_FUN, N_SOL,
#ifdef N_BINCL
		N_BINCL, N_EXCL, N_EINCL,
#endif
#ifdef N_XLINE
		N_XLINE,
#endif
#ifdef AO_ELF
		N_ILDPAD,
		N_UNDF,
#endif
	};
	static int aout_only_syms[] = {
		N_SO,
		N_TEXT, N_TEXT | N_EXT, N_BSS | N_EXT, N_DATA | N_EXT,
		N_DATA,
#ifdef AO_ELF
		N_OPT,
#endif
#ifdef N_MAIN
		N_MAIN
#endif
	};
	int i;

	memset(ofile_symset, '\0', SYMSET_SIZE);
	for (i = 0; i < sizeof(common_syms) / sizeof(common_syms[0]); ++i)
		ofile_symset[common_syms[i]] = TRUE;

	memcpy(aout_symset, ofile_symset, SYMSET_SIZE);
	for (i = 0; i < sizeof(aout_only_syms) / sizeof(aout_only_syms[0]); ++i)
		aout_symset[aout_only_syms[i]] = TRUE;
}

bool
parse_number(stf, sr, p_s, p_val)
stf_t *stf;
Symrec *sr;
const char **p_s;
int *p_val;
{
	const char *s;
	int res;

	s = *p_s;

	if (*s == '\\')
	  s = get_cont_symstring(sr);

	if (!isdigit(*s))
		return FALSE;

	res = 0;
	if (stf->stf_compiler_type ==  CT_GNU_CC && s[-1] == '/' && s[-2] == ':')
	  bump_str(sr, &s);	/* RGA - g++ puts out these... */
	if (*s == '0') {
		bump_str(sr, &s);
		if (*s == 'x' || *s == 'X') {
			bump_str(sr, &s);
			for (;;) {
				if (isdigit(*s))
					res = res * 16 + bump_str(sr, &s) - '0';
				else if (*s >= 'A' && *s <= 'F')
					res = res * 16 + bump_str(sr, &s) - 'A' + 10;
				else if (*s >= 'a' && *s <= 'f')
					res = res * 16 + bump_str(sr, &s) - 'a' + 10;
				else
					break;
			}
		}
		else {
		    while (*s >= '0' && *s <= '7')
		      res = res * 8 + bump_str(sr, &s) - '0';
		}
	      }
	else {
		while (isdigit(*s))
		  res = res * 10 + bump_str(sr, &s) - '0';
	}
	if (*s == '\\')
	  s = get_cont_symstring(sr);
	*p_s = s;
	*p_val = res;
	return TRUE;
}
bool
parse_typenum(stf, sr, assume_paren, p_s, p_fnum, p_tnum)
stf_t *stf;
Symrec *sr;
bool assume_paren;
const char **p_s;
int *p_fnum, *p_tnum;
{
	const char *s;
	bool ok;

	s = *p_s;
	if (assume_paren == TRUE || *s == '(') {
	  if (assume_paren == FALSE)
		  bump_str(sr, &s);
		ok = (parse_number(stf, sr, &s, p_fnum) &&
		      bump_str(sr, &s) == ',' &&
		      parse_number(stf, sr, &s, p_tnum) &&
		      bump_str(sr, &s) == ')');
	}
	else {
		*p_fnum = 0;
		ok = parse_number(stf, sr, &s, p_tnum);
	}

	if (ok)
		*p_s = s;
	return ok;
}

bool
char_to_utypecode(c, p_typecode)
int c;
typecode_t *p_typecode;
{
	switch (c) {
	case 's':
		*p_typecode = TY_U_STRUCT;
		break;
	case 'u':
		*p_typecode = TY_U_UNION;
		break;
	case 'e':
		*p_typecode = TY_U_ENUM;
		break;
	default:
		return FALSE;
	}

	return TRUE;
}

/*  BUG: this is gross, and wrong to boot.  The number of basic types
 *       varies between f77 compilers.  See the comment about this
 *       in get_fi_vars().
 */
#define N_FIXED_FORTRAN_TYPES	9

bool
symtab_name_to_sn(snlist, name, prefix, fname, use_allnames, p_sn)
snlist_t *snlist;
const char *name;
const char *prefix;
const char *fname;
bool use_allnames;
snlist_t **p_sn;
{
  snlist_t *sn;
  const char *c;

  for (sn = snlist; sn != NULL; sn = sn->sn_next)
  {
    if (strcmp(sn->sn_name, name) == 0)
    {
      /* RGA for SC4, local statics of the same name in different
	 functions are distinguished by the prefix and mangled function
	 name in the sn_symtab_name.
	 */
      if (use_allnames == TRUE)
      {
	int prefix_len, fname_len;

	prefix_len = strlen(prefix);
	fname_len = strlen(fname);
	c = strchr(sn->sn_symtab_name, '.');
	c++;
	if (c)
	{
	  /* RGA FIXME: first few letters of prefix do not allway match the
	     global prefix, so offset by 3 until we get a better solution.
	     */
	  if ((prefix_len == c - sn->sn_symtab_name) &&
	      strncmp(sn->sn_symtab_name+3, prefix+3, prefix_len-3) == 0 &&
	      strncmp(c, fname, fname_len) == 0)
	  {
	    *p_sn = sn;
	    return TRUE;
	  }
	}
      }
      else
      {
	*p_sn = sn;
	return TRUE;
      }
    }
  }

  return FALSE;
}
bool
symtab_sym_name_to_sn(snlist, name, p_sn, justone)
snlist_t *snlist;
const char *name;
snlist_t **p_sn;
bool justone;
{
	const char* end = strchr(name, ':');
	int len = end ? end-name : strlen(name);

	snlist_t *sn;

	for (sn = snlist; sn != NULL; sn = sn->sn_next) {
          if (   strncmp(sn->sn_symtab_name, name, len) == 0
	      && strlen(sn->sn_symtab_name) == len) {
			*p_sn = sn;
			return TRUE;
		}
		if ( justone)
		   break;
	}

	return FALSE;
}

/*  Do a prescan of a symbol table.  We don't load in all of the symbol
 *  table on startup as that costs a lot in startup time for big symbol
 *  tables.  Instead we load enough to get us going (basically function
 *  and global variable names and addresses) and pull other bits in as
 *  needed.  This is a big win in normal use because the average debugger
 *  run touches only a small number of functions and global variables.
 *  Most of the symbol table is never read in at all.
 *
 *  The Sun C compiler has a system for reducing symbol table size by
 *  only including header file symbol table information once.  We have
 *  to do a fair amount of bookkeeping to resolve the header file
 *  references.
 *
 *  For most things that we load in this pass (like functions, global
 *  variables etc) we record the symbol number range of the object.
 *  This is so we can pull in more information when needed (e.g. the
 *  local variables of a function, the globals of a source file).
 */
void
scan_symtab(st, path, stf, p_flist, p_mainfunc_name)
symtab_t *st;
const char *path;
stf_t *stf;
func_t **p_flist;
const char **p_mainfunc_name;
{
    static int first_call = TRUE;
    static char aout_symset[SYMSET_SIZE], ofile_symset[SYMSET_SIZE];
    char *symset;
    snlist_t *sn;
    block_t *rootblock;
    fil_t *solfil;
    symio_t *symio;
    Symrec symrec;
    nlist_t nm;
    hf_t *headers, *hf;
#ifdef AO_ELF
    off_t file_offset, next_file_offset;
    const char* next_global_prefix = NULL;
#endif
    Compiler_type next_compiler = CT_UNKNOWN;
    bool          set_compiler = FALSE;

    hf_t **fmap, **istack;
    ao_stdata_t *ast;
    func_t *curfunc, *flist;
    funclist_t* new_functlist;
    funclist_t** e_new_functlist;
    const char *name = 0, *mainfunc_name, *path_hint, *cptr;
    char *cptr2, *end;
    int symno;
    unsigned sline_offset;
    int isp, istack_size, mapsize, max_mapsize, nsyms, doing_header;
    alloc_pool_t *ap, *tmp_ap;
    bool seen_func, doing_ofile;
#ifdef OS_ULTRIX
    int last_data_symno, have_unused_datasym;
    nlist_t data_nm;
    const char *lastname;
#endif

    doing_ofile = stf != NULL;

    if (first_call) {
	build_symset(aout_symset, ofile_symset);
	first_call = FALSE;
    }

    ast = AO_STDATA(st);
    flist = NULL;
    curfunc = NULL;
    new_functlist = NULL;
    e_new_functlist = &new_functlist;
    rootblock = get_rootblock();
    doing_header = 0;
    headers = NULL;

#ifdef OS_ULTRIX
    /*  FRAGILE CODE
     *
     *  The Ultrix C compiler has a charming habit of correcting
     *  itself over symbol addresses.  A symbol table frequently
     *  has an N_DATA symbol with one address, followed soon
     *  after by an N_STSYM for the same symbol name with a slightly
     *  different address.  The N_DATA address is the correct one.
     *
     *  To cope with this, we remember the symbol number of N_DATA
     *  symbols, and correct the N_STSYM address if necessary.
     *
     *  The compiler also tends to put out N_DATA symbols immediately
     *  after N_STSYM symbols, but in these cases the addresses
     *  seem to always be the same.
     */
    have_unused_datasym = FALSE;
    last_data_symno = 0; /* to satisfy gcc */
#endif

#ifdef AO_ELF
    file_offset = next_file_offset = 0;
#endif

    max_mapsize = 32;
    fmap = (hf_t **) e_malloc(max_mapsize * sizeof(hf_t *));

    isp = 0;
    istack_size = 8;
    istack = (hf_t **) e_malloc(istack_size * sizeof(hf_t *));

    symno = -1;
    path_hint = NULL;
    seen_func = 0; /* to satisfy gcc */
    ap = st->st_apool;
    tmp_ap = alloc_create_pool();
    mainfunc_name = NULL;
    solfil = NULL;
    sline_offset = 0;

    if (doing_ofile) {
#ifdef AO_ELF
	symio = stf->stf_symio;
#else
	panic("doing_ofile set for non-ELF file in ss");
	symio = NULL;	/* to satisfy gcc */
#endif

	symset = ofile_symset;
	stf->stf_fnum = 0;
	fmap[0] = (hf_t *) alloc(ap, sizeof(hf_t));
	fmap[0]->hf_stf = stf;
	fmap[0]->hf_id = -1;
	fmap[0]->hf_next = NULL;
	mapsize = 1;
    }
    else {
	symset = aout_symset;
	symio = ast->st_text_symio;

	mapsize = 0; /* for lint */
    }

    nsyms = get_symio_nsyms(symio);

    for (symno = findsym(symio, symno + 1, &nm, symset);;
	 symno = next_unmarked_sym(symio, symno + 1)) {

	symno = findsym(symio, symno, &nm, symset);

	if (symno >= nsyms)
	    break;

	cptr2 = 0;
	switch(nm.n_type) {
	    const char *symtab_name;
	    language_t lang;
#ifdef AO_ELF
	    bool has_debug_syms;
#endif

#ifdef AO_ELF
	case N_ILDPAD:
	    next_file_offset += nm.n_value;
	    break;
	case N_UNDF:
	    file_offset = next_file_offset;
	    next_file_offset = file_offset + nm.n_value;

	    add_extra_string_offset(symio, symno, file_offset);
	    break;
#endif

#ifdef N_MAIN
	case N_MAIN:
	    mainfunc_name = symstring(symio, symno);
	    break;
#endif

	case N_SO:
	    solfil = NULL;
	    sline_offset = 0;

#ifdef COFF_SUN386
	    /*  The Sun 386i C compiler seems to put out
	     *  spurious N_SO symbols for functions.
	     *  The bad ones all seem to have a non zero
	     *  n_dbx_desc field, so skip these.
	     */
	    if (nm.n_dbx_desc != 0)
		    break;
#endif /* COFF_SUN386 */
	    if (curfunc != NULL) {
		    AO_FSYMDATA(curfunc)->fs_symlim = symno;
		    curfunc = NULL;
	    }
	    if (stf != NULL)
		    stf->stf_symlim = symno;

	    name = symstring(symio, symno);

	    /*  4.0 cc puts paths ending in '/' just before
	     *  the source files that follow.
	     */
	    if (!name || *name == '\0' || name[strlen(name) - 1] == '/') {
		    path_hint = name;
		    break;
	    }

	    if (stf != NULL) {
		    wrapup_stf(stf, fmap, mapsize);
		    reverse_stf_funclist(stf);
	    }

#ifndef AO_ELF
	    if (strcmp(name, "libg.s") == 0) {
		    stf = NULL;
		    break;
	    }
#endif

	    if (name && *name == '.' && *(name+1) == '/') /* RGA */
		    name += 2;
	    lang = srctype(name);
#ifdef OS_SUNOS_4
	    /*  F77 files can be compiled with the f90 compiler,
	     *  so try and work out from the symbol table which
	     *  was used.
	     */
	    if (IS_FORTRAN(lang)) {
		const char *s;

		s = symstring(symio, symno + 1);

		if (strncmp(s, "byte:", 5) == 0) {
		    lang = LANG_F90;
		}
		else if (strncmp(s, "integer*2:", 10) == 0) {
		    lang = LANG_F77;
		}
	    }
#endif

	    stf = make_stf(ap, name, st, symno, lang, nm.n_value);
#ifdef AO_ELF
	    stf->stf_symio = symio;
#endif
	    st->st_sfiles = make_fil(stf, rootblock, path_hint, st->st_sfiles);
#ifndef OS_LINUX
	    if (!path_hint && lang == LANG_CC)
		    /* RGA g++ puts out empty names so hide such files  */
		    st->st_sfiles->fi_flags |= FI_HIDE_ENTRY;
#endif

	    set_compiler = next_compiler != CT_UNKNOWN;

	    if ( set_compiler )
	    {
		    stf->stf_compiler_type = next_compiler;
		    st->st_sfiles->fi_flags |= FI_FOUND_COMPILER;
		    next_compiler = CT_UNKNOWN;
#ifdef AO_ELF
		    stf->stf_global_prefix = next_global_prefix;
		    next_global_prefix = NULL;
#endif
	    }

	    doing_header = 0;
	    stf->stf_fil = st->st_sfiles;

	    if (isp != 0)
	    {
		    errf_ofunc_t oldf;

		    oldf = errf_set_ofunc(display_message);
		    errf("unmatched N_BINCL symbol in %s (%s)", path, name);
		    errf_set_ofunc(oldf);
		    isp = 0;
	    }

	    stf->stf_fnum = 0;
	    fmap[0] = (hf_t *) alloc(ap, sizeof(hf_t));
	    fmap[0]->hf_stf = stf;
	    fmap[0]->hf_id = -1;
	    fmap[0]->hf_next = NULL;
	    mapsize = 1;
	    path_hint = NULL;
	    seen_func = FALSE;
	    symset[N_SLINE] = TRUE;
#ifdef OS_ULTRIX
	    have_unused_datasym = FALSE;
#endif
	    break;

	case N_SOL:
	    /*  Names are relative to the last N_SO, so we need one.
	     */
	    if (stf == NULL)
		    break;

	    name = symstring(symio, symno);

	    if (name && *name == '.' && *(name+1) == '/')
		    name += 2;
	    solfil = add_sol_fil(stf, ap, st->st_sfiles, stf->stf_fil, name); 

	    if (solfil == stf->stf_fil)
		    solfil = NULL;

	    /*
	     * If we were able to determine the compiler,
	     * set FI_FOUND_COMPILER flag
	     */
	    if (solfil && set_compiler) {
		    solfil->fi_flags |= FI_FOUND_COMPILER;
	    }

	    if (curfunc != NULL && solfil != NULL &&
		  (solfil->fi_funclist == NULL ||
		   solfil->fi_funclist->fl_func != curfunc))
	    {
		add_to_fil_funclist(ap, solfil, curfunc);
	    }

	    /* RGA Insight puts out these - ignore them */
	    if (strcmp(name, "NoName") == 0)
		break;

	    /*
	     * Make ups work better with cfront (c++).
	     * Is it a something other than a header file ?
	     */
	    if (solfil && name != NULL &&
	        !strstr(name, ".h") &&
	        !strstr(name, ".H") &&
	        !strstr(name, ".hh") &&
	        !strstr(name, ".idl") &&
	        !strstr(name, ".icon"))
	    {
		/*
		 * Not a header.
		 */
		if (solfil->fi_language == LANG_UNKNOWN)
		    solfil->fi_flags |= FI_RENAMED_OTHER;

		if (!(st->st_sfiles->fi_flags & FI_RENAMED_OTHER) &&
		    (!strrchr(name, '/') ||
		     (st->st_sfiles->fi_language != srctype(stf->stf_name) &&
		      strrchr(stf->stf_name, '.'))))
		  /* ignore bogus files with no extension */
		{
		    if (st->st_sfiles->fi_language == LANG_C &&
			solfil->fi_language == LANG_CC)
		    {
			/*
			 * C++ -> C, so looks like it is out of cfront.
			 * Use first file renamed by cfront.
			 */
			st->st_sfiles->fi_flags |= FI_RENAMED_OTHER;
			st->st_sfiles->fi_name = solfil->fi_name;
			st->st_sfiles->fi_name_only = solfil->fi_name_only;
			st->st_sfiles->fi_language = LANG_CC;
		    }
		    else if ((st->st_sfiles->fi_language != solfil->fi_language) &&
			   (solfil->fi_language != LANG_UNKNOWN))
		    {
			/*
			 * Some other pre-processor, e.g. f2c.
			 */
			st->st_sfiles->fi_name = solfil->fi_name;
			st->st_sfiles->fi_name_only = solfil->fi_name_only;
			st->st_sfiles->fi_language = solfil->fi_language;
		    }
		    doing_header = 0;
		}
		else
		    doing_header = 0;
	    }
	    else
	    {
		/* Is a header. */
		if (solfil != NULL)
		    solfil->fi_flags |= FI_HEADER;
		doing_header = 1;
	    }
	    break;

#ifdef AO_ELF
	case N_OPT:
	    /* RCB:  Gnu outputs the N_OPT before the
	    **  N_SO, so we have to save the data
	    **  until we get the N_SO record.
	    */

	    cptr = symstring(symio, symno);

	    if (cptr== NULL)
		break;

	    elf_handle_optsym(ap, cptr,
			      stf ? &stf->stf_language : NULL,
			      &next_global_prefix,
			      &next_compiler,
			      &has_debug_syms);
	    if (stf && !set_compiler)
	    {
		stf->stf_compiler_type = next_compiler;
		stf->stf_global_prefix = next_global_prefix;
		stf->stf_obj_mtime = nm.n_value;
		next_compiler = CT_UNKNOWN;
		next_global_prefix = NULL;
	    }
	    break;
#endif

	case N_SLINE:
	    if (!seen_func && stf != NULL)
		    stf->stf_flags |= STF_LNOS_PRECEDE_FUNCS;
	    symset[N_SLINE] = FALSE;
	    break;

#ifdef N_XLINE
	case N_XLINE:
	    sline_offset = nm.n_desc << 16;
	    break;
#endif

#ifdef N_BINCL
	case N_BINCL:
	case N_EXCL:
	    if (stf == NULL)
		    panic("header outside source file in ss");

	    if (mapsize == max_mapsize) {
		    max_mapsize *= 2;
		    fmap = (hf_t **) e_realloc((char *)fmap,
				    max_mapsize * sizeof(hf_t *));
	    }

	    if (nm.n_type == N_EXCL) {
		    hf = lookup_hf(headers, (int)nm.n_value);
		    fmap[mapsize++] = hf;
		    break;
	    }

	    if (isp == istack_size) {
		    istack_size *= 2;
		    istack = (hf_t **) e_realloc((char *)istack,
				    istack_size * sizeof(hf_t *));
	    }

	    istack[isp] = (hf_t *) alloc(ap, sizeof(hf_t));

	    istack[isp]->hf_next = headers;
	    headers = istack[isp++];

	    name = alloc_strdup(ap, symstring(symio, symno));
	    headers->hf_stf = make_stf(ap, name, st, symno,
				       st->st_sfiles->fi_language,
				       nm.n_value);

	    /* RCB: Copy the known compiler info to the header file */
	    headers->hf_stf->stf_compiler_type = stf->stf_compiler_type;

	    if (nm.n_type == N_EXCL) {
		    headers->hf_stf->stf_fil = NULL;
	    }
	    else {
		    headers->hf_stf->stf_fil =
				    make_fil(headers->hf_stf,
					     (block_t *)NULL,
					     (const char *)NULL,
					     (fil_t *)NULL);
		    if (st->st_sfiles->fi_flags &= FI_FOUND_COMPILER)
			headers->hf_stf->stf_fil->fi_flags |= FI_FOUND_COMPILER;
	    }

	    doing_header = 0;
	    headers->hf_stf->stf_fnum = mapsize;
	    headers->hf_id = nm.n_value;
	    fmap[mapsize++] = headers;
	    break;

	case N_EINCL:
	    if (isp == 0)
		    panic("unmatched N_EINCL");

	    --isp;
	    istack[isp]->hf_stf->stf_symlim = symno;

	    if (!doing_ofile)
		    reverse_stf_funclist(stf);
	    break;
#endif /* N_BINCL */

	case N_STSYM:
	case N_GSYM:
	case N_LCSYM:
	    /*  We shouldn't get here before stf exists,
	     *  but lets not core dump if we do.
	     */
	    if (stf == NULL)
		    break;

	    if (IS_FORTRAN(stf->stf_language) &&
		symno - stf->stf_symno <= N_FIXED_FORTRAN_TYPES)
		    break;

	    cptr = symstring(symio, symno);

	    /* RGA have seen this with SC4 with templates */
	    while (*cptr==';')
	      cptr++;

	    /* RGA have seen this with SunOS/centerline */
	    if (*cptr == 0 || (*cptr  && *cptr==' '))
		break;

	    /* RGA have seen this with SC4.2 with templates */
	    if (*cptr != ':' && *cptr != '?' && !isalpha(*cptr) &&
		*cptr != '_' &&
		*cptr != '$' && *cptr != '.')
		break;

	    symrec.symio = symio;
	    symrec.symno = symno;
#if 0
	/* RGA SC4.2 folds lines at 400. Can't find a define for */
	/* this, so using an ugly number at present... */
	      {
		size_t len;

		len = strlen(cptr);
		end = (char *)cptr + len - 1;
		if (len == 401 && *end == '\\')
		{
		  cptr2 = e_malloc(len + 1);
		  memcpy((void *)cptr2, cptr, len + 1);
		  cptr = cptr2;
		}
		if (len == 401)
		  while (*end == '\\')
		  {
		    char *s1;
		    size_t new_len;

		    s1 = (char *)get_cont_symstring(&symrec);
		    mark_sym(symio, symrec.symno);
		    new_len = strlen(s1);
		    cptr2 = (char *)e_realloc((void *)cptr2, len + new_len);
		    cptr = cptr2;
		    memcpy((void *)(cptr2 + len - 1), s1, new_len);
		    cptr2[len + new_len - 1] = 0;
		    len += new_len - 1;
		    end = (char *)cptr + len - 1;
		    if (new_len != 401)
		      break;
		  }
	      }
#endif
#if 1
	    /* Check for continuation characters in the name */
	    {
		size_t len;

		len = strlen(cptr);
		end = (char *)cptr + len - 1;
		if (*end == '\\')
		{
		    cptr2 = e_malloc(len + 1);
		    memcpy((void *)cptr2, cptr, len + 1);
		    cptr = cptr2;
		}
		while (*end == '\\')
		{
		    char *s1;
		    size_t new_len;

		    s1 = (char *)get_cont_symstring(&symrec);
		    /* symno = symrec.symno;   No!  */
		    mark_sym(symio, symrec.symno);
		    new_len = strlen(s1);
		    cptr2 = (char *)e_realloc((void *)cptr2, len + new_len);
		    cptr = cptr2;
		    memcpy((void *)(cptr2 + len - 1), s1, new_len);
		    cptr2[len + new_len - 1] = 0;
		    len += new_len - 1;
		    end = (char *)cptr + len - 1;
		}
	    }
#endif
	    symtab_name = cptr;

#ifdef AO_ELF
	    if (doing_ofile) {
		if (symtab_sym_name_to_sn(stf->stf_snlist,
				      symtab_name, &sn, FALSE)) {
			sn->sn_symno = symno;
			break;
		}

		/*  The Sun cc (SPARCompiler 3.0) leaves a
		 *  few symbols out of the .stab.index
		 *  section in the linked file, so don't
		 *  complain about extra symbols - just
		 *  silently add them.  These symbols always
		 *  seem to be local static variables in an
		 *  inner block scope, but I can't reproduce
		 *  this with a small test case.
		 */
	    }

	    /*  SPARCompiler 3.0 sometimes emit duplicate
	     *  symbols, of which the first seems to be bogus.
	     *  For example, there are two entries for
	     *  file_string in the symbol table for
	     *  test/C/core/f.c.
	     *
	     *  Just ignore the first one.
	     */
	    if (symtab_sym_name_to_sn(stf->stf_snlist,
					  symtab_name, &sn, TRUE)) {
		    sn->sn_symno = symno;
		    break;
	    }

#endif

	    sn = push_symname(&symrec,ap, stf, cptr, symno);

#ifdef OS_ULTRIX
	    sn->sn_addr = 0;

	    if (have_unused_datasym) {
		lastname = symstring(symio, last_data_symno);

		if (*lastname == '_' &&
		    strcmp(lastname + 1, sn->sn_name) == 0) {
			getsym(symio, last_data_symno, &data_nm);
			sn->sn_addr = data_nm.n_value;
		}
		have_unused_datasym = FALSE;
	    }
#endif
	    break;

	case N_FUN:
	    name = symstring(symio, symno);

	    /*  Some compilers (e.g. gcc) put read only strings
	     *  in the text segment, and generate N_FUN symbols
	     *  for them.  We're not interested in these here.
	     */
	    if ((cptr = strchr(name, ':')) == NULL ||
		(cptr[1] != 'F' && cptr[1] != 'f'))
		    break;

#if defined(OS_SUNOS)
	    /* (IDE) Caused problems with C++ SC 4.2 on Sun. */
#else
	    /*  (IDE) On FreeBSD 3.0 getting two N_FUN for each
	     *  function - 1st has PSYM and SLINE after it, 2nd
	     *  repeats the PSYMs and has all other types.
	     *   RCB: Added test for nm.n_value!=0
	     */
	    if ((curfunc != NULL)
		&& (curfunc->fu_addr == nm.n_value)
		&& nm.n_value!=0 )
	    {
		    stf->stf_flags |= STF_FUNCS_REPEATED;
		    break;
	    }
#endif

	    /*  Close previous function.
	     */
	    if (curfunc != NULL) {
		    AO_FSYMDATA(curfunc)->fs_symlim = symno;
		    curfunc = NULL;
	    }

	    seen_func = TRUE;

#ifdef AO_ELF
	    if (doing_ofile) {
		    curfunc = note_ofile_function(ap, ap, stf,
						  path, solfil,
						  sline_offset,
						  name, symno,
						  e_new_functlist);
		      
		    if ( *e_new_functlist )
			e_new_functlist = & (*e_new_functlist)->fl_next;
			
		    break;
	    }
#endif
/*#ifdef OS_SUNOS
	    add_function_to_symtab
		  (st, &flist, name,
		   (st->st_sfiles->fi_language == LANG_CC && headers &&
		    headers->hf_stf) ? headers->hf_stf->stf_fil:
		   st->st_sfiles, solfil, cptr[1] == 'f', FALSE,
		   symno, nm.n_value);
#else*/
	    add_function_to_symtab(st, &flist, name,
				   st->st_sfiles, solfil,
				   cptr[1] == 'f', FALSE,
				   symno, nm.n_value);
/*#endif*/
	    AO_FSYMDATA(flist)->fs_initial_sline_offset = sline_offset;

	    /* RGA */
	    if (doing_header && flist->fu_language == LANG_CC)
		    flist->fu_flags |= FU_NOTHEADER;

	    curfunc = flist;

	    if (is_fortran_void(cptr))
		    curfunc->fu_type = ci_code_to_type(TY_VOID);
	    break;

	case N_TEXT:
	case N_TEXT | N_EXT:
	    name = symstring(symio, symno);

	    /*  Some compilers put N_TEXT symbols out with object
	     *  file names, often with the same addresses as real
	     *  functions.  We don't want these.
	     *
	     *  We also don't want N_TEXT symbols which immediately
	     *  follow an N_FUN symbol with the same address.
	     */
	    if (nm.n_type == N_TEXT) {
		if (*name != '_') {
#ifndef AO_ELF
		    /* RCB: Try to improve on gross
		    ** get_fi_compiler algorithm
		    */
		    if (next_compiler == CT_UNKNOWN)
		    {
			if (strncmp(name, "gcc_com",7) == 0) 
			    next_compiler = CT_GNU_CC;
			else if (strncmp(name, "gcc2_com",8) == 0) 
			    next_compiler = CT_GNU_CC;
			else if (strncmp(name, "clcc_",5) == 0) 
			    next_compiler = CT_CLCC;
		    }
#endif
		    /*  A .o file symbol is definitely
		     *  the end of the current function,
		     *  if any.
		     */
		    if (curfunc != NULL) {
			    AO_FSYMDATA(curfunc)->fs_symlim = symno;
			    curfunc = NULL;
		    }
		    break;
		}
		if ((curfunc != NULL) && (curfunc->fu_addr == nm.n_value))
			break;
	    }

	    add_function_to_symtab(st, &flist, name,
				   (fil_t *)NULL, (fil_t *)NULL,
				   (nm.n_type & N_EXT) == 0, TRUE, 
				   symno, nm.n_value);

	    /* RGA */
	    if (doing_header && flist->fu_language == LANG_CC)
		flist->fu_flags |= FU_NOTHEADER;

	    /*  You'd expect that we'd close down the current
	     *  function here, but some C compilers put out
	     *  N_TEXT symbols in the middle of the N_SLINE
	     *  symbols for a function.
	     *
	     *  Thus we leave curfunc alone, and rely on an N_SO or
	     *  a .o file N_TEXT to terminate the current
	     *  function.
	     */
	    break;

	case N_DATA:
#ifdef OS_ULTRIX
	    last_data_symno = symno;
	    have_unused_datasym = TRUE;
	    break; /* ? */
#endif
#ifdef ARCH_CLIPPER
	    {
		/*  The Clipper C compiler puts out an N_LCSYM symbol
		 *  with the wrong address for static globals, then
		 *  later puts out an N_DATA with the right address.
		 *  This we keep a list of N_DATA symbols for each
		 *  file so we can check the addresses later.
		 *
		 *  Note that we can't just stick the symbol in the
		 *  global addresses list, as we may have static
		 *  globals with the same name in different files.
		 */
		char *class_name, *name_start;
		int class_len, name_len;

		name = symstring(symio, symno);
		if (*name != '_')
			break;
		name_start = name+1;
		if (get_mangled_name_info
		    (0, name+1, &name_start, &name_len,
		     &class_name, &class_len))
		  name_start[name_len] = 0;
		else
		  name_start = name+1;

		insert_global_addr(ap, &stf->stf_addrlist,
				   name_start, (taddr_t)nm.n_value);
	    }
	    break; /* ? */
#endif
	case N_BSS | N_EXT:
	case N_DATA | N_EXT:
	    {
		char *name_start;

		name = symstring(symio, symno);
#ifndef COFF_SUN386
		if (*name != '_')
			break;
		++name;
#endif
		name_start = (char *)name;
#if 1
		/*  We only want local variables
		**  here if they look like gnu vector tables
		**  Skipping this for other local variables can
		**  save a lot of memory.
		*/
		if (nm.n_type == N_DATA )
		{
		    if (     name[0] != '_' 
			 ||  name[1] != 'v'
			 ||  name[2] != 't'
			 ||( name[3] != '$' && name[3] != '.' ) )
			break;
		}
#endif

		insert_global_addr(ap, &st->st_addrlist, name_start,
				   ast->st_base_address +
						  (taddr_t)nm.n_value);
	    }
	    break;

	case N_BCOMM:
	    symno = push_common_block(st, stf, curfunc, symio, symno);
	    break;

	default:
	    panic("unexpected symbol in init_syms");

	} /* switch nm.ntype */

	if (cptr2)
	    free((void *)cptr2);

    } /* for symno ... */

    if (curfunc != NULL) {
	AO_FSYMDATA(curfunc)->fs_symlim = symno;
	curfunc = NULL;
    }

    if (stf != NULL) {
	wrapup_stf(stf, fmap, mapsize);

	if (!doing_ofile)
	    reverse_stf_funclist(stf);
	else if (new_functlist)
	    stf->stf_fil->fi_funclist = new_functlist;

	stf->stf_symlim = symno;
    }

    free((char *)fmap);
    free((char *)istack);
    alloc_free_pool(tmp_ap);

    if (!doing_ofile)
	*p_flist = flist;

    if (p_mainfunc_name != NULL)
	*p_mainfunc_name = mainfunc_name;
}

snlist_t *push_symname(sr,ap,  stf, sym_name, symno)
Symrec *sr;
alloc_pool_t *ap;
stf_t *stf;
const char *sym_name;
int symno;
{
    /*
    **  RCB: Radically re-wrote to put all calls to
    **       demangle, or to elf_name_from_symtab_name,
    **	     here, instead of in the callers to this routine.
    **
    **	Enter:  sym_name = name as it appears in the symbol table
    **
    **    Create a snlist_t for this symbol.  Determine the
    **	   sn_name = the name as it is known to the user.
    **
    **	Link the snlist_t into the stf, and return it.
    **
    */
    char* cptr;
    const char* end_name = sym_name;
    snlist_t *sn = (snlist_t *)alloc(ap, sizeof(snlist_t));
    sn->sn_symno = symno;
#ifdef OS_ULTRIX
    sn->sn_addr = 0;
#endif

    /* get the end of the name */
    /* ( This would fail if a continuation character occured in
    ** the name.  But the N_DATA records for which this routine
    ** is called tend to be short and do not have continuation chars. )
    */
    parse_name(sr, &end_name, NULL, 0, stf->stf_compiler_type,
	       IS_FORTRAN(stf->stf_language));

    /* copy the name */
    cptr = (char*)alloc(ap, end_name-sym_name+1);
    strncpy(cptr,sym_name,end_name-sym_name);
    cptr[end_name-sym_name] = 0;
    sn->sn_symtab_name = cptr;
#ifdef AO_ELF
    sym_name = elf_name_from_symtab_name
			  (stf->stf_global_prefix, sym_name);
#endif
    /* parse the name again for demangling */
    sn->sn_name = parse_name(sr, &sym_name, ap, 0, stf->stf_compiler_type,
			     IS_FORTRAN(stf->stf_language));

    sn->sn_next = stf->stf_snlist;
    stf->stf_snlist = sn;
    return sn;
}
#endif /* !ST_TE */

#ifdef AO_ELF
static func_t *
note_ofile_function(ap, tmp_ap, stf, path, solfil, sline_offset, namestr, symno, p_fl)
alloc_pool_t *ap, *tmp_ap;
stf_t *stf;
const char *path;
fil_t *solfil;
unsigned sline_offset;
const char *namestr;
int symno;
funclist_t** p_fl;
{
	fil_t *fil = stf->stf_fil;
	funclist_t* fl = NULL;
	funclist_t** plast_fl=&fil->fi_funclist;
	func_t *f = NULL;
	const char *modname, *fname;
	int modsepc;

	/*  RCB:  Added p_fl parameter.  When funct is found, we remove
	 *        it from the original functlist and pass it to the caller,
	 *	  who puts it in a list sorted by symno.  This is because
	 *	  the list as originally built is not sorted in any useful
	 *	  order.
	 */
	modsepc = (fil->fi_language == LANG_F90) ? '$' : '\0';

	parse_fname(tmp_ap, namestr, modsepc, FALSE, &modname, &fname);

	for (fl = fil->fi_funclist; fl != NULL; fl = fl->fl_next)
	{
	    if (strcmp(fl->fl_func->fu_name, fname) == 0)
	    {
	      fsyminfo_t *fs;

	      f = fl->fl_func;
	      fs = AO_FSYMDATA(f);
	      if (fs->fs_symno == 0)
	      {
		fs->fs_symno = symno;
		fs->fs_initial_lno_fil = (solfil != NULL) ? solfil : fil;
		fs->fs_initial_sline_offset = sline_offset;

		if (solfil != NULL)
		  add_to_fil_funclist(ap, solfil, f);
		break;
	      }
	    }
	    plast_fl = &fl->fl_next;
	}
	if ( fl)
	{
	    *plast_fl = fl->fl_next;
	    fl->fl_next = NULL;
	}
	*p_fl = fl;
	return f;
}
#endif /* AO_ELF */

static void
add_to_fil_funclist(ap, fil, f)
alloc_pool_t *ap;
fil_t *fil;
func_t *f;
{
	funclist_t *fl;

	fl = (funclist_t *)alloc(ap, sizeof(funclist_t));
	fl->fl_func = f;
	fl->fl_next = fil->fi_funclist;
	fil->fi_funclist = fl;
}

void
add_function_to_symtab(st, p_flist, namestr, fil, solfil,
		       is_static, is_textsym, symno, addr)
symtab_t *st;
func_t **p_flist;
const char *namestr;
fil_t *fil, *solfil;
bool is_static, is_textsym;
int symno;
taddr_t addr;
{
	fsyminfo_t *fs;
	func_t *f;
	const char *modname, *fname;
	int modsepc;

	modsepc = (fil != NULL && fil->fi_language == LANG_F90) ? '$' : '\0';

	parse_fname(st->st_apool, namestr, modsepc,
		    is_textsym && !is_static, &modname, &fname);

	fs = make_fsyminfo(st->st_apool, symno);

	/*  I put this in as a workaround for a bug (with a fixme
	 *  comment.  Now I can't remember why it was needed.
	 *
	 *  TODO: find out why it was needed, and maybe do something
	 *        better.
	 */
	fs->fs_symlim = 1;

	fs->fs_initial_lno_fil = (solfil != NULL) ? solfil : fil;

	if (fil && fil->fi_language == LANG_CC && solfil &&
	    ao_compiler(fil, FALSE, CT_UNKNOWN) != CT_GNU_CC)
	{
	  f = ci_make_func(st->st_apool, fname, addr, st, solfil, *p_flist);
	  if (!strcmp(f->fu_demangled_name, "__STATIC_CONSTRUCTOR")) 
	  {			 /* static ctor */
	    f->fu_fil = fil;
	    f->fu_language = (fil != NULL) ? fil->fi_language : LANG_UNKNOWN;
	  }
	}
	else
	  f = ci_make_func(st->st_apool, fname, addr, st, fil, *p_flist);
	f->fu_symdata = (char *)fs;
	f->fu_predata = NULL;

	if (fil == NULL) {
		f->fu_flags |= FU_NOSYM | FU_DONE_BLOCKS | FU_DONE_LNOS;
	}
	else {
		add_to_fil_funclist(st->st_apool, fil, f);

		if (solfil != NULL)
			add_to_fil_funclist(st->st_apool, solfil, f);
	}

	if (is_static)
		f->fu_flags |= FU_STATIC;

	if (modname != NULL)
		add_module_function(st, modname, f);

	*p_flist = f;
}


static bool
is_fortran_void(cptr)
const char *cptr;
{
	/*  BUG: should look at the type properly.
	 *       There is no guarantee that type 11 is always void.
	 */
	return strcmp(cptr, ":F11") == 0;
}

/*  Adjust the addresses of all the global variables associated
 *  with source files in flist.  Called when a shared library
 *  mapping address changes across runs of the target.
 */
static void
adjust_fil_vars_addr_base(flist, delta)
fil_t *flist;
long delta;
{
	fil_t *fil;
	var_t *v;

	for (fil = flist; fil != NULL; fil = fil->fi_next) {
		if (AO_FIDATA(fil) == NULL)
			continue;

		AO_FIDATA(fil)->stf_addr += delta;

		if (fil->fi_flags & FI_DONE_VARS) {
			for (v = fil->fi_block->bl_vars;
			     v != NULL;
			     v = v->va_next)
				v->va_addr += delta;
		}
	}
}

/*  Deal with a change in the text offset of a symbol table.  This may
 *  be necessary when re-running the target as shared libraries may be
 *  mapped at different addresses.  It's also necessary when we have
 *  preloaded symbol tables with a nominal offset of zero.
 *
 *  We adjust the following:
 *
 *	function and line number addresses
 *	symbol table address to text file offset
 *	addresses of global variables
 *
 *  We don't change breakpoint addresses here - we do that by removing
 *  and recreating all breakpoints just after starting the target.
 */
void
change_base_address(st, new_addr)
symtab_t *st;
taddr_t new_addr;
{
	long delta;
	ao_stdata_t *ast;

	ast = AO_STDATA(st);
	delta = new_addr - ast->st_base_address;

	if (delta != 0) {
		adjust_addrlist_addr_offset(st->st_addrlist, delta);
		ast->st_addr_to_fpos_offset += delta;
		adjust_functab_text_addr_base(st->st_functab,
					      st->st_funclist, delta);
		adjust_fil_vars_addr_base(st->st_sfiles, delta);
		ast->st_base_address = new_addr;
	}
}


#endif /* AO_TARGET */


int
get_mangled_name_info(var, name, name_start, name_len,
		      class_name, class_len)
     int var;
     char *name;
     char **name_start;
     int *name_len;
     char **class_name;
     int *class_len;
{
  int ret = 0;
  char *t, *n, *start, *end;
  char num_buff[10];

  *class_name = NULL;
  *class_len = 0;
  *name_len = 0;
  start = name;

  if (demangling_enabled(0, 0))
  {
    if (var)
    {
      start = *name_start;
      t = strstr(start, "__");
      if (t && isdigit(*(t + 2)) && t == start)
      {
	ret = 1;
	t += 2;		/* skip "__" */
	while(isdigit(*t))
	  t++;
      }
      else
	t = start;
      *name_start = start = t;
    }
    else
      start = name;
    end = start + strlen(start);
    for (t = start; t && t < end;)
    {
      t = strstr(t, "__");
      if (t)
	if (isdigit(*(t + 2)) || (isalpha(*(t + 2)) && isupper(*(t + 2))))
	{
	  for (*name_len = 0, n = start; n < t; (*name_len)++, n++);
	  if (t && isdigit(*(t + 2)))
	  {
	    if (*(t + 2) == '0')
	    {
	      ret = 2;		/* SC3 mangling */
	      if (isupper(*(t + 3)))
	      {
		*name_start = t + 5;
		if ((int)(*(t + 4) - 'A') > 25)
		  *name_len = (int)(*(t + 4) - 'a') + 26;
		else
		  *name_len = (int)(*(t + 4) - 'A');
		t = *name_start + *name_len;
	      }
	      else
	      {
		if (*(t + 3) == 'd' && isdigit(*(t + 4)))
		{
		  while (!isupper(*(t + 4)) && t + 5 < end) t++;
		  if ((int)(*(t + 4) - 'A') > 0)
		    if ((int)(*(t + 4) - 'A') > 25)
		      t += (int)(*(t + 4) - 'a') + 26 + 1;
		    else
		      t += (int)(*(t + 4) - 'A') + 1;
		}
		if ((int)(*(t + 4) - 'A') > 0)
		{
		  *class_name = t + 5;
		  if ((int)(*(t + 4) - 'A') > 25)
		    *class_len = (int)(*(t + 4) - 'a') + 26;
		  else
		    *class_len = (int)(*(t + 4) - 'A');
		  if (*class_len > end - *class_name)
		    *class_len = end - *class_name;
		  t = *class_name + *class_len;
		  while (isdigit(*t)) /* templates...just skip */
		    t++;
		  *name_start = t + 1;
		  if (*name_start > end)
		    *name_start = start;
		  if ((int)(*(t) - 'A') > 25)
		    *name_len = (int)(*(t) - 'a') + 26;
		  else
		    *name_len = (int)(*(t) - 'A');
		  if (*name_len > end - *name_start)
		    *name_len = end - *name_start;
		  if (*name_len < 0)
		    t = *name_start;
		  else
		  t = *name_start + *name_len;
		}
		else
		{
		  ret = 0;
		  break;
		}
	      }
	    }
	    else
	    {
	      for (*name_len = 0, n = start; n < t; (*name_len)++, n++);
	      if (isdigit(*(t + 2)))
	      {
		t += 2;		/* skip "__" */
		for (n = num_buff; (isdigit(*t)); t++, n++)
		  *n = *t;
		*(n++) = 0;
		*class_name = t;
		*class_len = atoi(num_buff);
		if (t + *class_len > end)
		{
		  *class_name = NULL;
		  *class_len = 0;
		  *name_len = end - *name_start;
		}
	      }
	      ret = 1;
	      break;
	    }
	  }
	  if (!ret)
	    ret = 1;
	  break;
	}
	else
	  ++t;
    }
    if (!(*name_len))
      for(*name_len = 0, t = start; isalnum(*t) || *t == '_';
	  (*name_len)++, t++); 
    if (*name_len < 0)
      *name_len = 0;
  }
  return (ret);
}
#define CONSTRUCTOR 0
#define DESTRUCTOR 1
#define OPERATOR 2
#define OPERATOR_CAST 3

static struct 
{
  const char *mangle_str;
  int   mangle_str_len;
  const char *demangle_str;
  int demangle_str_len;
  int type;
} Mangle_buff[] =
{
  /*  Macro to define an entry in Mangle_buff */
#define MNGL(mgl, dmgl, type) { mgl, sizeof(mgl)-1, dmgl, sizeof(dmgl)-1,type }

  MNGL( "ct",  "",           CONSTRUCTOR),
  MNGL( "dt",  "",           DESTRUCTOR),
  MNGL( "op",  "operator ",   OPERATOR_CAST),
  MNGL( "as",  "operator=",  OPERATOR),
  MNGL( "eq",  "operator==", OPERATOR),
  MNGL( "pl",  "operator+",  OPERATOR),
  MNGL( "mi",  "operator-",  OPERATOR),
  MNGL( "ml",  "operator*",  OPERATOR),
  MNGL( "dv",  "operator/",  OPERATOR),
  MNGL( "md",  "operator%",  OPERATOR),
  MNGL( "er",  "operator^",  OPERATOR),
  MNGL( "ad",  "operator&",  OPERATOR),
  MNGL( "or",  "operator|",  OPERATOR),
  MNGL( "co",  "operator~",  OPERATOR),
  MNGL( "nt",  "operator!",  OPERATOR),
  MNGL( "gt",  "operator>",  OPERATOR),
  MNGL( "lt",  "operator<",  OPERATOR),
  MNGL( "apl", "operator+=", OPERATOR),
  MNGL( "ami", "operator-=", OPERATOR),
  MNGL( "amu", "operator*=", OPERATOR),
  MNGL( "aml", "operator*=", OPERATOR),
  MNGL( "adv", "operator/=", OPERATOR),
  MNGL( "gdv", "operator/=", OPERATOR),
  MNGL( "amd", "operator%=", OPERATOR),
  MNGL( "aer", "operator^=", OPERATOR),
  MNGL( "aad", "operator&=", OPERATOR),
  MNGL( "gad", "operator&=", OPERATOR),
  MNGL( "aor", "operator|=", OPERATOR),
  MNGL( "ls",  "operator<<", OPERATOR),
  MNGL( "rs",  "operator>>", OPERATOR),
  MNGL( "ars", "operator>>=",OPERATOR),
  MNGL( "als", "operator<<=",OPERATOR),
  MNGL( "ne",  "operator!=", OPERATOR),
  MNGL( "le",  "operator<=", OPERATOR),
  MNGL( "ge",  "operator>=", OPERATOR),
  MNGL( "rm",  "operator->*",OPERATOR),
  MNGL( "cm",  "operator,",  OPERATOR),
  MNGL( "mm",  "operator--", OPERATOR),
  MNGL( "pp",  "operator++", OPERATOR),
  MNGL( "oo",  "operator||", OPERATOR),
  MNGL( "aa",  "operator&&", OPERATOR),
  MNGL( "vc",  "operator[]", OPERATOR),
  MNGL( "cl",  "operator()", OPERATOR),
  MNGL( "rf",  "operator->", OPERATOR),
  MNGL( "nw",  "operator new",        OPERATOR),
  MNGL( "dl",  "operator delete",     OPERATOR)
};
#define NMANGLE_STRS (sizeof Mangle_buff / sizeof *Mangle_buff)

char* demangle_name_3(name)
char* name;
{
    /* demangle the input name, returning a malloc'ed string */
    char* dmangle = NULL;
    switch ( ao_compiler(NULL, FALSE, CT_UNKNOWN))
    {
    case CT_GNU_CC:
        dmangle = gnu_cplus_demangle(name, DMGL_GNU);
	break;
    case CT_CLCC:
        dmangle = gnu_cplus_demangle(name, DMGL_ARM);
	break;
    case CT_CC:
      {
#if HAVE_CPLUS_DEMANGLE
	    char buff[512];
	    const char* dmgl = buff;
    	    int ret = sunpro_cplus_demangle(name, buff, 512);
	    if ( ret == DEMANGLE_ESPACE)
		dmgl = name;
	    dmangle = (char*)malloc(strlen(name)+1);
	    strcpy(dmangle, dmgl);
#else
	    int name_len, class_len;
	    char* class_name, *name_start;
	    name_start = (char*)name;     /* cast away const */
	    if ( get_mangled_name_info(0, name_start, &name_start, &name_len,
		      &class_name, &class_len))
	    {
		dmangle = malloc(class_len+name_len+3);
		strncpy(dmangle,class_name,class_len);
		strcpy(dmangle+class_len,"::");
		strncpy(dmangle+class_len+2, name_start, name_len);
		dmangle[class_len+name_len+2] = 0;
	    }
#endif
	break;
      }
    default:
	break;
    }
    return dmangle;
}

void
demangle_name_2(name, len, alloc_id, ptr, func, fil)
     char *name;
     int len;
     alloc_pool_t *alloc_id;
     char **ptr;
     int func;
     fil_t *fil;
{
  /* Dibyendu : when debugging CX executables, demangle_name() does
   * not make sense - so avoid calling it. I am assuming that CT_UNKNOWN
   * is not a valid compiler type - and the default. Ideally CX/CG
   * should get their own type.
   * ao_compiler() is fooled by setting FI_FOUND_COMPILER flag when
   * loading a CX executable (see xc_text.c).
   */
  Compiler_type ct;

  ct = ao_compiler(fil, FALSE, CT_UNKNOWN);
  if (ct == CT_UNKNOWN)
     *ptr = strdup(name);
  else
     demangle_name(name, len, alloc_id, ptr, func, ct);
}

/* RGA for Solaris, you can use the cplus_demangle() function in libC
   by changing the #ifdefs below. This will demangle templates and
   the like for SC4 and above. You need to extract dem.o cafe_dem.o
   from libC.a. E.g.

   ar x /opt/SUNWspro/SC4.0/lib/libC.a dem.o cafe_dem.o

   and add these files to the link, such as the AOOBJS list in
   ups/Makefile.
   */


static  char* demangle_type PROTO((const char** mangled));

void
demangle_name(name, len, alloc_id, ptr, func, compiler)
     char *name;
     int len;
     alloc_pool_t *alloc_id;
     char **ptr;
     int func;
     Compiler_type compiler;
{
  char *class_name, *name_start, tmp = 0, tmp2;
  int class_len, name_len, mangle, index, gnu_destructor = 0;

  name_start = name;
  tmp2 = *(name+len);
  *(name+len)= 0;
  *ptr = NULL;

  if (func == 0 
      && !( compiler == CT_CC || compiler == CT_CLCC)
      && demangling_enabled(0, 0)
      )
  {
    char *result = gnu_cplus_demangle (name, DMGL_ANSI);
    *(name+len) = tmp2;
    if (result == NULL)
    {
      *(name+len) = tmp2;
      *ptr = alloc(alloc_id, len + 1);
      memcpy(*ptr, name, len);
      (*ptr)[len] = '\0';
    }
    else
    {
      len = strlen(result);
      *ptr = alloc(alloc_id, len + 1);
      memcpy(*ptr, result, len);
      (*ptr)[len] = '\0';
      free(result);
    }
    return;
  }
#if HAVE_CPLUS_DEMANGLE
  if (   compiler == CT_CC
      && demangling_enabled(0, 0) )
  {
    char buff[512];
    int ret;
    char* dmgl = buff;
    char* name1 = name;

    /* For field names and some variable names, the sunpro compiler puts an
    ** access level character in front of the mangled name cplus_demangle
    ** is prepared to demangle.  So if the demangle failed and name+1 looks
    ** like a Sunpro mangled name try name+1 instead.
    */
    if (        name[1] == '_'
	     && name[2] == '_'
	     && isupper(name[0])
	     && (name[3] == '0' || name[3] == '1') )
    {
	*dmgl++ = *name1++; /* copy first char incase demangle fails */
    }

    ret = sunpro_cplus_demangle(name1, dmgl, 511);
    /* sunpro's demangler should not report that a function
    ** is static, but it does
    */
    if (ret == 0 && !strncmp(buff, "static ", sizeof("static")))
	dmgl += sizeof("static");
    else if (   ret == DEMANGLE_ENAME )
    {
	dmgl = buff; /* back up to the copied char */
    }
    *(name+len) = tmp2; /* put back the nulled out character */

    if ( ret != DEMANGLE_ESPACE)
    {
      if ( func == 0 )
      {
          /* If there are parameters, cut them off
	  **  But watch out for operator()(...)
          */
          char* params = strchr(buff,'(');
	  if ( params && params[1] == ')' && params[2] == '(')
              params+=2;
          if ( params)
            *params = 0;
  
      }
      else
      {
	  /* cut off the function or class name if the demangler put it in */
	  char* n = strrchr(buff, ':');
	  if (n)
	     dmgl = n+1;
      }
      len = strlen(dmgl);
    }
    else
    {
	 /* Demangled name too long if here.  Just return the mangled name */
	 dmgl = name;
    }
    *ptr = alloc(alloc_id, len + 1);
    memcpy(*ptr, dmgl, len);
    (*ptr)[len] = '\0';
    return;
  }
#endif /* HAVE_CPLUS_DEMANGLE */

  if (*(name+1) == '$' && *name == '_' && *(name+2) == '_')
  {
    /* If the compiler is gnu, we shouldn't get here unless
    ** the compiler is incorrectly determined.  But handle
    ** that just in case
    */
    gnu_destructor = 1;
    *(name+1) = '_';
  }

  mangle = get_mangled_name_info(func==1, name, &name_start, &name_len,
				 &class_name, &class_len);
  if (gnu_destructor)
    *(name+1) = '$';
  if (mangle)
  {
    if (func == 1)		/* variable */
    {
      *ptr = alloc(alloc_id, name_len + 1);
      (void) strncpy(*ptr, name_start, name_len);
      (*ptr)[name_len] = '\0';
    }
    else
    if (mangle == 2 && !class_len) /* SC 3 mangling*/
    {
      if (!strncmp(name_start, "_STCON_", name_len))
      {
	*ptr = alloc(alloc_id, strlen("__STATIC_CONSTRUCTOR") + 1);
	(void) strcpy(*ptr, "__STATIC_CONSTRUCTOR");
      }
      else
	if (!strncmp(name_start, "_STDES_", name_len))
	{
	  *ptr = alloc(alloc_id, strlen("__STATIC_DESTRUCTOR") + 1);
	  (void) strcpy(*ptr, "__STATIC_DESTRUCTOR");
	}
	else
	{
	  *ptr = alloc(alloc_id, name_len + 1);
	  (void) strncpy(*ptr, name_start, name_len);
	  (*ptr)[name_len] = '\0';
	}
    }
    else
    {				/* function name */
      if (name_len <= len)
	tmp = *(name+name_len);
      if (mangle != 2)
	*(name+name_len) = 0;
      if (gnu_destructor)
      {
	*ptr = alloc(alloc_id, 2*class_len + 4);
	memcpy(*ptr, class_name, class_len);
	memcpy(*ptr+class_len, "::", 2);
	class_len += 2;
	*(*ptr+class_len) = '~';
	memcpy(*ptr+class_len+1, *ptr, class_len-2);
	(*ptr)[class_len+class_len-1] = 0;
      }
      else
	if (class_name && !strncmp(name, "__", 2))
	{
	  if (mangle == 1 && isdigit(*(name + 2)))
	  {			/* g++ constructor */
	    *ptr = alloc(alloc_id, 2*class_len + 3);
	    memcpy(*ptr, class_name, class_len);
	    memcpy(*ptr+class_len, "::", 2);
	    class_len += 2;
	    memcpy(*ptr+class_len, *ptr, class_len - 2);
	    (*ptr)[class_len+class_len-2] = 0;
	  }
	  else
	  {
	    const char* mangled_op =
	       (mangle == 2 )
	       ? class_name + class_len
	       : name+2;
	    for (index = 0; !*ptr && index < NMANGLE_STRS; index++)
	    {
	      if (!strncmp( mangled_op
			  , Mangle_buff[index].mangle_str
			  , Mangle_buff[index].mangle_str_len))
	      {
		switch (Mangle_buff[index].type)
		{
		case CONSTRUCTOR:
		  *ptr = alloc(alloc_id, 2*class_len + 3);
		  memcpy(*ptr, class_name, class_len);
		  memcpy(*ptr+class_len, "::", 2);
		  class_len += 2;
		  memcpy(*ptr+class_len, *ptr, class_len - 2);
		  (*ptr)[class_len+class_len-2] = 0;
		  break;
		case DESTRUCTOR:
		  *ptr = alloc(alloc_id, 2*class_len + 4);
		  memcpy(*ptr, class_name, class_len);
		  memcpy(*ptr+class_len, "::", 2);
		  class_len += 2;
		  *(*ptr+class_len) = '~';
		  memcpy(*ptr+class_len+1, *ptr, class_len-2);
		  (*ptr)[class_len+class_len-1] = 0;
		  break;
		case OPERATOR:
		  *ptr = alloc(alloc_id, class_len +
			       Mangle_buff[index].demangle_str_len + 3);
		  memcpy(*ptr, class_name, class_len);
		  memcpy(*ptr+class_len, "::", 2);
		  class_len += 2;
		  memcpy(*ptr+class_len,
			 Mangle_buff[index].demangle_str,
			 Mangle_buff[index].demangle_str_len);
		  (*ptr)[class_len+Mangle_buff[index].demangle_str_len] = 0;
		  break;
		case OPERATOR_CAST:
		 {
		   /* point to end of string parsed so far: */
		   const char* ptype = mangled_op+Mangle_buff[index].mangle_str_len;
		   /* Use the gnu demangler to demangle the type */
		   char* type = demangle_type(&ptype);
		   if ( type )
		      ptype = type;
		   else
		      ptype = "";

		   /* gnu doesn't know about SC 3.  Fix that: */
		   if ( mangle ==2 && isupper(*ptype))
		      ptype++;

		   *ptr = alloc(alloc_id, class_len +
			       Mangle_buff[index].demangle_str_len + 3 +strlen(ptype));
		   memcpy(*ptr, class_name, class_len);
		   memcpy(*ptr+class_len, "::", 2);
		   class_len += 2;
		   memcpy(*ptr+class_len,
			 Mangle_buff[index].demangle_str,
			 Mangle_buff[index].demangle_str_len);
		   (*ptr)[class_len+Mangle_buff[index].demangle_str_len] = 0;
		   strcat(*ptr,ptype);
		   if ( type )
		      free(type);
		 }
		}
	      }
	    }
	  }
	}
      if (!*ptr)
      {
	if (mangle == 2)		/* SC 3 mangling*/
	{
	  *ptr = alloc(alloc_id, class_len + name_len + 3);
	  memcpy(*ptr, class_name, class_len);
	  memcpy(*ptr + class_len, "::", 2);
	  class_len += 2;
	  memcpy(*ptr + class_len, name_start, name_len);
	  (*ptr)[class_len+name_len] = 0;
	}
	else
	{
	  if (class_name)
	  {
	    *ptr = alloc(alloc_id, class_len + name_len + 3);
	    memcpy(*ptr, class_name, class_len);
	    memcpy(*ptr+class_len, "::", 2);
	    class_len += 2;
	  }
	  else
	    *ptr = alloc(alloc_id, class_len + name_len + 1);
	  if (name_len <= len)
	    name[name_len] = tmp;
	  memcpy(*ptr+class_len, name, name_len);
	  (*ptr)[class_len+name_len] = 0;
	}
      }
      if (name_len <= len)
	*(name+name_len) = tmp;
    }
    *(name+len) = tmp2;
  }
  else
  {
    if (!strncmp(name, "__sti__", 7))
    {
      *ptr = alloc(alloc_id, strlen("__STATIC_CONSTRUCTOR") + 1);
      (void) strcpy(*ptr, "__STATIC_CONSTRUCTOR");
    }
    else
      if (!strncmp(name, "__std__", 7))
      {
	*ptr = alloc(alloc_id, strlen("__STATIC_DESTRUCTOR") + 1);
	(void) strcpy(*ptr, "__STATIC_DESTRUCTOR");
      }
      else
      {
	*(name+len) = tmp2;
	*ptr = alloc(alloc_id, len + 1);
	memcpy(*ptr, name, len);
	(*ptr)[len] = '\0';
      }
  }
}

int
demangling_enabled(set, reset)
     int set;
     int reset;
{
  static int enabled = 1;

  if (set)
    enabled = 1;
  if (reset)
    enabled = 0;
  return(enabled);
}



/***********************************************************************/
/*                                                                     */
/*  GNU demangle, obtained from www.cygnus.com                         */
/*  cplus-dem.c  ( to find, search for "cplus" )                       */
/*                                                                     */
/***********************************************************************/

/*  Some preliminary #defines to get the Gnu code to compile */

/* define away gnu malloc routines */
#define xmalloc malloc
#define xrealloc realloc

/* Rename the exported routines to not colide with standard library */
#define cplus_demangle gnu_cplus_demangle

/* Turn off compiling of stuff we don't use */
#define COMPILE_UNUSED 0


/*  Set up the function prototype macro */
#ifdef __STDC__
#define PARAMS(stuff) stuff
#else
#define PARAMS(stuff) ()
#endif

/* Demangler for GNU C++ 
   Copyright 1989, 91, 94, 95, 96, 97, 1998 Free Software Foundation, Inc.
   Written by James Clark (jjc@jclark.uucp)
   Rewritten by Fred Fish (fnf@cygnus.com) for ARM and Lucid demangling
   Modified by Satish Pai (pai@apollo.hp.com) for HP demangling

This file is part of the libiberty library.
Libiberty is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

Libiberty is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with libiberty; see the file COPYING.LIB.  If
not, write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.  */

/* This file exports two functions; cplus_mangle_opname and cplus_demangle.

   This file imports xmalloc and xrealloc, which are like malloc and
   realloc except that they generate a fatal error if there is no
   available memory.  */


/* This file lives in both GCC and libiberty.  When making changes, please
   try not to break either.  */

#undef CURRENT_DEMANGLING_STYLE
#define CURRENT_DEMANGLING_STYLE work->options

/*extern char *xmalloc PARAMS((unsigned)); */
/*extern char *xrealloc PARAMS((char *, unsigned)); */

static const char *mystrstr PARAMS ((const char *, const char *));

static const char *
mystrstr (s1, s2)
     const char *s1, *s2;
{
  register const char *p = s1;
  register int len = strlen (s2);

  for (; (p = strchr (p, *s2)) != 0; p++)
    {
      if (strncmp (p, s2, len) == 0)
	{
	  return (p);
	}
    }
  return (0);
}

/* In order to allow a single demangler executable to demangle strings
   using various common values of CPLUS_MARKER, as well as any specific
   one set at compile time, we maintain a string containing all the
   commonly used ones, and check to see if the marker we are looking for
   is in that string.  CPLUS_MARKER is usually '$' on systems where the
   assembler can deal with that.  Where the assembler can't, it's usually
   '.' (but on many systems '.' is used for other things).  We put the
   current defined CPLUS_MARKER first (which defaults to '$'), followed
   by the next most common value, followed by an explicit '$' in case
   the value of CPLUS_MARKER is not '$'.

   We could avoid this if we could just get g++ to tell us what the actual
   cplus marker character is as part of the debug information, perhaps by
   ensuring that it is the character that terminates the gcc<n>_compiled
   marker symbol (FIXME).  */

#if !defined (CPLUS_MARKER)
#define CPLUS_MARKER '$'
#endif

enum demangling_styles current_demangling_style = gnu_demangling;

static char cplus_markers[] = { CPLUS_MARKER, '.', '$', '\0' };

static char char_str[2] = { '\000', '\000' };

#if COMPILE_UNUSED
static void
set_cplus_marker_for_demangling (ch)
     int ch;
{
  cplus_markers[0] = ch;
}
#endif /* COMPILE_UNUSED */

typedef struct string		/* Beware: these aren't required to be */
{				/*  '\0' terminated.  */
  char *b;			/* pointer to start of string */
  char *p;			/* pointer after last character */
  char *e;			/* pointer after end of allocated space */
} string;

/* Stuff that is shared between sub-routines.
   Using a shared structure allows cplus_demangle to be reentrant.  */

struct work_stuff
{
  int options;
  char **typevec;
  char **ktypevec;
  char **btypevec;
  int numk;
  int numb;
  int ksize;
  int bsize;
  int ntypes;
  int typevec_size;
  int constructor;
  int destructor;
  int static_type;	/* A static member function */
  int temp_start;       /* index in demangled to start of template args */   
  int type_quals;       /* The type qualifiers.  */
  int dllimported;	/* Symbol imported from a PE DLL */
  char **tmpl_argvec;   /* Template function arguments. */
  int ntmpl_args;       /* The number of template function arguments. */
  int forgetting_types; /* Nonzero if we are not remembering the types
			   we see.  */
  string* previous_argument; /* The last function argument demangled.  */
  int nrepeats;         /* The number of times to repeat the previous
			   argument.  */
};

#define PRINT_ANSI_QUALIFIERS (work -> options & DMGL_ANSI)
#define PRINT_ARG_TYPES       (work -> options & DMGL_PARAMS)

static const struct optable
{
  const char *in;
  const char *out;
  int flags;
} optable[] = {
  {"nw",	  " new",	DMGL_ANSI},	/* new (1.92,	 ansi) */
  {"dl",	  " delete",	DMGL_ANSI},	/* new (1.92,	 ansi) */
  {"new",	  " new",	0},		/* old (1.91,	 and 1.x) */
  {"delete",	  " delete",	0},		/* old (1.91,	 and 1.x) */
  {"vn",	  " new []",	DMGL_ANSI},	/* GNU, pending ansi */
  {"vd",	  " delete []",	DMGL_ANSI},	/* GNU, pending ansi */
  {"as",	  "=",		DMGL_ANSI},	/* ansi */
  {"ne",	  "!=",		DMGL_ANSI},	/* old, ansi */
  {"eq",	  "==",		DMGL_ANSI},	/* old,	ansi */
  {"ge",	  ">=",		DMGL_ANSI},	/* old,	ansi */
  {"gt",	  ">",		DMGL_ANSI},	/* old,	ansi */
  {"le",	  "<=",		DMGL_ANSI},	/* old,	ansi */
  {"lt",	  "<",		DMGL_ANSI},	/* old,	ansi */
  {"plus",	  "+",		0},		/* old */
  {"pl",	  "+",		DMGL_ANSI},	/* ansi */
  {"apl",	  "+=",		DMGL_ANSI},	/* ansi */
  {"minus",	  "-",		0},		/* old */
  {"mi",	  "-",		DMGL_ANSI},	/* ansi */
  {"ami",	  "-=",		DMGL_ANSI},	/* ansi */
  {"mult",	  "*",		0},		/* old */
  {"ml",	  "*",		DMGL_ANSI},	/* ansi */
  {"amu",	  "*=",		DMGL_ANSI},	/* ansi (ARM/Lucid) */
  {"aml",	  "*=",		DMGL_ANSI},	/* ansi (GNU/g++) */
  {"convert",	  "+",		0},		/* old (unary +) */
  {"negate",	  "-",		0},		/* old (unary -) */
  {"trunc_mod",	  "%",		0},		/* old */
  {"md",	  "%",		DMGL_ANSI},	/* ansi */
  {"amd",	  "%=",		DMGL_ANSI},	/* ansi */
  {"trunc_div",	  "/",		0},		/* old */
  {"dv",	  "/",		DMGL_ANSI},	/* ansi */
  {"adv",	  "/=",		DMGL_ANSI},	/* ansi */
  {"truth_andif", "&&",		0},		/* old */
  {"aa",	  "&&",		DMGL_ANSI},	/* ansi */
  {"truth_orif",  "||",		0},		/* old */
  {"oo",	  "||",		DMGL_ANSI},	/* ansi */
  {"truth_not",	  "!",		0},		/* old */
  {"nt",	  "!",		DMGL_ANSI},	/* ansi */
  {"postincrement","++",	0},		/* old */
  {"pp",	  "++",		DMGL_ANSI},	/* ansi */
  {"postdecrement","--",	0},		/* old */
  {"mm",	  "--",		DMGL_ANSI},	/* ansi */
  {"bit_ior",	  "|",		0},		/* old */
  {"or",	  "|",		DMGL_ANSI},	/* ansi */
  {"aor",	  "|=",		DMGL_ANSI},	/* ansi */
  {"bit_xor",	  "^",		0},		/* old */
  {"er",	  "^",		DMGL_ANSI},	/* ansi */
  {"aer",	  "^=",		DMGL_ANSI},	/* ansi */
  {"bit_and",	  "&",		0},		/* old */
  {"ad",	  "&",		DMGL_ANSI},	/* ansi */
  {"aad",	  "&=",		DMGL_ANSI},	/* ansi */
  {"bit_not",	  "~",		0},		/* old */
  {"co",	  "~",		DMGL_ANSI},	/* ansi */
  {"call",	  "()",		0},		/* old */
  {"cl",	  "()",		DMGL_ANSI},	/* ansi */
  {"alshift",	  "<<",		0},		/* old */
  {"ls",	  "<<",		DMGL_ANSI},	/* ansi */
  {"als",	  "<<=",	DMGL_ANSI},	/* ansi */
  {"arshift",	  ">>",		0},		/* old */
  {"rs",	  ">>",		DMGL_ANSI},	/* ansi */
  {"ars",	  ">>=",	DMGL_ANSI},	/* ansi */
  {"component",	  "->",		0},		/* old */
  {"pt",	  "->",		DMGL_ANSI},	/* ansi; Lucid C++ form */
  {"rf",	  "->",		DMGL_ANSI},	/* ansi; ARM/GNU form */
  {"indirect",	  "*",		0},		/* old */
  {"method_call",  "->()",	0},		/* old */
  {"addr",	  "&",		0},		/* old (unary &) */
  {"array",	  "[]",		0},		/* old */
  {"vc",	  "[]",		DMGL_ANSI},	/* ansi */
  {"compound",	  ", ",		0},		/* old */
  {"cm",	  ", ",		DMGL_ANSI},	/* ansi */
  {"cond",	  "?:",		0},		/* old */
  {"cn",	  "?:",		DMGL_ANSI},	/* pseudo-ansi */
  {"max",	  ">?",		0},		/* old */
  {"mx",	  ">?",		DMGL_ANSI},	/* pseudo-ansi */
  {"min",	  "<?",		0},		/* old */
  {"mn",	  "<?",		DMGL_ANSI},	/* pseudo-ansi */
  {"nop",	  "",		0},		/* old (for operator=) */
  {"rm",	  "->*",	DMGL_ANSI},	/* ansi */
  {"sz",          "sizeof ",    DMGL_ANSI}      /* pseudo-ansi */
};

/* These values are used to indicate the various type varieties.
   They are all non-zero so that they can be used as `success'
   values.  */
typedef enum type_kind_t 
{ 
  tk_none,
  tk_pointer,
  tk_reference,
  tk_integral, 
  tk_bool,
  tk_char, 
  tk_real
} type_kind_t;

#define STRING_EMPTY(str)	((str) -> b == (str) -> p)
#define PREPEND_BLANK(str)	{if (!STRING_EMPTY(str)) \
    string_prepend(str, " ");}
#define APPEND_BLANK(str)	{if (!STRING_EMPTY(str)) \
    string_append(str, " ");}
#define LEN_STRING(str)         ( (STRING_EMPTY(str))?0:((str)->p - (str)->b))

/* The scope separator appropriate for the language being demangled.  */
#define SCOPE_STRING(work) "::"

#define ARM_VTABLE_STRING "__vtbl__"	/* Lucid/ARM virtual table prefix */
#define ARM_VTABLE_STRLEN 8		/* strlen (ARM_VTABLE_STRING) */

/* Prototypes for local functions */

static char *
mop_up PARAMS ((struct work_stuff *, string *, int));

static void
squangle_mop_up PARAMS ((struct work_stuff *));

#if 0
static int
demangle_method_args PARAMS ((struct work_stuff *, const char **, string *));
#endif

static char *
internal_cplus_demangle PARAMS ((struct work_stuff *, const char *));

static int
demangle_template_template_parm PARAMS ((struct work_stuff *work, 
					 const char **, string *));

static int
demangle_template PARAMS ((struct work_stuff *work, const char **, string *,
			   string *, int, int));

static int
arm_pt PARAMS ((struct work_stuff *, const char *, int, const char **,
		const char **));

static int
demangle_class_name PARAMS ((struct work_stuff *, const char **, string *));

static int
demangle_qualified PARAMS ((struct work_stuff *, const char **, string *,
			    int, int));

static int
demangle_class PARAMS ((struct work_stuff *, const char **, string *));

static int
demangle_fund_type PARAMS ((struct work_stuff *, const char **, string *));

static int
demangle_signature PARAMS ((struct work_stuff *, const char **, string *));

static int
demangle_prefix PARAMS ((struct work_stuff *, const char **, string *));

static int
gnu_special PARAMS ((struct work_stuff *, const char **, string *));

static int
arm_special PARAMS ((const char **, string *));

static void
string_need PARAMS ((string *, int));

static void
string_delete PARAMS ((string *));

static void
string_init PARAMS ((string *));

static void
string_clear PARAMS ((string *));

#if 0
static int
string_empty PARAMS ((string *));
#endif

static void
string_append PARAMS ((string *, const char *));

static void
string_appends PARAMS ((string *, string *));

static void
string_appendn PARAMS ((string *, const char *, int));

static void
string_prepend PARAMS ((string *, const char *));

static void
string_prependn PARAMS ((string *, const char *, int));

static int
get_count PARAMS ((const char **, int *));

static int
consume_count PARAMS ((const char **));

static int 
consume_count_with_underscores PARAMS ((const char**));

static int
demangle_args PARAMS ((struct work_stuff *, const char **, string *));

static int
demangle_nested_args PARAMS ((struct work_stuff*, const char**, string*));

static int
do_type PARAMS ((struct work_stuff *, const char **, string *));

static int
do_arg PARAMS ((struct work_stuff *, const char **, string *));

static void
demangle_function_name PARAMS ((struct work_stuff *, const char **, string *,
				const char *));

static void
remember_type PARAMS ((struct work_stuff *, const char *, int));

static void
remember_Btype PARAMS ((struct work_stuff *, const char *, int, int));

static int
register_Btype PARAMS ((struct work_stuff *));

static void
remember_Ktype PARAMS ((struct work_stuff *, const char *, int));

static void
forget_types PARAMS ((struct work_stuff *));

static void
forget_B_and_K_types PARAMS ((struct work_stuff *));

static void
string_prepends PARAMS ((string *, string *));

static int 
demangle_template_value_parm PARAMS ((struct work_stuff*, const char**, 
				      string*, type_kind_t));

static int 
do_hpacc_template_const_value PARAMS ((struct work_stuff *, const char **, string *));

static int 
do_hpacc_template_literal PARAMS ((struct work_stuff *, const char **, string *));

static int 
snarf_numeric_literal PARAMS ((const char **, string *));

/* There is a TYPE_QUAL value for each type qualifier.  They can be
   combined by bitwise-or to form the complete set of qualifiers for a
   type.  */

#define TYPE_UNQUALIFIED   0x0
#define TYPE_QUAL_CONST    0x1
#define TYPE_QUAL_VOLATILE 0x2
#define TYPE_QUAL_RESTRICT 0x4

static int 
code_for_qualifier PARAMS ((char));

static const char*
qualifier_string PARAMS ((int));

static const char*
demangle_qualifier PARAMS ((char));

/*  Translate count to integer, consuming tokens in the process.
    Conversion terminates on the first non-digit character.
    Trying to consume something that isn't a count results in
    no consumption of input and a return of 0.  */

static int
consume_count (type)
     const char **type;
{
  int count = 0;

  while (isdigit ((unsigned char)**type))
    {
      count *= 10;
      count += **type - '0';
      (*type)++;
    }
  return (count);
}


/* Like consume_count, but for counts that are preceded and followed
   by '_' if they are greater than 10.  Also, -1 is returned for
   failure, since 0 can be a valid value.  */

static int
consume_count_with_underscores (mangled)
     const char **mangled;
{
  int idx;

  if (**mangled == '_')
    {
      (*mangled)++;
      if (!isdigit ((unsigned char)**mangled))
	return -1;

      idx = consume_count (mangled);
      if (**mangled != '_')
	/* The trailing underscore was missing. */
	return -1;

      (*mangled)++;
    }
  else
    {
      if (**mangled < '0' || **mangled > '9')
	return -1;

      idx = **mangled - '0';
      (*mangled)++;
    }

  return idx;
}

/* C is the code for a type-qualifier.  Return the TYPE_QUAL
   corresponding to this qualifier.  */

static int
code_for_qualifier (c)
     char c;
{
  switch (c) 
    {
    case 'C':
      return TYPE_QUAL_CONST;

    case 'V':
      return TYPE_QUAL_VOLATILE;

    case 'u':
      return TYPE_QUAL_RESTRICT;

    default:
      break;
    }

  /* C was an invalid qualifier.  */
  abort ();
}

/* Return the string corresponding to the qualifiers given by
   TYPE_QUALS.  */

static const char*
qualifier_string (type_quals)
     int type_quals;
{
  switch (type_quals)
    {
    case TYPE_UNQUALIFIED:
      return "";

    case TYPE_QUAL_CONST:
      return "const";

    case TYPE_QUAL_VOLATILE:
      return "volatile";

    case TYPE_QUAL_RESTRICT:
      return "__restrict";

    case TYPE_QUAL_CONST | TYPE_QUAL_VOLATILE:
      return "const volatile";

    case TYPE_QUAL_CONST | TYPE_QUAL_RESTRICT:
      return "const __restrict";

    case TYPE_QUAL_VOLATILE | TYPE_QUAL_RESTRICT:
      return "volatile __restrict";

    case TYPE_QUAL_CONST | TYPE_QUAL_VOLATILE | TYPE_QUAL_RESTRICT:
      return "const volatile __restrict";

    default:
      break;
    }

  /* TYPE_QUALS was an invalid qualifier set.  */
  abort ();
}

/* C is the code for a type-qualifier.  Return the string
   corresponding to this qualifier.  This function should only be
   called with a valid qualifier code.  */

static const char*
demangle_qualifier (c)
     char c;
{
  return qualifier_string (code_for_qualifier (c));
}

#if COMPILE_UNUSED
static int
cplus_demangle_opname (opname, result, options)
     const char *opname;
     char *result;
     int options;
{
  int len, len1, ret;
  string type;
  struct work_stuff work[1];
  const char *tem;

  len = strlen(opname);
  result[0] = '\0';
  ret = 0;
  memset ((char *) work, 0, sizeof (work));
  work->options = options;

  if (opname[0] == '_' && opname[1] == '_'
      && opname[2] == 'o' && opname[3] == 'p')
    {
      /* ANSI.  */
      /* type conversion operator.  */
      tem = opname + 4;
      if (do_type (work, &tem, &type))
	{
	  strcat (result, "operator ");
	  strncat (result, type.b, type.p - type.b);
	  string_delete (&type);
	  ret = 1;
	}
    }
  else if (opname[0] == '_' && opname[1] == '_'
	   && opname[2] >= 'a' && opname[2] <= 'z'
	   && opname[3] >= 'a' && opname[3] <= 'z')
    {
      if (opname[4] == '\0')
	{
	  /* Operator.  */
	  size_t i;
	  for (i = 0; i < sizeof (optable) / sizeof (optable[0]); i++)
	    {
	      if (strlen (optable[i].in) == 2
		  && memcmp (optable[i].in, opname + 2, 2) == 0)
		{
		  strcat (result, "operator");
		  strcat (result, optable[i].out);
		  ret = 1;
		  break;
		}
	    }
	}
      else
	{
	  if (opname[2] == 'a' && opname[5] == '\0')
	    {
	      /* Assignment.  */
	      size_t i;
	      for (i = 0; i < sizeof (optable) / sizeof (optable[0]); i++)
		{
		  if (strlen (optable[i].in) == 3
		      && memcmp (optable[i].in, opname + 2, 3) == 0)
		    {
		      strcat (result, "operator");
		      strcat (result, optable[i].out);
		      ret = 1;
		      break;
		    }		      
		}
	    }
	}
    }
  else if (len >= 3 
	   && opname[0] == 'o'
	   && opname[1] == 'p'
	   && strchr (cplus_markers, opname[2]) != NULL)
    {
      /* see if it's an assignment expression */
      if (len >= 10 /* op$assign_ */
	  && memcmp (opname + 3, "assign_", 7) == 0)
	{
	  size_t i;
	  for (i = 0; i < sizeof (optable) / sizeof (optable[0]); i++)
	    {
	      len1 = len - 10;
	      if ((int) strlen (optable[i].in) == len1
		  && memcmp (optable[i].in, opname + 10, len1) == 0)
		{
		  strcat (result, "operator");
		  strcat (result, optable[i].out);
		  strcat (result, "=");
		  ret = 1;
		  break;
		}
	    }
	}
      else
	{
	  size_t i;
	  for (i = 0; i < sizeof (optable) / sizeof (optable[0]); i++)
	    {
	      len1 = len - 3;
	      if ((int) strlen (optable[i].in) == len1 
		  && memcmp (optable[i].in, opname + 3, len1) == 0)
		{
		  strcat (result, "operator");
		  strcat (result, optable[i].out);
		  ret = 1;
		  break;
		}
	    }
	}
    }
  else if (len >= 5 && memcmp (opname, "type", 4) == 0
	   && strchr (cplus_markers, opname[4]) != NULL)
    {
      /* type conversion operator */
      tem = opname + 5;
      if (do_type (work, &tem, &type))
	{
	  strcat (result, "operator ");
	  strncat (result, type.b, type.p - type.b);
	  string_delete (&type);
	  ret = 1;
	}
    }
  squangle_mop_up (work);
  return ret;

}
#endif /* COMPILE_UNUSED */
#if COMPILE_UNUSED
/* Takes operator name as e.g. "++" and returns mangled
   operator name (e.g. "postincrement_expr"), or NULL if not found.

   If OPTIONS & DMGL_ANSI == 1, return the ANSI name;
   if OPTIONS & DMGL_ANSI == 0, return the old GNU name.  */

static const char *
cplus_mangle_opname (opname, options)
     const char *opname;
     int options;
{
  size_t i;
  int len;

  len = strlen (opname);
  for (i = 0; i < sizeof (optable) / sizeof (optable[0]); i++)
    {
      if ((int) strlen (optable[i].out) == len
	  && (options & DMGL_ANSI) == (optable[i].flags & DMGL_ANSI)
	  && memcmp (optable[i].out, opname, len) == 0)
	return optable[i].in;
    }
  return (0);
}
#endif /* COMPILE_UNUSED */

/* char *cplus_demangle (const char *mangled, int options)

   If MANGLED is a mangled function name produced by GNU C++, then
   a pointer to a malloced string giving a C++ representation
   of the name will be returned; otherwise NULL will be returned.
   It is the caller's responsibility to free the string which
   is returned.

   The OPTIONS arg may contain one or more of the following bits:

   	DMGL_ANSI	ANSI qualifiers such as `const' and `void' are
			included.
	DMGL_PARAMS	Function parameters are included.

   For example,

   cplus_demangle ("foo__1Ai", DMGL_PARAMS)		=> "A::foo(int)"
   cplus_demangle ("foo__1Ai", DMGL_PARAMS | DMGL_ANSI)	=> "A::foo(int)"
   cplus_demangle ("foo__1Ai", 0)			=> "A::foo"

   cplus_demangle ("foo__1Afe", DMGL_PARAMS)		=> "A::foo(float,...)"
   cplus_demangle ("foo__1Afe", DMGL_PARAMS | DMGL_ANSI)=> "A::foo(float,...)"
   cplus_demangle ("foo__1Afe", 0)			=> "A::foo"

   Note that any leading underscores, or other such characters prepended by
   the compilation system, are presumed to have already been stripped from
   MANGLED.  */

static char *
gnu_cplus_demangle (mangled, options)
     const char *mangled;
     int options;
{
  char *ret;
  struct work_stuff work[1];
  memset ((char *) work, 0, sizeof (work));
  work -> options = options;
  if ((work -> options & DMGL_STYLE_MASK) == 0)
    work -> options |= (int) current_demangling_style & DMGL_STYLE_MASK;

  ret = internal_cplus_demangle (work, mangled);
  squangle_mop_up (work);
  return (ret);
}


/* This function performs most of what cplus_demangle use to do, but 
   to be able to demangle a name with a B, K or n code, we need to
   have a longer term memory of what types have been seen. The original
   now intializes and cleans up the squangle code info, while internal
   calls go directly to this routine to avoid resetting that info. */

static char *
internal_cplus_demangle (work, mangled)
     struct work_stuff *work;
     const char *mangled;
{

  string decl;
  int success = 0;
  char *demangled = NULL;
  int s1,s2,s3,s4;
  s1 = work->constructor;
  s2 = work->destructor;
  s3 = work->static_type;
  s4 = work->type_quals;
  work->constructor = work->destructor = 0;
  work->type_quals = TYPE_UNQUALIFIED;
  work->dllimported = 0;

  if ((mangled != NULL) && (*mangled != '\0'))
    {
      string_init (&decl);

      /* First check to see if gnu style demangling is active and if the
	 string to be demangled contains a CPLUS_MARKER.  If so, attempt to
	 recognize one of the gnu special forms rather than looking for a
	 standard prefix.  In particular, don't worry about whether there
	 is a "__" string in the mangled string.  Consider "_$_5__foo" for
	 example.  */

      if ((AUTO_DEMANGLING || GNU_DEMANGLING))
	{
	  success = gnu_special (work, &mangled, &decl);
	}
      if (!success)
	{
	  success = demangle_prefix (work, &mangled, &decl);
	}
      if (success && (*mangled != '\0'))
	{
	  success = demangle_signature (work, &mangled, &decl);
	}
      if (work->constructor == 2)
        {
          string_prepend (&decl, "global constructors keyed to ");
          work->constructor = 0;
        }
      else if (work->destructor == 2)
        {
          string_prepend (&decl, "global destructors keyed to ");
          work->destructor = 0;
        }
      else if (work->dllimported == 1)
        {
          string_prepend (&decl, "import stub for ");
          work->dllimported = 0;
        }
      demangled = mop_up (work, &decl, success);
    }
  work->constructor = s1;
  work->destructor = s2;
  work->static_type = s3;
  work->type_quals = s4;
  return (demangled);
}


/* Clear out and squangling related storage */
static void
squangle_mop_up (work)
     struct work_stuff *work;
{
  /* clean up the B and K type mangling types. */
  forget_B_and_K_types (work);
  if (work -> btypevec != NULL)
    {
      free ((char *) work -> btypevec);
    }
  if (work -> ktypevec != NULL)
    {
      free ((char *) work -> ktypevec);
    }
}

/* Clear out any mangled storage */

static char *
mop_up (work, declp, success)
     struct work_stuff *work;
     string *declp;
     int success;
{
  char *demangled = NULL;

  /* Discard the remembered types, if any.  */

  forget_types (work);
  if (work -> typevec != NULL)
    {
      free ((char *) work -> typevec);
      work -> typevec = NULL;
    }
  if (work->tmpl_argvec)
    {
      int i;

      for (i = 0; i < work->ntmpl_args; i++)
	if (work->tmpl_argvec[i])
	  free ((char*) work->tmpl_argvec[i]);

      free ((char*) work->tmpl_argvec);
      work->tmpl_argvec = NULL;
    }
  if (work->previous_argument)
    {
      string_delete (work->previous_argument);
      free ((char*) work->previous_argument);
      work->previous_argument = NULL;
    }

  /* If demangling was successful, ensure that the demangled string is null
     terminated and return it.  Otherwise, free the demangling decl.  */

  if (!success)
    {
      string_delete (declp);
    }
  else
    {
      string_appendn (declp, "", 1);
      demangled = declp -> b;
    }
  return (demangled);
}

/*

LOCAL FUNCTION

	demangle_signature -- demangle the signature part of a mangled name

SYNOPSIS

	static int
	demangle_signature (struct work_stuff *work, const char **mangled,
			    string *declp);

DESCRIPTION

	Consume and demangle the signature portion of the mangled name.

	DECLP is the string where demangled output is being built.  At
	entry it contains the demangled root name from the mangled name
	prefix.  I.E. either a demangled operator name or the root function
	name.  In some special cases, it may contain nothing.

	*MANGLED points to the current unconsumed location in the mangled
	name.  As tokens are consumed and demangling is performed, the
	pointer is updated to continuously point at the next token to
	be consumed.

	Demangling GNU style mangled names is nasty because there is no
	explicit token that marks the start of the outermost function
	argument list.  */

static int
demangle_signature (work, mangled, declp)
     struct work_stuff *work;
     const char **mangled;
     string *declp;
{
  int success = 1;
  int func_done = 0;
  int expect_func = 0;
  int expect_return_type = 0;
  const char *oldmangled = NULL;
  string trawname;
  string tname;

  while (success && (**mangled != '\0'))
    {
      switch (**mangled)
	{
	case 'Q':
	  oldmangled = *mangled;
	  success = demangle_qualified (work, mangled, declp, 1, 0);
	  if (success)
	    remember_type (work, oldmangled, *mangled - oldmangled);
	  if (AUTO_DEMANGLING || GNU_DEMANGLING)
	    expect_func = 1;
	  oldmangled = NULL;
	  break;

        case 'K':
	  oldmangled = *mangled;
	  success = demangle_qualified (work, mangled, declp, 1, 0);
	  if (AUTO_DEMANGLING || GNU_DEMANGLING)
	    {
	      expect_func = 1;
	    }
	  oldmangled = NULL;
	  break;

	case 'S':
	  /* Static member function */
	  if (oldmangled == NULL)
	    {
	      oldmangled = *mangled;
	    }
	  (*mangled)++;
	  work -> static_type = 1;
	  break;

	case 'C':
	case 'V':
	case 'u':
	  work->type_quals |= code_for_qualifier (**mangled);

	  /* a qualified member function */
	  if (oldmangled == NULL)
	    oldmangled = *mangled;
	  (*mangled)++;
	  break;

	case 'L':
	  /* Local class name follows after "Lnnn_" */
	  if (HP_DEMANGLING)
	    {
	      while (**mangled && (**mangled != '_'))
		(*mangled)++;
	      if (!**mangled)
		success = 0;
	      else
		(*mangled)++;
	    }
	  else
	    success = 0;
	  break;

	case '0': case '1': case '2': case '3': case '4':
	case '5': case '6': case '7': case '8': case '9':
	  if (oldmangled == NULL)
	    {
	      oldmangled = *mangled;
	    }
          work->temp_start = -1; /* uppermost call to demangle_class */ 
	  success = demangle_class (work, mangled, declp);
	  if (success)
	    {
	      remember_type (work, oldmangled, *mangled - oldmangled);
	    }
	  if (AUTO_DEMANGLING || GNU_DEMANGLING || EDG_DEMANGLING)
	    {
              /* EDG and others will have the "F", so we let the loop cycle 
                 if we are looking at one. */
              if (**mangled != 'F')
                 expect_func = 1;
	    }
	  oldmangled = NULL;
	  break;

	case 'B':
	  {
	    string s;
	    success = do_type (work, mangled, &s);
	    if (success)
	      {
		string_append (&s, SCOPE_STRING (work));
		string_prepends (declp, &s);
	      }
	    oldmangled = NULL;
	    expect_func = 1;
	  }
	  break;

	case 'F':
	  /* Function */
	  /* ARM/HP style demangling includes a specific 'F' character after
	     the class name.  For GNU style, it is just implied.  So we can
	     safely just consume any 'F' at this point and be compatible
	     with either style.  */

	  oldmangled = NULL;
	  func_done = 1;
	  (*mangled)++;

	  /* For lucid/ARM/HP style we have to forget any types we might
	     have remembered up to this point, since they were not argument
	     types.  GNU style considers all types seen as available for
	     back references.  See comment in demangle_args() */

	  if (LUCID_DEMANGLING || ARM_DEMANGLING || HP_DEMANGLING || EDG_DEMANGLING)
	    {
	      forget_types (work);
	    }
	  success = demangle_args (work, mangled, declp);
	  /* After picking off the function args, we expect to either
	     find the function return type (preceded by an '_') or the
	     end of the string. */
	  if (success && (AUTO_DEMANGLING || EDG_DEMANGLING) && **mangled == '_')
	    {
	      ++(*mangled);
              /* At this level, we do not care about the return type. */
              success = do_type (work, mangled, &tname);
              string_delete (&tname);
            }

	  break;

	case 't':
	  /* G++ Template */
	  string_init(&trawname); 
	  string_init(&tname);
	  if (oldmangled == NULL)
	    {
	      oldmangled = *mangled;
	    }
	  success = demangle_template (work, mangled, &tname,
				       &trawname, 1, 1);
	  if (success)
	    {
	      remember_type (work, oldmangled, *mangled - oldmangled);
	    }
	  string_append (&tname, SCOPE_STRING (work));

	  string_prepends(declp, &tname);
	  if (work -> destructor & 1)
	    {
	      string_prepend (&trawname, "~");
	      string_appends (declp, &trawname);
	      work->destructor -= 1;
	    }
	  if ((work->constructor & 1) || (work->destructor & 1))
	    {
	      string_appends (declp, &trawname);
	      work->constructor -= 1;
	    }
	  string_delete(&trawname);
	  string_delete(&tname);
	  oldmangled = NULL;
	  expect_func = 1;
	  break;

	case '_':
	  if (GNU_DEMANGLING && expect_return_type) 
	    {
	      /* Read the return type. */
	      string return_type;
	      string_init (&return_type);

	      (*mangled)++;
	      success = do_type (work, mangled, &return_type);
	      APPEND_BLANK (&return_type);

	      string_prepends (declp, &return_type);
	      string_delete (&return_type);
	      break;
	    }
	  else
	    /* At the outermost level, we cannot have a return type specified,
	       so if we run into another '_' at this point we are dealing with
	       a mangled name that is either bogus, or has been mangled by
	       some algorithm we don't know how to deal with.  So just
	       reject the entire demangling.  */
            /* However, "_nnn" is an expected suffix for alternate entry point
               numbered nnn for a function, with HP aCC, so skip over that
               without reporting failure. pai/1997-09-04 */
            if (HP_DEMANGLING)
              {
                (*mangled)++;
                while (**mangled && isdigit (**mangled))
                  (*mangled)++;
              }
            else
	      success = 0;
	  break;

	case 'H':
	  if (GNU_DEMANGLING) 
	    {
	      /* A G++ template function.  Read the template arguments. */
	      success = demangle_template (work, mangled, declp, 0, 0,
					   0);
	      if (!(work->constructor & 1))
		expect_return_type = 1;
	      (*mangled)++;
	      break;
	    }
	  else
	    /* fall through */
	    {;}

	default:
	  if (AUTO_DEMANGLING || GNU_DEMANGLING)
	    {
	      /* Assume we have stumbled onto the first outermost function
		 argument token, and start processing args.  */
	      func_done = 1;
	      success = demangle_args (work, mangled, declp);
	    }
	  else
	    {
	      /* Non-GNU demanglers use a specific token to mark the start
		 of the outermost function argument tokens.  Typically 'F',
		 for ARM/HP-demangling, for example.  So if we find something
		 we are not prepared for, it must be an error.  */
	      success = 0;
	    }
	  break;
	}
      /*
	if (AUTO_DEMANGLING || GNU_DEMANGLING)
	*/
      {
	if (success && expect_func)
	  {
	    func_done = 1;
              if (LUCID_DEMANGLING || ARM_DEMANGLING || EDG_DEMANGLING)
                {
                  forget_types (work);
                }
	    success = demangle_args (work, mangled, declp);
	    /* Since template include the mangling of their return types,
	       we must set expect_func to 0 so that we don't try do
	       demangle more arguments the next time we get here.  */
	    expect_func = 0;
	  }
      }
    }
  if (success && !func_done)
    {
      if (AUTO_DEMANGLING || GNU_DEMANGLING)
	{
	  /* With GNU style demangling, bar__3foo is 'foo::bar(void)', and
	     bar__3fooi is 'foo::bar(int)'.  We get here when we find the
	     first case, and need to ensure that the '(void)' gets added to
	     the current declp.  Note that with ARM/HP, the first case
	     represents the name of a static data member 'foo::bar',
	     which is in the current declp, so we leave it alone.  */
	  success = demangle_args (work, mangled, declp);
	}
    }
  if (success && PRINT_ARG_TYPES)
    {
      if (work->static_type)
	string_append (declp, " static");
      if (work->type_quals != TYPE_UNQUALIFIED)
	{
	  APPEND_BLANK (declp);
	  string_append (declp, qualifier_string (work->type_quals));
	}
    }

  return (success);
}

#if 0

static int
demangle_method_args (work, mangled, declp)
     struct work_stuff *work;
     const char **mangled;
     string *declp;
{
  int success = 0;

  if (work -> static_type)
    {
      string_append (declp, *mangled + 1);
      *mangled += strlen (*mangled);
      success = 1;
    }
  else
    {
      success = demangle_args (work, mangled, declp);
    }
  return (success);
}

#endif

static int
demangle_template_template_parm (work, mangled, tname)
     struct work_stuff *work;
     const char **mangled;
     string *tname;
{
  int i;
  int r;
  int need_comma = 0;
  int success = 1;
  string temp;

  string_append (tname, "template <");
  /* get size of template parameter list */
  if (get_count (mangled, &r))
    {
      for (i = 0; i < r; i++)
	{
	  if (need_comma)
	    {
	      string_append (tname, ", ");
	    }

	    /* Z for type parameters */
	    if (**mangled == 'Z')
	      {
		(*mangled)++;
		string_append (tname, "class");
	      }
	      /* z for template parameters */
	    else if (**mangled == 'z')
	      {
		(*mangled)++;
		success = 
		  demangle_template_template_parm (work, mangled, tname);
		if (!success)
		  {
		    break;
		  }
	      }
	    else
	      {
		/* temp is initialized in do_type */
		success = do_type (work, mangled, &temp);
		if (success)
		  {
		    string_appends (tname, &temp);
		  }
		string_delete(&temp);
		if (!success)
		  {
		    break;
		  }
	      }
	  need_comma = 1;
	}

    }
  if (tname->p[-1] == '>')
    string_append (tname, " ");
  string_append (tname, "> class");
  return (success);
}

static int
demangle_integral_value (work, mangled, s)
     struct work_stuff *work;
     const char** mangled;
     string* s;
{
  int success;

  if (**mangled == 'E')
    {
      int need_operator = 0;

      success = 1;
      string_appendn (s, "(", 1);
      (*mangled)++;
      while (success && **mangled != 'W' && **mangled != '\0')
	{
	  if (need_operator)
	    {
	      size_t i;
	      size_t len;

	      success = 0;

	      len = strlen (*mangled);

	      for (i = 0; 
		   i < sizeof (optable) / sizeof (optable [0]);
		   ++i)
		{
		  size_t l = strlen (optable[i].in);

		  if (l <= len
		      && memcmp (optable[i].in, *mangled, l) == 0)
		    {
		      string_appendn (s, " ", 1);
		      string_append (s, optable[i].out);
		      string_appendn (s, " ", 1);
		      success = 1;
		      (*mangled) += l;
		      break;
		    }
		}

	      if (!success)
		break;
	    }
	  else
	    need_operator = 1;

	  success = demangle_template_value_parm (work, mangled, s,
						  tk_integral);
	}

      if (**mangled != 'W')
	  success = 0;
      else 
	{
	  string_appendn (s, ")", 1);
	  (*mangled)++;
	}
    }
  else if (**mangled == 'Q' || **mangled == 'K')
    success = demangle_qualified (work, mangled, s, 0, 1);
  else
    {
      success = 0;

      if (**mangled == 'm')
	{
	  string_appendn (s, "-", 1);
	  (*mangled)++;
	}
      while (isdigit ((unsigned char)**mangled))
	{
	  string_appendn (s, *mangled, 1);
	  (*mangled)++;
	  success = 1;
	}
    }

  return success;
}

static int 
demangle_template_value_parm (work, mangled, s, tk)
     struct work_stuff *work;
     const char **mangled;
     string* s;
     type_kind_t tk;
{
  int success = 1;

  if (**mangled == 'Y')
    {
      /* The next argument is a template parameter. */
      int idx;

      (*mangled)++;
      idx = consume_count_with_underscores (mangled);
      if (idx == -1 
	  || (work->tmpl_argvec && idx >= work->ntmpl_args)
	  || consume_count_with_underscores (mangled) == -1)
	return -1;
      if (work->tmpl_argvec)
	string_append (s, work->tmpl_argvec[idx]);
      else
	{
	  char buf[10];
	  sprintf(buf, "T%d", idx);
	  string_append (s, buf);
	}
    }
  else if (tk == tk_integral)
    success = demangle_integral_value (work, mangled, s);
  else if (tk == tk_char)
    {
      char tmp[2];
      int val;
      if (**mangled == 'm')
	{
	  string_appendn (s, "-", 1);
	  (*mangled)++;
	}
      string_appendn (s, "'", 1);
      val = consume_count(mangled);
      if (val == 0)
	return -1;
      tmp[0] = (char)val;
      tmp[1] = '\0';
      string_appendn (s, &tmp[0], 1);
      string_appendn (s, "'", 1);
    }
  else if (tk == tk_bool)
    {
      int val = consume_count (mangled);
      if (val == 0)
	string_appendn (s, "false", 5);
      else if (val == 1)
	string_appendn (s, "true", 4);
      else
	success = 0;
    }
  else if (tk == tk_real)
    {
      if (**mangled == 'm')
	{
	  string_appendn (s, "-", 1);
	  (*mangled)++;
	}
      while (isdigit ((unsigned char)**mangled))
	{
	  string_appendn (s, *mangled, 1);
	  (*mangled)++;
	}
      if (**mangled == '.') /* fraction */
	{
	  string_appendn (s, ".", 1);
	  (*mangled)++;
	  while (isdigit ((unsigned char)**mangled))
	    {
	      string_appendn (s, *mangled, 1);
	      (*mangled)++;
	    }
	}
      if (**mangled == 'e') /* exponent */
	{
	  string_appendn (s, "e", 1);
	  (*mangled)++;
	  while (isdigit ((unsigned char)**mangled))
	    {
	      string_appendn (s, *mangled, 1);
	      (*mangled)++;
	    }
	}
    }
  else if (tk == tk_pointer || tk == tk_reference)
    {
      int symbol_len = consume_count (mangled);
      if (symbol_len == 0)
	return -1;
      if (symbol_len == 0)
	string_appendn (s, "0", 1);
      else
	{
	  char *p = xmalloc (symbol_len + 1), *q;
	  strncpy (p, *mangled, symbol_len);
	  p [symbol_len] = '\0';
	  /* We use cplus_demangle here, rather than
	     internal_cplus_demangle, because the name of the entity
	     mangled here does not make use of any of the squangling
	     or type-code information we have built up thus far; it is
	     mangled independently.  */
	  q = cplus_demangle (p, work->options);
	  if (tk == tk_pointer)
	    string_appendn (s, "&", 1);
	  /* FIXME: Pointer-to-member constants should get a
	            qualifying class name here.  */
	  if (q)
	    {
	      string_append (s, q);
	      free (q);
	    }
	  else
	    string_append (s, p);
	  free (p);
	}
      *mangled += symbol_len;
    }

  return success;
}

/* Demangle the template name in MANGLED.  The full name of the
   template (e.g., S<int>) is placed in TNAME.  The name without the
   template parameters (e.g. S) is placed in TRAWNAME if TRAWNAME is
   non-NULL.  If IS_TYPE is nonzero, this template is a type template,
   not a function template.  If both IS_TYPE and REMEMBER are nonzero,
   the tmeplate is remembered in the list of back-referenceable
   types.  */

static int
demangle_template (work, mangled, tname, trawname, is_type, remember)
     struct work_stuff *work;
     const char **mangled;
     string *tname;
     string *trawname;
     int is_type;
     int remember;
{
  int i;
  int r;
  int need_comma = 0;
  int success = 0;
  const char *start;
  string temp;
  int bindex = 0;

  (*mangled)++;
  if (is_type)
    {
      if (remember)
	bindex = register_Btype (work);
      start = *mangled;
      /* get template name */
      if (**mangled == 'z')
	{
	  int idx;
	  (*mangled)++;
	  (*mangled)++;

	  idx = consume_count_with_underscores (mangled);
	  if (idx == -1 
	      || (work->tmpl_argvec && idx >= work->ntmpl_args)
	      || consume_count_with_underscores (mangled) == -1)
	    return (0);

	  if (work->tmpl_argvec)
	    {
	      string_append (tname, work->tmpl_argvec[idx]);
	      if (trawname)
		string_append (trawname, work->tmpl_argvec[idx]);
	    }
	  else
	    {
	      char buf[10];
	      sprintf(buf, "T%d", idx);
	      string_append (tname, buf);
	      if (trawname)
		string_append (trawname, buf);
	    }
	}
      else
	{
	  if ((r = consume_count (mangled)) == 0
	      || (int) strlen (*mangled) < r)
	    {
	      return (0);
	    }
	      string_appendn (tname, *mangled, r);
	  if (trawname)
	    string_appendn (trawname, *mangled, r);
	  *mangled += r;
	}
    }
    string_append (tname, "<");
  /* get size of template parameter list */
  if (!get_count (mangled, &r))
    {
      return (0);
    }
  if (!is_type)
    {
      /* Create an array for saving the template argument values. */
      work->tmpl_argvec = (char**) xmalloc (r * sizeof (char *));
      work->ntmpl_args = r;
      for (i = 0; i < r; i++)
	work->tmpl_argvec[i] = 0;
    }
  for (i = 0; i < r; i++)
    {
      if (need_comma)
	{
	  string_append (tname, ", ");
	}
      /* Z for type parameters */
      if (**mangled == 'Z')
	{
	  (*mangled)++;
	  /* temp is initialized in do_type */
	  success = do_type (work, mangled, &temp);
	  if (success)
	    {
	      string_appends (tname, &temp);

	      if (!is_type)
		{
		  /* Save the template argument. */
		  int len = temp.p - temp.b;
		  work->tmpl_argvec[i] = xmalloc (len + 1);
		  memcpy (work->tmpl_argvec[i], temp.b, len);
		  work->tmpl_argvec[i][len] = '\0';
		}
	    }
	  string_delete(&temp);
	  if (!success)
	    {
	      break;
	    }
	}
      /* z for template parameters */
      else if (**mangled == 'z')
	{
	  int r2;
	  (*mangled)++;
	  success = demangle_template_template_parm (work, mangled, tname);

	  if (success
	      && (r2 = consume_count (mangled)) > 0
	      && (int) strlen (*mangled) >= r2)
	    {
	      string_append (tname, " ");
	      string_appendn (tname, *mangled, r2);
	      if (!is_type)
		{
		  /* Save the template argument. */
		  int len = r2;
		  work->tmpl_argvec[i] = xmalloc (len + 1);
		  memcpy (work->tmpl_argvec[i], *mangled, len);
		  work->tmpl_argvec[i][len] = '\0';
		}
	      *mangled += r2;
	    }
	  if (!success)
	    {
	      break;
	    }
	}
      else
	{
	  string  param;
	  string* s;

	  /* otherwise, value parameter */

	  /* temp is initialized in do_type */
	  success = do_type (work, mangled, &temp);
	  string_delete(&temp);
	  if (!success)
	    break;

	  if (!is_type)
	    {
	      s = &param;
	      string_init (s);
	    }
	  else
	    s = tname;

	  success = demangle_template_value_parm (work, mangled, s,
						  (type_kind_t) success);

	  if (!success)
	    {
	      if (!is_type)
		string_delete (s);
	      success = 0;
	      break;
	    }

	  if (!is_type)
	    {
	      int len = s->p - s->b;
	      work->tmpl_argvec[i] = xmalloc (len + 1);
	      memcpy (work->tmpl_argvec[i], s->b, len);
	      work->tmpl_argvec[i][len] = '\0';

	      string_appends (tname, s);
	      string_delete (s);
	    }
	}
      need_comma = 1;
    }
    {
      if (tname->p[-1] == '>')
	string_append (tname, " ");
      string_append (tname, ">");
    }

  if (is_type && remember)
    remember_Btype (work, tname->b, LEN_STRING (tname), bindex);

  /*
    if (work -> static_type)
    {
    string_append (declp, *mangled + 1);
    *mangled += strlen (*mangled);
    success = 1;
    }
    else
    {
    success = demangle_args (work, mangled, declp);
    }
    }
    */
  return (success);
}

static int
arm_pt (work, mangled, n, anchor, args)
     struct work_stuff *work;
     const char *mangled;
     int n;
     const char **anchor, **args;
{
  /* Check if ARM template with "__pt__" in it ("parameterized type") */
  /* Allow HP also here, because HP's cfront compiler follows ARM to some extent */
  if ((ARM_DEMANGLING || HP_DEMANGLING) && (*anchor = mystrstr (mangled, "__pt__")))
    {
      int len;
      *args = *anchor + 6;
      len = consume_count (args);
      if (*args + len == mangled + n && **args == '_')
	{
	  ++*args;
	  return 1;
	}
    }
  if (AUTO_DEMANGLING || EDG_DEMANGLING)
    {
      if ((*anchor = mystrstr (mangled, "__tm__"))
          || (*anchor = mystrstr (mangled, "__ps__"))
          || (*anchor = mystrstr (mangled, "__pt__")))
        {
          int len;
          *args = *anchor + 6;
          len = consume_count (args);
          if (*args + len == mangled + n && **args == '_')
            {
              ++*args;
              return 1;
            }
        }
      else if ((*anchor = mystrstr (mangled, "__S")))
        {
 	  int len;
 	  *args = *anchor + 3;
 	  len = consume_count (args);
 	  if (*args + len == mangled + n && **args == '_')
            {
              ++*args;
 	      return 1;
            }
        }
    }

  return 0;
}

static void
demangle_arm_hp_template (work, mangled, n, declp)
     struct work_stuff *work;
     const char **mangled;
     int n;
     string *declp;
{
  const char *p;
  const char *args;
  const char *e = *mangled + n;
  string arg;

  /* Check for HP aCC template spec: classXt1t2 where t1, t2 are
     template args */
  if (HP_DEMANGLING && ((*mangled)[n] == 'X'))
    {
      char *start_spec_args = NULL;

      /* First check for and omit template specialization pseudo-arguments,
         such as in "Spec<#1,#1.*>" */
      start_spec_args = strchr (*mangled, '<');
      if (start_spec_args && (start_spec_args - *mangled < n))
        string_appendn (declp, *mangled, start_spec_args - *mangled);
      else
        string_appendn (declp, *mangled, n);
      (*mangled) += n + 1;
      string_init (&arg);
      if (work->temp_start == -1) /* non-recursive call */ 
        work->temp_start = declp->p - declp->b;
      string_append (declp, "<");
      while (1)
        {
          string_clear (&arg);
          switch (**mangled)
            {
              case 'T':
                /* 'T' signals a type parameter */
                (*mangled)++;
                if (!do_type (work, mangled, &arg))
                  goto hpacc_template_args_done;
                break;

              case 'U':
              case 'S':
                /* 'U' or 'S' signals an integral value */
                if (!do_hpacc_template_const_value (work, mangled, &arg))
                  goto hpacc_template_args_done;
                break;

              case 'A':
                /* 'A' signals a named constant expression (literal) */
                if (!do_hpacc_template_literal (work, mangled, &arg))
                  goto hpacc_template_args_done;
                break;

              default:
                /* Today, 1997-09-03, we have only the above types
                   of template parameters */ 
                /* FIXME: maybe this should fail and return null */ 
                goto hpacc_template_args_done;
            }
          string_appends (declp, &arg);
         /* Check if we're at the end of template args.
             0 if at end of static member of template class,
             _ if done with template args for a function */ 
          if ((**mangled == '\000') || (**mangled == '_')) 
            break; 
          else
            string_append (declp, ",");
        }
    hpacc_template_args_done:
      string_append (declp, ">");
      string_delete (&arg);
      if (**mangled == '_')
        (*mangled)++;
      return;
    }
  /* ARM template? (Also handles HP cfront extensions) */
  else if (arm_pt (work, *mangled, n, &p, &args))
    {
      string type_str;

      string_init (&arg);
      string_appendn (declp, *mangled, p - *mangled);
      if (work->temp_start == -1)  /* non-recursive call */
	work->temp_start = declp->p - declp->b;  
      string_append (declp, "<");
      /* should do error checking here */
      while (args < e) {
	string_clear (&arg);

	/* Check for type or literal here */
	switch (*args)
	  {
	    /* HP cfront extensions to ARM for template args */
	    /* spec: Xt1Lv1 where t1 is a type, v1 is a literal value */
	    /* FIXME: We handle only numeric literals for HP cfront */
          case 'X':
            /* A typed constant value follows */ 
            args++;
            if (!do_type (work, &args, &type_str))
	      goto cfront_template_args_done;
            string_append (&arg, "(");
            string_appends (&arg, &type_str);
            string_append (&arg, ")");
            if (*args != 'L')
              goto cfront_template_args_done;
            args++;
            /* Now snarf a literal value following 'L' */
            if (!snarf_numeric_literal (&args, &arg))
	      goto cfront_template_args_done;
            break;

          case 'L':
            /* Snarf a literal following 'L' */
            args++;
            if (!snarf_numeric_literal (&args, &arg))
	      goto cfront_template_args_done;
            break;
          default:
            /* Not handling other HP cfront stuff */ 
            if (!do_type (work, &args, &arg))
              goto cfront_template_args_done;
	  }
	string_appends (declp, &arg);
	string_append (declp, ",");
      }
    cfront_template_args_done:
      string_delete (&arg);
      if (args >= e)
	--declp->p; /* remove extra comma */ 
      string_append (declp, ">");
    }
  else if (n>10 && strncmp (*mangled, "_GLOBAL_", 8) == 0
	   && (*mangled)[9] == 'N'
	   && (*mangled)[8] == (*mangled)[10]
	   && strchr (cplus_markers, (*mangled)[8]))
    {
      /* A member of the anonymous namespace.  */
      string_append (declp, "{anonymous}");
    }
  else
    {
      if (work->temp_start == -1) /* non-recursive call only */ 
	work->temp_start = 0;     /* disable in recursive calls */ 
      string_appendn (declp, *mangled, n);
    }
  *mangled += n;
}

/* Extract a class name, possibly a template with arguments, from the
   mangled string; qualifiers, local class indicators, etc. have
   already been dealt with */

static int
demangle_class_name (work, mangled, declp)
     struct work_stuff *work;
     const char **mangled;
     string *declp;
{
  int n;
  int success = 0;

  n = consume_count (mangled);
  if ((int) strlen (*mangled) >= n)
    {
      demangle_arm_hp_template (work, mangled, n, declp);
      success = 1;
    }

  return (success);
}

/*

LOCAL FUNCTION

	demangle_class -- demangle a mangled class sequence

SYNOPSIS

	static int
	demangle_class (struct work_stuff *work, const char **mangled,
			strint *declp)

DESCRIPTION

	DECLP points to the buffer into which demangling is being done.

	*MANGLED points to the current token to be demangled.  On input,
	it points to a mangled class (I.E. "3foo", "13verylongclass", etc.)
	On exit, it points to the next token after the mangled class on
	success, or the first unconsumed token on failure.

	If the CONSTRUCTOR or DESTRUCTOR flags are set in WORK, then
	we are demangling a constructor or destructor.  In this case
	we prepend "class::class" or "class::~class" to DECLP.

	Otherwise, we prepend "class::" to the current DECLP.

	Reset the constructor/destructor flags once they have been
	"consumed".  This allows demangle_class to be called later during
	the same demangling, to do normal class demangling.

	Returns 1 if demangling is successful, 0 otherwise.

*/

static int
demangle_class (work, mangled, declp)
     struct work_stuff *work;
     const char **mangled;
     string *declp;
{
  int success = 0;
  int btype;
  string class_name;
  char *save_class_name_end = 0;  

  string_init (&class_name);
  btype = register_Btype (work);
  if (demangle_class_name (work, mangled, &class_name))
    {
      save_class_name_end = class_name.p;
      if ((work->constructor & 1) || (work->destructor & 1))
	{
          /* adjust so we don't include template args */
          if (work->temp_start && (work->temp_start != -1))
            {
              class_name.p = class_name.b + work->temp_start;
            }
	  string_prepends (declp, &class_name);
	  if (work -> destructor & 1)
	    {
	      string_prepend (declp, "~");
              work -> destructor -= 1;
	    }
	  else
	    {
	      work -> constructor -= 1; 
	    }
	}
      class_name.p = save_class_name_end;
      remember_Ktype (work, class_name.b, LEN_STRING(&class_name));
      remember_Btype (work, class_name.b, LEN_STRING(&class_name), btype);
      string_prepend (declp, SCOPE_STRING (work));
      string_prepends (declp, &class_name);
      success = 1;
    }
  string_delete (&class_name);
  return (success);
}

/*

LOCAL FUNCTION

	demangle_prefix -- consume the mangled name prefix and find signature

SYNOPSIS

	static int
	demangle_prefix (struct work_stuff *work, const char **mangled,
			 string *declp);

DESCRIPTION

	Consume and demangle the prefix of the mangled name.

	DECLP points to the string buffer into which demangled output is
	placed.  On entry, the buffer is empty.  On exit it contains
	the root function name, the demangled operator name, or in some
	special cases either nothing or the completely demangled result.

	MANGLED points to the current pointer into the mangled name.  As each
	token of the mangled name is consumed, it is updated.  Upon entry
	the current mangled name pointer points to the first character of
	the mangled name.  Upon exit, it should point to the first character
	of the signature if demangling was successful, or to the first
	unconsumed character if demangling of the prefix was unsuccessful.

	Returns 1 on success, 0 otherwise.
 */

static int
demangle_prefix (work, mangled, declp)
     struct work_stuff *work;
     const char **mangled;
     string *declp;
{
  int success = 1;
  const char *scan;
  int i;

  if (strlen(*mangled) > 6
      && (strncmp(*mangled, "_imp__", 6) == 0 
          || strncmp(*mangled, "__imp_", 6) == 0))
    {
      /* it's a symbol imported from a PE dynamic library. Check for both
         new style prefix _imp__ and legacy __imp_ used by older versions
	 of dlltool. */
      (*mangled) += 6;
      work->dllimported = 1;
    }
  else if (strlen(*mangled) >= 11 && strncmp(*mangled, "_GLOBAL_", 8) == 0)
    {
      char *marker = strchr (cplus_markers, (*mangled)[8]);
      if (marker != NULL && *marker == (*mangled)[10])
	{
	  if ((*mangled)[9] == 'D')
	    {
	      /* it's a GNU global destructor to be executed at program exit */
	      (*mangled) += 11;
	      work->destructor = 2;
	      if (gnu_special (work, mangled, declp))
		return success;
	    }
	  else if ((*mangled)[9] == 'I')
	    {
	      /* it's a GNU global constructor to be executed at program init */
	      (*mangled) += 11;
	      work->constructor = 2;
	      if (gnu_special (work, mangled, declp))
		return success;
	    }
	}
    }
  else if ((ARM_DEMANGLING || HP_DEMANGLING || EDG_DEMANGLING) && strncmp(*mangled, "__std__", 7) == 0)
    {
      /* it's a ARM global destructor to be executed at program exit */
      (*mangled) += 7;
      work->destructor = 2;
    }
  else if ((ARM_DEMANGLING || HP_DEMANGLING || EDG_DEMANGLING) && strncmp(*mangled, "__sti__", 7) == 0)
    {
      /* it's a ARM global constructor to be executed at program initial */
      (*mangled) += 7;
      work->constructor = 2;
    }

  /*  This block of code is a reduction in strength time optimization
      of:
      scan = mystrstr (*mangled, "__"); */

  {
    scan = *mangled;

    do {
      scan = strchr (scan, '_');
    } while (scan != NULL && *++scan != '_');

    if (scan != NULL) --scan;
  }

  if (scan != NULL)
    {
      /* We found a sequence of two or more '_', ensure that we start at
	 the last pair in the sequence.  */
      i = strspn (scan, "_");
      if (i > 2)
	{
	  scan += (i - 2); 
	}
    }

  if (scan == NULL)
    {
      success = 0;
    }
  else if (work -> static_type)
    {
      if (!isdigit ((unsigned char)scan[0]) && (scan[0] != 't'))
	{
	  success = 0;
	}
    }
  else if ((scan == *mangled)
	   && (isdigit ((unsigned char)scan[2]) || (scan[2] == 'Q')
	       || (scan[2] == 't') || (scan[2] == 'K') || (scan[2] == 'H')))
    {
      /* The ARM says nothing about the mangling of local variables.
	 But cfront mangles local variables by prepending __<nesting_level>
	 to them. As an extension to ARM demangling we handle this case.  */
      if ((LUCID_DEMANGLING || ARM_DEMANGLING || HP_DEMANGLING)
	  && isdigit ((unsigned char)scan[2]))
	{
	  *mangled = scan + 2;
	  consume_count (mangled);
	  string_append (declp, *mangled);
	  *mangled += strlen (*mangled);
	  success = 1; 
	}
      else
	{
	  /* A GNU style constructor starts with __[0-9Qt].  But cfront uses
	     names like __Q2_3foo3bar for nested type names.  So don't accept
	     this style of constructor for cfront demangling.  A GNU
	     style member-template constructor starts with 'H'. */
	  if (!(LUCID_DEMANGLING || ARM_DEMANGLING || HP_DEMANGLING || EDG_DEMANGLING))
	    work -> constructor += 1;
	  *mangled = scan + 2;
	}
    }
  else if (ARM_DEMANGLING && scan[2] == 'p' && scan[3] == 't')
    {
      /* Cfront-style parameterized type.  Handled later as a signature. */
      success = 1;

      /* ARM template? */
      demangle_arm_hp_template (work, mangled, strlen (*mangled), declp);
    }
  else if (EDG_DEMANGLING && ((scan[2] == 't' && scan[3] == 'm')
                              || (scan[2] == 'p' && scan[3] == 's')
                              || (scan[2] == 'p' && scan[3] == 't')))
    {
      /* EDG-style parameterized type.  Handled later as a signature. */
      success = 1;

      /* EDG template? */
      demangle_arm_hp_template (work, mangled, strlen (*mangled), declp);
    }
  else if ((scan == *mangled) && !isdigit ((unsigned char)scan[2])
	   && (scan[2] != 't'))
    {
      /* Mangled name starts with "__".  Skip over any leading '_' characters,
	 then find the next "__" that separates the prefix from the signature.
	 */
      if (!(ARM_DEMANGLING || LUCID_DEMANGLING || HP_DEMANGLING || EDG_DEMANGLING)
	  || (arm_special (mangled, declp) == 0))
	{
	  while (*scan == '_')
	    {
	      scan++;
	    }
	  if ((scan = mystrstr (scan, "__")) == NULL || (*(scan + 2) == '\0'))
	    {
	      /* No separator (I.E. "__not_mangled"), or empty signature
		 (I.E. "__not_mangled_either__") */
	      success = 0;
	    }
	  else
	    {
	      demangle_function_name (work, mangled, declp, scan);
	    }
	}
    }
  else if (*(scan + 2) != '\0')
    {
      /* Mangled name does not start with "__" but does have one somewhere
	 in there with non empty stuff after it.  Looks like a global
	 function name.  */
      demangle_function_name (work, mangled, declp, scan);
    }
  else
    {
      /* Doesn't look like a mangled name */
      success = 0;
    }

  if (!success && (work->constructor == 2 || work->destructor == 2))
    {
      string_append (declp, *mangled);
      *mangled += strlen (*mangled);
      success = 1;
    } 
  return (success);
}

/*

LOCAL FUNCTION

	gnu_special -- special handling of gnu mangled strings

SYNOPSIS

	static int
	gnu_special (struct work_stuff *work, const char **mangled,
		     string *declp);


DESCRIPTION

	Process some special GNU style mangling forms that don't fit
	the normal pattern.  For example:

		_$_3foo		(destructor for class foo)
		_vt$foo		(foo virtual table)
		_vt$foo$bar	(foo::bar virtual table)
		__vt_foo	(foo virtual table, new style with thunks)
		_3foo$varname	(static data member)
		_Q22rs2tu$vw	(static data member)
		__t6vector1Zii	(constructor with template)
		__thunk_4__$_7ostream (virtual function thunk)
 */

static int
gnu_special (work, mangled, declp)
     struct work_stuff *work;
     const char **mangled;
     string *declp;
{
  int n;
  int success = 1;
  const char *p;

  if ((*mangled)[0] == '_'
      && strchr (cplus_markers, (*mangled)[1]) != NULL
      && (*mangled)[2] == '_')
    {
      /* Found a GNU style destructor, get past "_<CPLUS_MARKER>_" */
      (*mangled) += 3;
      work -> destructor += 1;
    }
  else if ((*mangled)[0] == '_'
	   && (((*mangled)[1] == '_'
		&& (*mangled)[2] == 'v'
		&& (*mangled)[3] == 't'
		&& (*mangled)[4] == '_')
	       || ((*mangled)[1] == 'v'
		   && (*mangled)[2] == 't'
		   && strchr (cplus_markers, (*mangled)[3]) != NULL)))
    {
      /* Found a GNU style virtual table, get past "_vt<CPLUS_MARKER>"
         and create the decl.  Note that we consume the entire mangled
	 input string, which means that demangle_signature has no work
	 to do.  */
      if ((*mangled)[2] == 'v')
	(*mangled) += 5; /* New style, with thunks: "__vt_" */
      else
	(*mangled) += 4; /* Old style, no thunks: "_vt<CPLUS_MARKER>" */
      while (**mangled != '\0')
	{
	  switch (**mangled)
	    {
	    case 'Q':
	    case 'K':
	      success = demangle_qualified (work, mangled, declp, 0, 1);
	      break;
	    case 't':
	      success = demangle_template (work, mangled, declp, 0, 1,
					   1);
	      break;
	    default:
	      if (isdigit((unsigned char)*mangled[0]))
		{
		  n = consume_count(mangled);
		  /* We may be seeing a too-large size, or else a
		     ".<digits>" indicating a static local symbol.  In
		     any case, declare victory and move on; *don't* try
		     to use n to allocate.  */
		  if (n > (int) strlen (*mangled))
		    {
		      success = 1;
		      break;
		    }
		}
	      else
		{
		  n = strcspn (*mangled, cplus_markers);
		}
	      string_appendn (declp, *mangled, n);
	      (*mangled) += n;
	    }

	  p = strpbrk (*mangled, cplus_markers);
	  if (success && ((p == NULL) || (p == *mangled)))
	    {
	      if (p != NULL)
		{
		  string_append (declp, SCOPE_STRING (work));
		  (*mangled)++;
		}
	    }
	  else
	    {
	      success = 0;
	      break;
	    }
	}
      if (success)
	string_append (declp, " virtual table");
    }
  else if ((*mangled)[0] == '_'
	   && (strchr("0123456789Qt", (*mangled)[1]) != NULL)
	   && (p = strpbrk (*mangled, cplus_markers)) != NULL)
    {
      /* static data member, "_3foo$varname" for example */
      (*mangled)++;
      switch (**mangled)
	{
	case 'Q':
	case 'K':
	  success = demangle_qualified (work, mangled, declp, 0, 1);
	  break;
	case 't':
	  success = demangle_template (work, mangled, declp, 0, 1, 1);
	  break;
	default:
	  n = consume_count (mangled);
	  string_appendn (declp, *mangled, n);
	  (*mangled) += n;
	}
      if (success && (p == *mangled))
	{
	  /* Consumed everything up to the cplus_marker, append the
	     variable name.  */
	  (*mangled)++;
	  string_append (declp, SCOPE_STRING (work));
	  n = strlen (*mangled);
	  string_appendn (declp, *mangled, n);
	  (*mangled) += n;
	}
      else
	{
	  success = 0;
	}
    }
  else if (strncmp (*mangled, "__thunk_", 8) == 0)
    {
      int delta = ((*mangled) += 8, consume_count (mangled));
      char *method = internal_cplus_demangle (work, ++*mangled);
      if (method)
	{
	  char buf[50];
	  sprintf (buf, "virtual function thunk (delta:%d) for ", -delta);
	  string_append (declp, buf);
	  string_append (declp, method);
	  free (method);
	  n = strlen (*mangled);
	  (*mangled) += n;
	}
      else
	{
	  success = 0;
	}
    }
  else if (strncmp (*mangled, "__t", 3) == 0
	   && ((*mangled)[3] == 'i' || (*mangled)[3] == 'f'))
    {
      p = (*mangled)[3] == 'i' ? " type_info node" : " type_info function";
      (*mangled) += 4;
      switch (**mangled)
	{
	case 'Q':
	case 'K':
	  success = demangle_qualified (work, mangled, declp, 0, 1);
	  break;
	case 't':
	  success = demangle_template (work, mangled, declp, 0, 1, 1);
	  break;
	default:
	  success = demangle_fund_type (work, mangled, declp);
	  break;
	}
      if (success && **mangled != '\0')
	success = 0;
      if (success)
	string_append (declp, p);
    }
  else
    {
      success = 0;
    }
  return (success);
}

static void
recursively_demangle(work, mangled, result, namelength)
     struct work_stuff *work;
     const char **mangled;
     string *result;
     int namelength;
{
  char * recurse = (char *)NULL;
  char * recurse_dem = (char *)NULL;

  recurse = (char *) xmalloc (namelength + 1);
  memcpy (recurse, *mangled, namelength);
  recurse[namelength] = '\000';

  recurse_dem = cplus_demangle (recurse, work->options);

  if (recurse_dem)
    {
      string_append (result, recurse_dem);
      free (recurse_dem);
    }
  else
    {
      string_appendn (result, *mangled, namelength);
    }
  free (recurse);
  *mangled += namelength;
}

/*

LOCAL FUNCTION

	arm_special -- special handling of ARM/lucid mangled strings

SYNOPSIS

	static int
	arm_special (const char **mangled,
		     string *declp);


DESCRIPTION

	Process some special ARM style mangling forms that don't fit
	the normal pattern.  For example:

		__vtbl__3foo		(foo virtual table)
		__vtbl__3foo__3bar	(bar::foo virtual table)

 */

static int
arm_special (mangled, declp)
     const char **mangled;
     string *declp;
{
  int n;
  int success = 1;
  const char *scan;

  if (strncmp (*mangled, ARM_VTABLE_STRING, ARM_VTABLE_STRLEN) == 0)
    {
      /* Found a ARM style virtual table, get past ARM_VTABLE_STRING
         and create the decl.  Note that we consume the entire mangled
	 input string, which means that demangle_signature has no work
	 to do.  */
      scan = *mangled + ARM_VTABLE_STRLEN;
      while (*scan != '\0')        /* first check it can be demangled */
        {
          n = consume_count (&scan);
          if (n==0)
	    {
	      return (0);           /* no good */
	    }
          scan += n;
          if (scan[0] == '_' && scan[1] == '_')
	    {
	      scan += 2;
	    }
        }
      (*mangled) += ARM_VTABLE_STRLEN;
      while (**mangled != '\0')
	{
	  n = consume_count (mangled);
	  string_prependn (declp, *mangled, n);
	  (*mangled) += n;
	  if ((*mangled)[0] == '_' && (*mangled)[1] == '_')
	    {
	      string_prepend (declp, "::");
	      (*mangled) += 2;
	    }
	}
      string_append (declp, " virtual table");
    }
  else
    {
      success = 0;
    }
  return (success);
}

/*

LOCAL FUNCTION

	demangle_qualified -- demangle 'Q' qualified name strings

SYNOPSIS

	static int
	demangle_qualified (struct work_stuff *, const char *mangled,
			    string *result, int isfuncname, int append);

DESCRIPTION

	Demangle a qualified name, such as "Q25Outer5Inner" which is
	the mangled form of "Outer::Inner".  The demangled output is
	prepended or appended to the result string according to the
	state of the append flag.

	If isfuncname is nonzero, then the qualified name we are building
	is going to be used as a member function name, so if it is a
	constructor or destructor function, append an appropriate
	constructor or destructor name.  I.E. for the above example,
	the result for use as a constructor is "Outer::Inner::Inner"
	and the result for use as a destructor is "Outer::Inner::~Inner".

BUGS

	Numeric conversion is ASCII dependent (FIXME).

 */

static int
demangle_qualified (work, mangled, result, isfuncname, append)
     struct work_stuff *work;
     const char **mangled;
     string *result;
     int isfuncname;
     int append;
{
  int qualifiers = 0;
  int success = 1;
  const char *p;
  char num[2];
  string temp;
  string last_name;
  int bindex = register_Btype (work);

  /* We only make use of ISFUNCNAME if the entity is a constructor or
     destructor.  */
  isfuncname = (isfuncname 
		&& ((work->constructor & 1) || (work->destructor & 1)));

  string_init (&temp);
  string_init (&last_name);

  if ((*mangled)[0] == 'K')
    {
    /* Squangling qualified name reuse */
      int idx;
      (*mangled)++;
      idx = consume_count_with_underscores (mangled);
      if (idx == -1 || idx >= work -> numk)
        success = 0;
      else
        string_append (&temp, work -> ktypevec[idx]);
    }
  else
    switch ((*mangled)[1])
    {
    case '_':
      /* GNU mangled name with more than 9 classes.  The count is preceded
	 by an underscore (to distinguish it from the <= 9 case) and followed
	 by an underscore.  */
      p = *mangled + 2;
      qualifiers = atoi (p);
      if (!isdigit ((unsigned char)*p) || *p == '0')
	success = 0;

      /* Skip the digits.  */
      while (isdigit ((unsigned char)*p))
	++p;

      if (*p != '_')
	success = 0;

      *mangled = p + 1;
      break;

    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      /* The count is in a single digit.  */
      num[0] = (*mangled)[1];
      num[1] = '\0';
      qualifiers = atoi (num);

      /* If there is an underscore after the digit, skip it.  This is
	 said to be for ARM-qualified names, but the ARM makes no
	 mention of such an underscore.  Perhaps cfront uses one.  */
      if ((*mangled)[2] == '_')
	{
	  (*mangled)++;
	}
      (*mangled) += 2;
      break;

    case '0':
    default:
      success = 0;
    }

  if (!success)
    return success;

  /* Pick off the names and collect them in the temp buffer in the order
     in which they are found, separated by '::'.  */

  while (qualifiers-- > 0)
    {
      int remember_K = 1;
      string_clear (&last_name);

      if (*mangled[0] == '_') 
	(*mangled)++;

      if (*mangled[0] == 't')
	{
	  /* Here we always append to TEMP since we will want to use
	     the template name without the template parameters as a
	     constructor or destructor name.  The appropriate
	     (parameter-less) value is returned by demangle_template
	     in LAST_NAME.  We do not remember the template type here,
	     in order to match the G++ mangling algorithm.  */
	  success = demangle_template(work, mangled, &temp, 
				      &last_name, 1, 0);
	  if (!success) 
	    break;
	} 
      else if (*mangled[0] == 'K')
	{
          int idx;
          (*mangled)++;
          idx = consume_count_with_underscores (mangled);
          if (idx == -1 || idx >= work->numk)
            success = 0;
          else
            string_append (&temp, work->ktypevec[idx]);
          remember_K = 0;

	  if (!success) break;
	}
      else
	{
	  if (EDG_DEMANGLING)
            {
	      int namelength;
 	      /* Now recursively demangle the qualifier
 	       * This is necessary to deal with templates in 
 	       * mangling styles like EDG */ 
	      namelength = consume_count (mangled);
 	      recursively_demangle(work, mangled, &temp, namelength);
            }
          else
            {
              success = do_type (work, mangled, &last_name);
              if (!success)
                break;
              string_appends (&temp, &last_name);
            }
	}

      if (remember_K)
	remember_Ktype (work, temp.b, LEN_STRING (&temp));

      if (qualifiers > 0)
	string_append (&temp, SCOPE_STRING (work));
    }

  remember_Btype (work, temp.b, LEN_STRING (&temp), bindex);

  /* If we are using the result as a function name, we need to append
     the appropriate '::' separated constructor or destructor name.
     We do this here because this is the most convenient place, where
     we already have a pointer to the name and the length of the name.  */

  if (isfuncname) 
    {
      string_append (&temp, SCOPE_STRING (work));
      if (work -> destructor & 1)
	string_append (&temp, "~");
      string_appends (&temp, &last_name);
    }

  /* Now either prepend the temp buffer to the result, or append it, 
     depending upon the state of the append flag.  */

  if (append)
    string_appends (result, &temp);
  else
    {
      if (!STRING_EMPTY (result))
	string_append (&temp, SCOPE_STRING (work));
      string_prepends (result, &temp);
    }

  string_delete (&last_name);
  string_delete (&temp);
  return (success);
}

/*

LOCAL FUNCTION

	get_count -- convert an ascii count to integer, consuming tokens

SYNOPSIS

	static int
	get_count (const char **type, int *count)

DESCRIPTION

	Return 0 if no conversion is performed, 1 if a string is converted.
*/

static int
get_count (type, count)
     const char **type;
     int *count;
{
  const char *p;
  int n;

  if (!isdigit ((unsigned char)**type))
    {
      return (0);
    }
  else
    {
      *count = **type - '0';
      (*type)++;
      if (isdigit ((unsigned char)**type))
	{
	  p = *type;
	  n = *count;
	  do 
	    {
	      n *= 10;
	      n += *p - '0';
	      p++;
	    } 
	  while (isdigit ((unsigned char)*p));
	  if (*p == '_')
	    {
	      *type = p + 1;
	      *count = n;
	    }
	}
    }
  return (1);
}

/* RESULT will be initialised here; it will be freed on failure.  The
   value returned is really a type_kind_t.  */

static int
do_type (work, mangled, result)
     struct work_stuff *work;
     const char **mangled;
     string *result;
{
  int n;
  int done;
  int success;
  string decl;
  const char *remembered_type;
  int type_quals;
  string btype;
  type_kind_t tk = tk_none;

  string_init (&btype);
  string_init (&decl);
  string_init (result);

  done = 0;
  success = 1;
  while (success && !done)
    {
      int member;
      switch (**mangled)
	{

	  /* A pointer type */
	case 'P':
	case 'p':
	  (*mangled)++;
	    string_prepend (&decl, "*");
	  if (tk == tk_none)
	    tk = tk_pointer;
	  break;

	  /* A reference type */
	case 'R':
	  (*mangled)++;
	  string_prepend (&decl, "&");
	  if (tk == tk_none)
	    tk = tk_reference;
	  break;

	  /* An array */
	case 'A':
	  {
	    ++(*mangled);
	    if (!STRING_EMPTY (&decl)
		&& (decl.b[0] == '*' || decl.b[0] == '&'))
	      {
		string_prepend (&decl, "(");
		string_append (&decl, ")");
	      }
	    string_append (&decl, "[");
	    if (**mangled != '_')
	      success = demangle_template_value_parm (work, mangled, &decl,
						      tk_integral);
	    if (**mangled == '_')
	      ++(*mangled);
	    string_append (&decl, "]");
	    break;
	  }

	/* A back reference to a previously seen type */
	case 'T':
	  (*mangled)++;
	  if (!get_count (mangled, &n) || n >= work -> ntypes)
	    {
	      success = 0;
	    }
	  else
	    {
	      remembered_type = work -> typevec[n];
	      mangled = &remembered_type;
	    }
	  break;

	  /* A function */
	case 'F':
	  (*mangled)++;
	    if (!STRING_EMPTY (&decl)
		&& (decl.b[0] == '*' || decl.b[0] == '&'))
	    {
	      string_prepend (&decl, "(");
	      string_append (&decl, ")");
	    }
	  /* After picking off the function args, we expect to either find the
	     function return type (preceded by an '_') or the end of the
	     string.  */
	  if (!demangle_nested_args (work, mangled, &decl)
	      || (**mangled != '_' && **mangled != '\0'))
	    {
	      success = 0;
	      break;
	    }
	  if (success && (**mangled == '_'))
	    (*mangled)++;
	  break;

	case 'M':
	case 'O':
	  {
	    type_quals = TYPE_UNQUALIFIED;

	    member = **mangled == 'M';
	    (*mangled)++;
	    if (!isdigit ((unsigned char)**mangled) && **mangled != 't')
	      {
		success = 0;
		break;
	      }

	    string_append (&decl, ")");
	    string_prepend (&decl, SCOPE_STRING (work));
	    if (isdigit ((unsigned char)**mangled))
	      {
		n = consume_count (mangled);
		if ((int) strlen (*mangled) < n)
		  {
		    success = 0;
		    break;
		  }
		string_prependn (&decl, *mangled, n);
		*mangled += n;
	      }
	    else
	      {
		string temp;
		string_init (&temp);
		success = demangle_template (work, mangled, &temp,
					     NULL, 1, 1);
		if (success)
		  {
		    string_prependn (&decl, temp.b, temp.p - temp.b);
		    string_clear (&temp);
		  }
		else
		  break;
	      }
	    string_prepend (&decl, "(");
	    if (member)
	      {
		switch (**mangled)
		  {
		  case 'C':
		  case 'V':
		  case 'u':
		    type_quals |= code_for_qualifier (**mangled);
		    (*mangled)++;
		    break;

		  default:
		    break;
		  }

		if (*(*mangled)++ != 'F')
		  {
		    success = 0;
		    break;
		  }
	      }
	    if ((member && !demangle_nested_args (work, mangled, &decl))
		|| **mangled != '_')
	      {
		success = 0;
		break;
	      }
	    (*mangled)++;
	    if (! PRINT_ANSI_QUALIFIERS)
	      {
		break;
	      }
	    if (type_quals != TYPE_UNQUALIFIED)
	      {
		APPEND_BLANK (&decl);
		string_append (&decl, qualifier_string (type_quals));
	      }
	    break;
	  }
        case 'G':
	  (*mangled)++;
	  break;

	case 'C':
	case 'V':
	case 'u':
	  if (PRINT_ANSI_QUALIFIERS)
	    {
	      if (!STRING_EMPTY (&decl))
		string_prepend (&decl, " ");

	      string_prepend (&decl, demangle_qualifier (**mangled));
	    }
	  (*mangled)++;
	  break;
	  /*
	    }
	    */

	  /* fall through */
	default:
	  done = 1;
	  break;
	}
    }

  if (success) switch (**mangled)
    {
      /* A qualified name, such as "Outer::Inner".  */
    case 'Q':
    case 'K':
      {
        success = demangle_qualified (work, mangled, result, 0, 1);
        break;
      }

    /* A back reference to a previously seen squangled type */
    case 'B':
      (*mangled)++;
      if (!get_count (mangled, &n) || n >= work -> numb)
	success = 0;
      else
	string_append (result, work->btypevec[n]);
      break;

    case 'X':
    case 'Y':
      /* A template parm.  We substitute the corresponding argument. */
      {
	int idx;

	(*mangled)++;
	idx = consume_count_with_underscores (mangled);

	if (idx == -1 
	    || (work->tmpl_argvec && idx >= work->ntmpl_args)
	    || consume_count_with_underscores (mangled) == -1)
	  {
	    success = 0;
	    break;
	  }

	if (work->tmpl_argvec)
	  string_append (result, work->tmpl_argvec[idx]);
	else
	  {
	    char buf[10];
	    sprintf(buf, "T%d", idx);
	    string_append (result, buf);
	  }

	success = 1;
      }
    break;

    default:
      success = demangle_fund_type (work, mangled, result);
      if (tk == tk_none)
	tk = (type_kind_t) success;
      break;
    }

  if (success)
    {
      if (!STRING_EMPTY (&decl))
	{
	  string_append (result, " ");
	  string_appends (result, &decl);
	}
    }
  else
    string_delete (result);
  string_delete (&decl);

  if (success)
    /* Assume an integral type, if we're not sure.  */
    return (int) ((tk == tk_none) ? tk_integral : tk);
  else
    return 0;
}

/* Given a pointer to a type string that represents a fundamental type
   argument (int, long, unsigned int, etc) in TYPE, a pointer to the
   string in which the demangled output is being built in RESULT, and
   the WORK structure, decode the types and add them to the result.

   For example:

   	"Ci"	=>	"const int"
	"Sl"	=>	"signed long"
	"CUs"	=>	"const unsigned short"

   The value returned is really a type_kind_t.  */

static int
demangle_fund_type (work, mangled, result)
     struct work_stuff *work;
     const char **mangled;
     string *result;
{
  int done = 0;
  int success = 1;
  char buf[10];
  int dec = 0;
  string btype;
  type_kind_t tk = tk_integral;

  string_init (&btype);

  /* First pick off any type qualifiers.  There can be more than one.  */

  while (!done)
    {
      switch (**mangled)
	{
	case 'C':
	case 'V':
	case 'u':
	  if (PRINT_ANSI_QUALIFIERS)
	    {
              if (!STRING_EMPTY (result))
                string_prepend (result, " ");
	      string_prepend (result, demangle_qualifier (**mangled));
	    }
	  (*mangled)++;
	  break;
	case 'U':
	  (*mangled)++;
	  APPEND_BLANK (result);
	  string_append (result, "unsigned");
	  break;
	case 'S': /* signed char only */
	  (*mangled)++;
	  APPEND_BLANK (result);
	  string_append (result, "signed");
	  break;
	case 'J':
	  (*mangled)++;
	  APPEND_BLANK (result);
	  string_append (result, "__complex");
	  break;
	default:
	  done = 1;
	  break;
	}
    }

  /* Now pick off the fundamental type.  There can be only one.  */

  switch (**mangled)
    {
    case '\0':
    case '_':
      break;
    case 'v':
      (*mangled)++;
      APPEND_BLANK (result);
      string_append (result, "void");
      break;
    case 'x':
      (*mangled)++;
      APPEND_BLANK (result);
      string_append (result, "long long");
      break;
    case 'l':
      (*mangled)++;
      APPEND_BLANK (result);
      string_append (result, "long");
      break;
    case 'i':
      (*mangled)++;
      APPEND_BLANK (result);
      string_append (result, "int");
      break;
    case 's':
      (*mangled)++;
      APPEND_BLANK (result);
      string_append (result, "short");
      break;
    case 'b':
      (*mangled)++;
      APPEND_BLANK (result);
      string_append (result, "bool");
      tk = tk_bool;
      break;
    case 'c':
      (*mangled)++;
      APPEND_BLANK (result);
      string_append (result, "char");
      tk = tk_char;
      break;
    case 'w':
      (*mangled)++;
      APPEND_BLANK (result);
      string_append (result, "wchar_t");
      tk = tk_char;
      break;
    case 'r':
      (*mangled)++;
      APPEND_BLANK (result);
      string_append (result, "long double");
      tk = tk_real;
      break;
    case 'd':
      (*mangled)++;
      APPEND_BLANK (result);
      string_append (result, "double");
      tk = tk_real;
      break;
    case 'f':
      (*mangled)++;
      APPEND_BLANK (result);
      string_append (result, "float");
      tk = tk_real;
      break;
    case 'G':
      (*mangled)++;
      if (!isdigit ((unsigned char)**mangled))
	{
	  success = 0;
	  break;
	}
    case 'I':
      ++(*mangled);
      if (**mangled == '_')
	{
	  int i;
	  ++(*mangled);
	  for (i = 0; **mangled != '_'; ++(*mangled), ++i)
	    buf[i] = **mangled;
	  buf[i] = '\0';
	  ++(*mangled);
	}
      else
	{
	  strncpy (buf, *mangled, 2);
	  *mangled += 2;
	}
      sscanf (buf, "%x", &dec); 
      sprintf (buf, "int%i_t", dec);
      APPEND_BLANK (result);
      string_append (result, buf);
      break;

      /* fall through */
      /* An explicit type, such as "6mytype" or "7integer" */
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      {
        int bindex = register_Btype (work);
        string bbtype;
        string_init (&bbtype);
        if (demangle_class_name (work, mangled, &bbtype)) {
          remember_Btype (work, bbtype.b, LEN_STRING (&bbtype), bindex);
          APPEND_BLANK (result);
          string_appends (result, &bbtype);
        }
        else 
          success = 0;
        string_delete (&bbtype);
        break;
      }
    case 't':
      {
        success = demangle_template (work, mangled, &btype, 0, 1, 1);
        string_appends (result, &btype);
        break;
      }
    default:
      success = 0;
      break;
    }

  return success ? ((int) tk) : 0;
}


/* Handle a template's value parameter for HP aCC (extension from ARM)
   **mangled points to 'S' or 'U' */

static int
do_hpacc_template_const_value (work, mangled, result)
     struct work_stuff *work;
     const char **mangled;
     string *result;
{
  int unsigned_const;

  if (**mangled != 'U' && **mangled != 'S')
    return 0;

  unsigned_const = (**mangled == 'U');

  (*mangled)++;

  switch (**mangled)
    {
      case 'N':
        string_append (result, "-");
        /* fall through */ 
      case 'P':
        (*mangled)++;
        break;
      case 'M':
        /* special case for -2^31 */ 
        string_append (result, "-2147483648");
        (*mangled)++;
        return 1;
      default:
        return 0;
    }

  /* We have to be looking at an integer now */
  if (!(isdigit (**mangled)))
    return 0;

  /* We only deal with integral values for template
     parameters -- so it's OK to look only for digits */
  while (isdigit (**mangled))
    {
      char_str[0] = **mangled;
      string_append (result, char_str);
      (*mangled)++;
    }

  if (unsigned_const)
    string_append (result, "U");

  /* FIXME? Some day we may have 64-bit (or larger :-) ) constants
     with L or LL suffixes. pai/1997-09-03 */

  return 1; /* success */ 
}

/* Handle a template's literal parameter for HP aCC (extension from ARM)
   **mangled is pointing to the 'A' */

static int
do_hpacc_template_literal (work, mangled, result)
     struct work_stuff *work;
     const char **mangled;
     string *result;
{
  int literal_len = 0;
  char * recurse;
  char * recurse_dem;

  if (**mangled != 'A')
    return 0;

  (*mangled)++;

  literal_len = consume_count (mangled);

  if (!literal_len)
    return 0;

  /* Literal parameters are names of arrays, functions, etc.  and the
     canonical representation uses the address operator */
  string_append (result, "&");

  /* Now recursively demangle the literal name */ 
  recurse = (char *) xmalloc (literal_len + 1);
  memcpy (recurse, *mangled, literal_len);
  recurse[literal_len] = '\000';

  recurse_dem = cplus_demangle (recurse, work->options);

  if (recurse_dem)
    {
      string_append (result, recurse_dem);
      free (recurse_dem);
    }
  else
    {
      string_appendn (result, *mangled, literal_len);
    }
  (*mangled) += literal_len;
  free (recurse);

  return 1;
}

static int
snarf_numeric_literal (args, arg)
     const char ** args;
     string * arg;
{
  if (**args == '-')
    {
      char_str[0] = '-';
      string_append (arg, char_str);
      (*args)++;
    }
  else if (**args == '+')
    (*args)++;

  if (!isdigit (**args))
    return 0;

  while (isdigit (**args))
    {
      char_str[0] = **args;
      string_append (arg, char_str);
      (*args)++;
    }

  return 1;
}

/* Demangle the next argument, given by MANGLED into RESULT, which
   *should be an uninitialized* string.  It will be initialized here,
   and free'd should anything go wrong.  */

static int
do_arg (work, mangled, result)
     struct work_stuff *work;
     const char **mangled;
     string *result;
{
  /* Remember where we started so that we can record the type, for
     non-squangling type remembering.  */
  const char *start = *mangled;

  string_init (result);

  if (work->nrepeats > 0)
    {
      --work->nrepeats;

      if (work->previous_argument == 0)
	return 0;

      /* We want to reissue the previous type in this argument list.  */ 
      string_appends (result, work->previous_argument);
      return 1;
    }

  if (**mangled == 'n')
    {
      /* A squangling-style repeat.  */
      (*mangled)++;
      work->nrepeats = consume_count(mangled);

      if (work->nrepeats == 0)
	/* This was not a repeat count after all.  */
	return 0;

      if (work->nrepeats > 9)
	{
	  if (**mangled != '_')
	    /* The repeat count should be followed by an '_' in this
	       case.  */
	    return 0;
	  else
	    (*mangled)++;
	}

      /* Now, the repeat is all set up.  */
      return do_arg (work, mangled, result);
    }

  /* Save the result in WORK->previous_argument so that we can find it
     if it's repeated.  Note that saving START is not good enough: we
     do not want to add additional types to the back-referenceable
     type vector when processing a repeated type.  */
  if (work->previous_argument)
    string_clear (work->previous_argument);
  else
    {
      work->previous_argument = (string*) xmalloc (sizeof (string));
      string_init (work->previous_argument);
    }

  if (!do_type (work, mangled, work->previous_argument))
    return 0;

  string_appends (result, work->previous_argument);

  remember_type (work, start, *mangled - start);
  return 1;
}

static void
remember_type (work, start, len)
     struct work_stuff *work;
     const char *start;
     int len;
{
  char *tem;

  if (work->forgetting_types)
    return;

  if (work -> ntypes >= work -> typevec_size)
    {
      if (work -> typevec_size == 0)
	{
	  work -> typevec_size = 3;
	  work -> typevec
	    = (char **) xmalloc (sizeof (char *) * work -> typevec_size);
	}
      else
	{
	  work -> typevec_size *= 2;
	  work -> typevec
	    = (char **) xrealloc ((char *)work -> typevec,
				  sizeof (char *) * work -> typevec_size);
	}
    }
  tem = xmalloc (len + 1);
  memcpy (tem, start, len);
  tem[len] = '\0';
  work -> typevec[work -> ntypes++] = tem;
}


/* Remember a K type class qualifier. */
static void
remember_Ktype (work, start, len)
     struct work_stuff *work;
     const char *start;
     int len;
{
  char *tem;

  if (work -> numk >= work -> ksize)
    {
      if (work -> ksize == 0)
	{
	  work -> ksize = 5;
	  work -> ktypevec
	    = (char **) xmalloc (sizeof (char *) * work -> ksize);
	}
      else
	{
	  work -> ksize *= 2;
	  work -> ktypevec
	    = (char **) xrealloc ((char *)work -> ktypevec,
				  sizeof (char *) * work -> ksize);
	}
    }
  tem = xmalloc (len + 1);
  memcpy (tem, start, len);
  tem[len] = '\0';
  work -> ktypevec[work -> numk++] = tem;
}

/* Register a B code, and get an index for it. B codes are registered
   as they are seen, rather than as they are completed, so map<temp<char> >  
   registers map<temp<char> > as B0, and temp<char> as B1 */

static int
register_Btype (work)
     struct work_stuff *work;
{
  int ret;

  if (work -> numb >= work -> bsize)
    {
      if (work -> bsize == 0)
	{
	  work -> bsize = 5;
	  work -> btypevec
	    = (char **) xmalloc (sizeof (char *) * work -> bsize);
	}
      else
	{
	  work -> bsize *= 2;
	  work -> btypevec
	    = (char **) xrealloc ((char *)work -> btypevec,
				  sizeof (char *) * work -> bsize);
	}
    }
  ret = work -> numb++;
  work -> btypevec[ret] = NULL;
  return(ret);
}

/* Store a value into a previously registered B code type. */

static void
remember_Btype (work, start, len, index)
     struct work_stuff *work;
     const char *start;
     int len, index;
{
  char *tem;

  tem = xmalloc (len + 1);
  memcpy (tem, start, len);
  tem[len] = '\0';
  work -> btypevec[index] = tem;
}

/* Lose all the info related to B and K type codes. */
static void
forget_B_and_K_types (work)
     struct work_stuff *work;
{
  int i;

  while (work -> numk > 0)
    {
      i = --(work -> numk);
      if (work -> ktypevec[i] != NULL)
	{
	  free (work -> ktypevec[i]);
	  work -> ktypevec[i] = NULL;
	}
    }

  while (work -> numb > 0)
    {
      i = --(work -> numb);
      if (work -> btypevec[i] != NULL)
	{
	  free (work -> btypevec[i]);
	  work -> btypevec[i] = NULL;
	}
    }
}
/* Forget the remembered types, but not the type vector itself.  */

static void
forget_types (work)
     struct work_stuff *work;
{
  int i;

  while (work -> ntypes > 0)
    {
      i = --(work -> ntypes);
      if (work -> typevec[i] != NULL)
	{
	  free (work -> typevec[i]);
	  work -> typevec[i] = NULL;
	}
    }
}

/* Process the argument list part of the signature, after any class spec
   has been consumed, as well as the first 'F' character (if any).  For
   example:

   "__als__3fooRT0"		=>	process "RT0"
   "complexfunc5__FPFPc_PFl_i"	=>	process "PFPc_PFl_i"

   DECLP must be already initialised, usually non-empty.  It won't be freed
   on failure.

   Note that g++ differs significantly from ARM and lucid style mangling
   with regards to references to previously seen types.  For example, given
   the source fragment:

     class foo {
       public:
       foo::foo (int, foo &ia, int, foo &ib, int, foo &ic);
     };

     foo::foo (int, foo &ia, int, foo &ib, int, foo &ic) { ia = ib = ic; }
     void foo (int, foo &ia, int, foo &ib, int, foo &ic) { ia = ib = ic; }

   g++ produces the names:

     __3fooiRT0iT2iT2
     foo__FiR3fooiT1iT1

   while lcc (and presumably other ARM style compilers as well) produces:

     foo__FiR3fooT1T2T1T2
     __ct__3fooFiR3fooT1T2T1T2

   Note that g++ bases its type numbers starting at zero and counts all
   previously seen types, while lucid/ARM bases its type numbers starting
   at one and only considers types after it has seen the 'F' character
   indicating the start of the function args.  For lucid/ARM style, we
   account for this difference by discarding any previously seen types when
   we see the 'F' character, and subtracting one from the type number
   reference.

 */

static int
demangle_args (work, mangled, declp)
     struct work_stuff *work;
     const char **mangled;
     string *declp;
{
  string arg;
  int need_comma = 0;
  int r;
  int t;
  const char *tem;
  char temptype;

  if (PRINT_ARG_TYPES)
    {
      string_append (declp, "(");
      if (**mangled == '\0')
	{
	  string_append (declp, "void");
	}
    }

  while ((**mangled != '_' && **mangled != '\0' && **mangled != 'e')
	 || work->nrepeats > 0)
    {
      if ((**mangled == 'N') || (**mangled == 'T'))
	{
	  temptype = *(*mangled)++;

	  if (temptype == 'N')
	    {
	      if (!get_count (mangled, &r))
		{
		  return (0);
		}
	    }
	  else
	    {
	      r = 1;
	    }
          if ((HP_DEMANGLING || ARM_DEMANGLING || EDG_DEMANGLING) && work -> ntypes >= 10)
            {
              /* If we have 10 or more types we might have more than a 1 digit
                 index so we'll have to consume the whole count here. This
                 will lose if the next thing is a type name preceded by a
                 count but it's impossible to demangle that case properly
                 anyway. Eg if we already have 12 types is T12Pc "(..., type1,
                 Pc, ...)"  or "(..., type12, char *, ...)" */
              if ((t = consume_count(mangled)) == 0)
                {
                  return (0);
                }
            }
          else
	    {
	      if (!get_count (mangled, &t))
	    	{
	          return (0);
	    	}
	    }
	  if (LUCID_DEMANGLING || ARM_DEMANGLING || HP_DEMANGLING || EDG_DEMANGLING)
	    {
	      t--;
	    }
	  /* Validate the type index.  Protect against illegal indices from
	     malformed type strings.  */
	  if ((t < 0) || (t >= work -> ntypes))
	    {
	      return (0);
	    }
	  while (work->nrepeats > 0 || --r >= 0)
	    {
	      tem = work -> typevec[t];
	      if (need_comma && PRINT_ARG_TYPES)
		{
		  string_append (declp, ", ");
		}
	      if (!do_arg (work, &tem, &arg))
		{
		  return (0);
		}
	      if (PRINT_ARG_TYPES)
		{
		  string_appends (declp, &arg);
		}
	      string_delete (&arg);
	      need_comma = 1;
	    }
	}
      else
	{
	  if (need_comma && PRINT_ARG_TYPES)
	    string_append (declp, ", ");
	  if (!do_arg (work, mangled, &arg))
	    return (0);
	  if (PRINT_ARG_TYPES)
	    string_appends (declp, &arg);
	  string_delete (&arg);
	  need_comma = 1;
	}
    }

  if (**mangled == 'e')
    {
      (*mangled)++;
      if (PRINT_ARG_TYPES)
	{
	  if (need_comma)
	    {
	      string_append (declp, ",");
	    }
	  string_append (declp, "...");
	}
    }

  if (PRINT_ARG_TYPES)
    {
      string_append (declp, ")");
    }
  return (1);
}

/* Like demangle_args, but for demangling the argument lists of function
   and method pointers or references, not top-level declarations.  */

static int
demangle_nested_args (work, mangled, declp)
     struct work_stuff *work;
     const char **mangled;
     string *declp;
{
  string* saved_previous_argument;
  int result;
  int saved_nrepeats;

  /* The G++ name-mangling algorithm does not remember types on nested
     argument lists, unless -fsquangling is used, and in that case the
     type vector updated by remember_type is not used.  So, we turn
     off remembering of types here.  */
  ++work->forgetting_types;

  /* For the repeat codes used with -fsquangling, we must keep track of
     the last argument.  */
  saved_previous_argument = work->previous_argument;
  saved_nrepeats = work->nrepeats;
  work->previous_argument = 0;
  work->nrepeats = 0;

  /* Actually demangle the arguments.  */
  result = demangle_args (work, mangled, declp);

  /* Restore the previous_argument field.  */
  if (work->previous_argument)
    string_delete (work->previous_argument);
  work->previous_argument = saved_previous_argument;
  work->nrepeats = saved_nrepeats;

  return result;
}

static void
demangle_function_name (work, mangled, declp, scan)
     struct work_stuff *work;
     const char **mangled;
     string *declp;
     const char *scan;
{
  size_t i;
  string type;
  const char *tem;

  string_appendn (declp, (*mangled), scan - (*mangled));
  string_need (declp, 1);
  *(declp -> p) = '\0';

  /* Consume the function name, including the "__" separating the name
     from the signature.  We are guaranteed that SCAN points to the
     separator.  */

  (*mangled) = scan + 2;
  /* We may be looking at an instantiation of a template function:
     foo__Xt1t2_Ft3t4, where t1, t2, ... are template arguments and a
     following _F marks the start of the function arguments.  Handle
     the template arguments first. */

  if (HP_DEMANGLING && (**mangled == 'X'))
    {
      demangle_arm_hp_template (work, mangled, 0, declp);
      /* This leaves MANGLED pointing to the 'F' marking func args */
    }

  if (LUCID_DEMANGLING || ARM_DEMANGLING || HP_DEMANGLING || EDG_DEMANGLING)
    {

      /* See if we have an ARM style constructor or destructor operator.
	 If so, then just record it, clear the decl, and return.
	 We can't build the actual constructor/destructor decl until later,
	 when we recover the class name from the signature.  */

      if (strcmp (declp -> b, "__ct") == 0)
	{
	  work -> constructor += 1;
	  string_clear (declp);
	  return;
	}
      else if (strcmp (declp -> b, "__dt") == 0)
	{
	  work -> destructor += 1;
	  string_clear (declp);
	  return;
	}
    }

  if (declp->p - declp->b >= 3 
      && declp->b[0] == 'o'
      && declp->b[1] == 'p'
      && strchr (cplus_markers, declp->b[2]) != NULL)
    {
      /* see if it's an assignment expression */
      if (declp->p - declp->b >= 10 /* op$assign_ */
	  && memcmp (declp->b + 3, "assign_", 7) == 0)
	{
	  for (i = 0; i < sizeof (optable) / sizeof (optable[0]); i++)
	    {
	      int len = declp->p - declp->b - 10;
	      if ((int) strlen (optable[i].in) == len
		  && memcmp (optable[i].in, declp->b + 10, len) == 0)
		{
		  string_clear (declp);
		  string_append (declp, "operator");
		  string_append (declp, optable[i].out);
		  string_append (declp, "=");
		  break;
		}
	    }
	}
      else
	{
	  for (i = 0; i < sizeof (optable) / sizeof (optable[0]); i++)
	    {
	      int len = declp->p - declp->b - 3;
	      if ((int) strlen (optable[i].in) == len 
		  && memcmp (optable[i].in, declp->b + 3, len) == 0)
		{
		  string_clear (declp);
		  string_append (declp, "operator");
		  string_append (declp, optable[i].out);
		  break;
		}
	    }
	}
    }
  else if (declp->p - declp->b >= 5 && memcmp (declp->b, "type", 4) == 0
	   && strchr (cplus_markers, declp->b[4]) != NULL)
    {
      /* type conversion operator */
      tem = declp->b + 5;
      if (do_type (work, &tem, &type))
	{
	  string_clear (declp);
	  string_append (declp, "operator ");
	  string_appends (declp, &type);
	  string_delete (&type);
	}
    }
  else if (declp->b[0] == '_' && declp->b[1] == '_'
	   && declp->b[2] == 'o' && declp->b[3] == 'p')
    {
      /* ANSI.  */
      /* type conversion operator.  */
      tem = declp->b + 4;
      if (do_type (work, &tem, &type))
	{
	  string_clear (declp);
	  string_append (declp, "operator ");
	  string_appends (declp, &type);
	  string_delete (&type);
	}
    }
  else if (declp->b[0] == '_' && declp->b[1] == '_'
	   && declp->b[2] >= 'a' && declp->b[2] <= 'z'
	   && declp->b[3] >= 'a' && declp->b[3] <= 'z')
    {
      if (declp->b[4] == '\0')
	{
	  /* Operator.  */
	  for (i = 0; i < sizeof (optable) / sizeof (optable[0]); i++)
	    {
	      if (strlen (optable[i].in) == 2
		  && memcmp (optable[i].in, declp->b + 2, 2) == 0)
		{
		  string_clear (declp);
		  string_append (declp, "operator");
		  string_append (declp, optable[i].out);
		  break;
		}
	    }
	}
      else
	{
	  if (declp->b[2] == 'a' && declp->b[5] == '\0')
	    {
	      /* Assignment.  */
	      for (i = 0; i < sizeof (optable) / sizeof (optable[0]); i++)
		{
		  if (strlen (optable[i].in) == 3
		      && memcmp (optable[i].in, declp->b + 2, 3) == 0)
		    {
		      string_clear (declp);
		      string_append (declp, "operator");
		      string_append (declp, optable[i].out);
		      break;
		    }		      
		}
	    }
	}
    }
}

/* a mini string-handling package */

static void
string_need (s, n)
     string *s;
     int n;
{
  int tem;

  if (s->b == NULL)
    {
      if (n < 32)
	{
	  n = 32;
	}
      s->p = s->b = xmalloc (n);
      s->e = s->b + n;
    }
  else if (s->e - s->p < n)
    {
      tem = s->p - s->b;
      n += tem;
      n *= 2;
      s->b = xrealloc (s->b, n);
      s->p = s->b + tem;
      s->e = s->b + n;
    }
}

static void
string_delete (s)
     string *s;
{
  if (s->b != NULL)
    {
      free (s->b);
      s->b = s->e = s->p = NULL;
    }
}

static void
string_init (s)
     string *s;
{
  s->b = s->p = s->e = NULL;
}

static void 
string_clear (s)
     string *s;
{
  s->p = s->b;
}

#if 0

static int
string_empty (s)
     string *s;
{
  return (s->b == s->p);
}

#endif

static void
string_append (p, s)
     string *p;
     const char *s;
{
  int n;
  if (s == NULL || *s == '\0')
    return;
  n = strlen (s);
  string_need (p, n);
  memcpy (p->p, s, n);
  p->p += n;
}

static void
string_appends (p, s)
     string *p, *s;
{
  int n;

  if (s->b != s->p)
    {
      n = s->p - s->b;
      string_need (p, n);
      memcpy (p->p, s->b, n);
      p->p += n;
    }
}

static void
string_appendn (p, s, n)
     string *p;
     const char *s;
     int n;
{
  if (n != 0)
    {
      string_need (p, n);
      memcpy (p->p, s, n);
      p->p += n;
    }
}

static void
string_prepend (p, s)
     string *p;
     const char *s;
{
  if (s != NULL && *s != '\0')
    {
      string_prependn (p, s, strlen (s));
    }
}

static void
string_prepends (p, s)
     string *p, *s;
{
  if (s->b != s->p)
    {
      string_prependn (p, s->b, s->p - s->b);
    }
}

static void
string_prependn (p, s, n)
     string *p;
     const char *s;
     int n;
{
  char *q;

  if (n != 0)
    {
      string_need (p, n);
      for (q = p->p - 1; q >= p->b; q--)
	{
	  q[n] = q[0];
	}
      memcpy (p->b, s, n);
      p->p += n;
    }
}
/***********************************************************************/
/*                                                                     */
/*  End of Gnu demangle code from cygnus.com                           */
/*                                                                     */
/***********************************************************************/

/*
**   Entry point to use the gnu demangler to
**   demangle type encodings as used in cast operators.
**    returns a char* which must be freed.
*/
static  char* demangle_type( mangled)
     const char **mangled;
{
  string decl;
  int success = 0;
  struct work_stuff work[1];
  char *result = NULL;

  memset ((char *) work, 0, sizeof (work));
  work -> options = DMGL_ANSI;
  string_init (&decl);
  success = do_type(work, mangled, &decl);
  result = mop_up (work, &decl, success);
  return result;
}
