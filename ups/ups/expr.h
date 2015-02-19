/* expr.h - header file for expr.c */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)expr.h	1.7 04 Jun 1995 (UKC) */

bool get_varname PROTO((language_t language, const char *text, const char *pos,
			size_t *p_start, size_t *p_end));

func_t *lnum_to_func PROTO((fil_t *fil, int lnum));

#ifdef OBJ_H_INCLUDED
int display_local PROTO((objid_t par, func_t *f, int lnum, const char *name,
			 bool restoring, objid_t *p_var_obj));

bool show_local_expr PROTO((fil_t *fil, int lnum, const char *text));
#endif

#ifdef SRCWIN_H_INCLUDED
void show_var_from_typing_line PROTO((Srcwin *sw, const char *name));
int show_var PROTO((Srcwin *sw, fil_t *fil, int lnum, const char *wholename,
		     errf_ofunc_t out_f));

#ifdef ST_H_INCLUDED
bool show_global PROTO((Srcwin *sw, fil_t *srcfil, func_t *srcfunc,
			common_block_t *srccblock,
			const char *name, bool want_errmesg,
			bool from_typing_line, bool restoring,
			objid_t *p_var_obj, bool undef_check));
void show_given_global PROTO((fil_t *fil, var_t *v));
#endif

#endif

bool show_static_member PROTO((type_t* type,var_t* v));
