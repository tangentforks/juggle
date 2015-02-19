/* st_debug.c - symbol table debugging routines */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ups_st_debug_c_sccsid[] = "@(#)st_debug.c	1.1 04 Jun 1995 (UKC)";

#include <mtrprog/ifdefs.h>

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include <local/ukcprog.h>
#include <mtrprog/utils.h>

#include "ups.h"
#include "symtab.h"
#include "target.h"
#include "st.h"
#include "st_debug.h"
#include "va.h"
#include "util.h"

static int load_func_info PROTO((func_t *f));
static bool get_file_or_func PROTO((const char *name, fil_t **p_fil, 
                                    func_t **p_f));
static var_t *reverse_varlist PROTO((var_t *varlist));
static enum_member_t *reverse_enumlist PROTO((enum_member_t *enumlist));
static aggr_or_enum_def_t *reverse_aelist PROTO((aggr_or_enum_def_t *aelist));
static typedef_t *reverse_tdlist PROTO((typedef_t *tdlist));
static void dump_varlist PROTO((FILE *fp, int level, var_t *varlist));
static bool dump_aelist PROTO((FILE *fp, int level, language_t language, 
                               aggr_or_enum_def_t *aelist));
static void dump_tdlist PROTO((FILE *fp, int level, language_t language, 
                               typedef_t *tdlist));
static bool dump_aggr PROTO((FILE *fp, int level, language_t language, 
                             aggr_or_enum_def_t *ae));
static bool dump_file_syms PROTO((FILE *fp, fil_t *fil));
static bool dump_block PROTO((FILE *fp, int level, language_t language, 
                              block_t *parbl, funclist_t *funclist));
static bool dump_func_syms PROTO((FILE *fp, int level, func_t *f));
static bool dump_all_syms PROTO((target_t *xp, FILE *fp));
static const char *get_fil_name PROTO((fil_t *fil));

enum { ISPACES = 4 };

static int
load_func_info(f)
func_t *f;
{
	taddr_t junk_addr;
	
	if (get_min_bpt_addr(f, &junk_addr, FALSE) != 0)
		return -1;
	
	st_get_fu_lnos(f);
	st_get_fu_blocks(f);

	return 0;
}

static bool
get_file_or_func(name, p_fil, p_f)
const char *name;
fil_t **p_fil;
func_t **p_f;
{
	if (*name == '\0') {
		*p_fil = NULL;
		*p_f = NULL;
	}
	else if (strchr(name, '.') != NULL && strchr(name, ':') == NULL) {
		fil_t *fil;
		
		if ((fil = name_to_fil(name)) == NULL) {
			errf("Unknown source file name %s", name);
			return FALSE;
		}

		*p_fil = fil;
		*p_f = NULL;
	}
	else {
		func_t *f, *f1;

		if (find_func_by_name(name, &f, &f1) != 0)
			return FALSE;
		
		*p_fil = NULL;
		*p_f = f;
	}

	return TRUE;
}

static var_t *
reverse_varlist(varlist)
var_t *varlist;
{
	var_t *v, *next, *newlist;

	newlist = NULL;
	
	for (v = varlist; v != NULL; v = next) {
		next = v->va_next;
		v->va_next = newlist;
		newlist = v;
	}
	
	return newlist;
}

static enum_member_t *
reverse_enumlist(enumlist)
enum_member_t *enumlist;
{
	enum_member_t *em, *next, *newlist;

	newlist = NULL;
	
	for (em = enumlist; em != NULL; em = next) {
		next = em->em_next;
		em->em_next = newlist;
		newlist = em;
	}
	
	return newlist;
}

static aggr_or_enum_def_t *
reverse_aelist(aelist)
aggr_or_enum_def_t *aelist;
{
	aggr_or_enum_def_t *ae, *next, *newlist;

	newlist = NULL;
	
	for (ae = aelist; ae != NULL; ae = next) {
		next = ae->ae_next;
		ae->ae_next = newlist;
		newlist = ae;
	}
	
	return newlist;
}

static typedef_t *
reverse_tdlist(tdlist)
typedef_t *tdlist;
{
	typedef_t *td, *next, *newlist;

	newlist = NULL;
	
	for (td = tdlist; td != NULL; td = next) {
		next = td->td_next;
		td->td_next = newlist;
		newlist = td;
	}
	
	return newlist;
}

static void
dump_varlist(fp, level, varlist)
FILE *fp;
int level;
var_t *varlist;
{
	var_t *v;

	varlist = reverse_varlist(varlist);
	
	for (v = varlist; v != NULL; v = v->va_next) {
		fprintf(fp, "%*s%s;\n", level * ISPACES, "",
			type_to_decl(v->va_name, v->va_type, v->va_class,
				     v->va_language, TRUE));
	}

	reverse_varlist(varlist);
}

static bool
dump_aelist(fp, level, language, aelist)
FILE *fp;
int level;
language_t language;
aggr_or_enum_def_t *aelist;
{
	aggr_or_enum_def_t *ae;
	bool ok;

	ok = TRUE;

	aelist = reverse_aelist(aelist);
	
	for (ae = aelist; ae != NULL && ok; ae = ae->ae_next) {
		if (ae->ae_type != NULL)
			ok = dump_aggr(fp, level, language, ae);
		else
			ok = dump_aelist(fp, level, language, ae->ae_sublist);
	}

	reverse_aelist(aelist);

	return ok;
}

static void
dump_tdlist(fp, level, language, tdlist)
FILE *fp;
int level;
language_t language;
typedef_t *tdlist;
{
	typedef_t *td;

	tdlist = reverse_tdlist(tdlist);
	
	for (td = tdlist; td != NULL; td = td->td_next) {
		if (td->td_type != NULL) {
			fprintf(fp, "%*stypedef %s;\n", level * ISPACES, "",
				type_to_decl(td->td_name, td->td_type,
					     CL_TYPEDEF, language, FALSE));
		}
		else {
			dump_tdlist(fp, level, language, td->td_sublist);
		}
	}

	reverse_tdlist(tdlist);
}

static bool
dump_aggr(fp, level, language, ae)
FILE *fp;
int level;
language_t language;
aggr_or_enum_def_t *ae;
{
	fprintf(fp, "%*s%s", level * ISPACES, "",
		type_to_decl("", ae->ae_type, CL_AUTO, language, FALSE));

	if (ae->ae_is_complete == AE_COMPLETE) {
		typecode_t typecode;

		fputs("{\n", fp);
		++level;

		typecode = ae->ae_type->ty_code;
		if (typecode == TY_ENUM || typecode == TY_U_ENUM) {
			enum_member_t *em, *members;

			members = reverse_enumlist(ae->ae_enum_members);
		
			for (em = members; em != NULL; em = em->em_next) {
				fprintf(fp, "%*s %s = %ld,\n",
					level * ISPACES, "",
					em->em_name, em->em_val);
			}

			reverse_enumlist(members);
		}
		else {
			dump_varlist(fp, level, ae->ae_aggr_members);
		}

		--level;
		fprintf(fp, "%*s}", level * ISPACES, "");
	}

	fputs(";\n\n", fp);
	
	return !ferror(fp);
}

static const char *
get_fil_name(fil)
fil_t *fil;
{
	static char *last = NULL;
	const char *name;
	
	if (fil == NULL)
		return "";
	name = fil->fi_name;

	if (*name == '/' || fil->fi_path_hint == NULL)
		return name;

	if (last != NULL)
		free(last);

	last = strf("%s%s", fil->fi_path_hint, name);

	return last;
}

static bool
dump_file_syms(fp, fil)
FILE *fp;
fil_t *fil;
{
	block_t *bl;
	
	/*  Ensure types and vars are loaded.
	 */
	st_get_fi_vars(fil);
	bl = fil->fi_block;
	
	fprintf(fp, "%s ", get_fil_name(fil));

	if (bl->bl_next != NULL)
		panic("fil next bl botch");
	
	if (!dump_block(fp, 0, fil->fi_language, bl, fil->fi_funclist))
		return FALSE;

	return fflush(fp) != EOF;
}

static bool
dump_block(fp, level, language, parbl, funclist)
FILE *fp;
int level;
language_t language;
block_t *parbl;
funclist_t *funclist;
{
	block_t *bl;
	funclist_t *fl;
	
	fprintf(fp, "%*s{\n", level * ISPACES, "");
	++level;

	if (parbl->bl_aggr_or_enum_defs != NULL)
		fputc('\n', fp);
	if (!dump_aelist(fp, level, language, parbl->bl_aggr_or_enum_defs))
		return FALSE;

	dump_tdlist(fp, level, language, parbl->bl_typedefs);
	if (parbl->bl_typedefs != NULL)
		fputc('\n', fp);
	
	dump_varlist(fp, level, parbl->bl_vars);
	if (parbl->bl_vars != NULL)
		fputc('\n', fp);
	
	for (bl = parbl->bl_blocks; bl != NULL; bl = bl->bl_next) {
		if (bl->bl_aggr_or_enum_defs != NULL || bl->bl_vars != NULL ||
		    bl->bl_typedefs != NULL || bl->bl_blocks != NULL) {
			if (!dump_block(fp, level, language, bl,
					(funclist_t *)NULL)) {
				return FALSE;
			}
		}
	}

	for (fl = funclist; fl != NULL; fl = fl->fl_next) {
		if (!dump_func_syms(fp, level, fl->fl_func))
			return FALSE;
	}
	
	--level;
	fprintf(fp, "%*s}\n\n", level * ISPACES, "");
	
	return !ferror(fp);
}

static bool
dump_func_syms(fp, level, f)
FILE *fp;
int level;
func_t *f;
{
	block_t *bl;
	
	bl = FU_BLOCKS(f);

	if (bl != NULL && bl->bl_next != NULL)
		panic("func next bl botch");

	fprintf(fp, "%*s", level * ISPACES, "");
	
	if (level == 0)
		fprintf(fp, "%s:", get_fil_name(f->fu_fil));
	
	fprintf(fp, "%s%s()",
		(f->fu_flags & FU_STATIC) ? "static " : "",
		f->fu_demangled_name);

	if (bl == NULL) {
		fputs("\n\n", fp);
		return TRUE;
	}

	fputc(' ', fp);
	return dump_block(fp, level, f->fu_language, bl, (funclist_t *)NULL);
}

static bool
dump_all_syms(xp, fp)
target_t *xp;
FILE *fp;
{
	int symtab_num, nsymtabs;
	symtab_t *st;
	bool ok;

	st = NULL;
	nsymtabs = 0;
	while (xp_next_symtab(xp, st, TRUE, &st))
		++nsymtabs;

	ok = TRUE;
	symtab_num = 1;
	
	st = NULL;
	while (ok && xp_next_symtab(xp, st, TRUE, &st)) {
		int counter, nfiles;
		fil_t *fil;
		
		nfiles = 0;
		for (fil = st->st_sfiles; fil != NULL; fil = fil->fi_next)
			++nfiles;

		counter = 1;
		for (fil = st->st_sfiles; fil != NULL; fil = fil->fi_next) {
			errf("\bSymtab %d of %d: File %d of %d: %s",
			     symtab_num, nsymtabs,
			     counter++, nfiles, fil->fi_name);

			if (!dump_file_syms(fp, fil)) {
				ok = FALSE;
				break;
			}
		}

		++symtab_num;
	}

	return ok;
}

void
debug_dump_symbols(xp, name)
target_t *xp;
const char *name;
{
	static const char what[] = "output file";
	fil_t *fil;
	func_t *f;
	FILE *fp;
	const char *opath;
	bool ok, overwrite;
	
	if (!get_debug_output_path(name, (const char *)NULL,
				   &name, &opath, &overwrite)) {
		return;
	}
 
	if (!get_file_or_func(name, &fil, &f))
		return;

	if (!fopen_new_file(what, opath, overwrite, &fp))
		return;
	
	if (fil != NULL) {
		ok = dump_file_syms(fp, fil);
	}
	else if (f != NULL) {
		ok = dump_func_syms(fp, 0, f);
	}
	else {
		ok = dump_all_syms(xp, fp);
	}

	fclose_new_file(what, name, ok, fp);
}

/*  Load all symbol table information.  This is used for debugging.
 */
void
debug_load_symbols(xp, name)
target_t *xp;
const char *name;
{
	symtab_t *st;
	fil_t *fil;
	func_t *f;
	int symtab_num, nsymtabs;

	if (!get_file_or_func(name, &fil, &f))
		return;

	if (fil != NULL) {
		errf("\bLoading symbols of file %s", fil->fi_name);
		st_get_fi_vars(fil);
		errf("\b");
		return;
	}

	if (f != NULL) {
		errf("\bLoading symbols of function %s", f->fu_demangled_name);
		load_func_info(f);
		errf("\b");
		return;
	}

	st = NULL;
	nsymtabs = 0;
	while (xp_next_symtab(xp, st, TRUE, &st))
		++nsymtabs;
	
	st = NULL;
	symtab_num = 1;
	while (xp_next_symtab(xp, st, TRUE, &st)) {
		int counter, nfuncs, nfiles;
		
		nfuncs = 0;
		for (f = st->st_funclist; f != NULL; f = f->fu_next)
			++nfuncs;

		counter = 1;
		for (f = st->st_funclist; f != NULL; f = f->fu_next) {
			errf("\bSymtab %d of %d: Func %d of %d: %s",
			     symtab_num, nsymtabs,
			     counter++, nfuncs, f->fu_demangled_name);
			
			load_func_info(f);
		}
		
		nfiles = 0;
		for (fil = st->st_sfiles; fil != NULL; fil = fil->fi_next)
			++nfiles;

		counter = 1;
		for (fil = st->st_sfiles; fil != NULL; fil = fil->fi_next) {
			errf("\bSymtab %d of %d: File %d of %d: %s",
			     symtab_num, nsymtabs,
			     counter++, nfiles, fil->fi_name);
			
			st_get_fi_vars(fil);
		}

		++symtab_num;
	}

	errf("\bEntire symbol table loaded");
}

