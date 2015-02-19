/* st_module.c - generic support for modules (so far used with f90 only) */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ups_st_module_c_sccsid[] = "@(#)st_module.c	1.1 21 Oct 1994 (UKC)";

#include <string.h>

#include <local/ukcprog.h>

#include "ups.h"
#include "symtab.h"
#include "st.h"

struct Module {
	const char *name;
	funclist_t *funclist;
	Module *next;
};

static Module *name_to_module PROTO((symtab_t *st, const char *modname));
static Module *add_module PROTO((symtab_t *st, const char *name));

static Module *
name_to_module(st, modname)
symtab_t *st;
const char *modname;
{
	Module *m;
	
	for (m = st->st_modules; m != NULL; m = m->next)
		if (strcmp(m->name, modname) == 0)
			return m;

	return NULL;
}

static Module *
add_module(st, name)
symtab_t *st;
const char *name;
{
	Module *m;

	m = (Module *)alloc(st->st_apool, sizeof(Module));
	m->name = alloc_strdup(st->st_apool, name);
	m->funclist = NULL;
	m->next = st->st_modules;
	st->st_modules = m;

	return m;
}

void
add_module_function(st, modname, f)
symtab_t *st;
const char *modname;
func_t *f;
{
	Module *m;
	funclist_t *fl;
	
	if ((m = name_to_module(st, modname)) == NULL)
		m = add_module(st, modname);

	fl = (funclist_t *)alloc(st->st_apool, sizeof(funclist_t));
	fl->fl_func = f;
	fl->fl_next = m->funclist;
	m->funclist = fl;
}

const char *
get_module_name(m)
Module *m;
{
	return m->name;
}

funclist_t *
get_module_funclist(m)
Module *m;
{
	return m->funclist;
}

Module *
get_next_module(m)
Module *m;
{
	return m->next;
}

void
iterate_over_modules(mlist, func)
Module *mlist;
void (*func)PROTO((Module *module));
{
	Module *m;

	for (m = mlist; m != NULL; m = m->next)
		(*func)(m);
}
