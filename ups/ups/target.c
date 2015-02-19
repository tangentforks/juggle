/* target.c - generic target functions */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ups_target_c_sccsid[] = "@(#)target.c	1.12 24 May 1995 (UKC)";

#include <mtrprog/ifdefs.h>
#include "ao_ifdefs.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <stdlib.h>
#include <string.h>
#ifdef __STDC__
#include <unistd.h>
#endif

#include <local/ukcprog.h>
#include <mtrprog/utils.h>
#include <mtrprog/alloc.h>
#include <mtrprog/ifdefs.h>
#include <local/wn.h>		/* for cursor_t */

#include "ups.h"
#include "symtab.h"
#include "target.h"
#include "tdr.h"
#include "cursors.h"
#include "ui.h"
#include "state.h"

#ifndef SEEK_SET
#define SEEK_SET 0
#endif

#if 0
static xp_ops_t *Target_drivers[] = {
	&Xc_ops,
	&Cc_ops,
#ifdef AO_TARGET
	&Ao_ops,
#endif
	&Gd_ops,
};
#endif

#if AO_USE_PROCFS
#define ps_stop				procfs_stop
#endif

#if AO_USE_PTRACE
#define ps_stop				ptrace_stop
#endif

ALLOC_NEW_FREE(static,Stack,stk,stk_inner)

int
preinitialise_target_drivers()
{
	int i;
	xp_ops_t **drivers;

	drivers = get_target_drivers();

	for (i = 0; drivers[i] != NULL; ++i) {
		if (drivers[i]->xo_preinitialise != NULL &&
		    (*drivers[i]->xo_preinitialise)() != 0)
			return -1;
	}

	return 0;
}
	
int
initialise_target_drivers(usage_eb, argv)
ebuf_t *usage_eb;
char **argv;
{
	int i;
	xp_ops_t **drivers;

	drivers = get_target_drivers();

	for (i = 0; drivers[i] != NULL; ++i) {
		if (drivers[i]->xo_initialise != NULL &&
		    (*drivers[i]->xo_initialise)(usage_eb, argv) != 0)
			return -1;
	}

	return 0;
}
	    
void
show_target_driver_info(name_only)
bool name_only;
{
	int i;
	xp_ops_t **drivers;

	drivers = get_target_drivers();
	
	for (i = 0; drivers[i] != NULL; ++i)
		(*drivers[i]->xo_show_target_driver_info)(name_only);
}
	    
bool
extract_bool_arg(usage_eb, argv, flag)
ebuf_t *usage_eb;
char **argv;
const char *flag;
{
	bool seen_flag;
	char **iptr, **optr;
	
	optr = argv;
	seen_flag = FALSE;

	for (iptr = argv; *iptr != NULL; ++iptr) {
		if (strcmp(*iptr, flag) == 0)
			seen_flag = TRUE;
		else
			*optr++ = *iptr;
	}
	*optr = NULL;

	ebuf_addstr(usage_eb, "[");
	ebuf_addstr(usage_eb, flag);
	ebuf_addstr(usage_eb, "] ");

	return seen_flag;
}

int
make_target(textpath, corepath, user_gave_core, p_xp, p_cmdline, restore_bpts)
const char *textpath, *corepath;
bool user_gave_core;
target_t **p_xp;
const char **p_cmdline;
bool restore_bpts;
{
	static const char what[] = "object file";
	struct stat stbuf;
	alloc_pool_t *ap;
	target_t *xp;
	text_block_t tbuf;
	int fd, i;
	size_t n_read;
	bool big_endian;
	xp_ops_t **drivers;
	union {
		int intval;
		char charval;
	} u;

	drivers = get_target_drivers();

	if ((fd = open(textpath, 0)) < 0) {
		failmesg("Can't open", what, textpath);
		return -1;
	}

	if (fstat(fd, &stbuf) == 0 && !S_ISREG(stbuf.st_mode)) {
		errf("%s is a %s (expected a regular file)",
					textpath,
					filetype_to_string((int)stbuf.st_mode));
		return -1;
	}

	n_read = read(fd, (char *)&tbuf, sizeof(tbuf));
	if (n_read <= 0) {
		if (n_read == -1)
			failmesg("Error reading", what, textpath);
		else
			errf("Unexpected EOF reading %s %s", what, textpath);
		close(fd);
		return -1;
	}

	if (lseek(fd, SEEK_SET, 0) == -1) {
		failmesg("Can't seek back to the start of", what, textpath);
		close(fd);
		return -1;
	}

	for (i = 0; drivers[i] != NULL; ++i) {
		if ((*drivers[i]->xo_match)(textpath, &tbuf, n_read))
			break;
	}
	
	if (drivers[i] == NULL) {
		errf("%s: File format unrecognised", textpath);
		return -1;
	}
	
	ap = alloc_create_pool();

	xp = (target_t *)alloc(ap, sizeof(target_t));
	xp->xp_apool = ap;
	xp->xp_textpath = textpath;
	xp->xp_mainfunc = NULL;
	xp->xp_initfunc = NULL;
	xp->xp_modtime = stbuf.st_mtime;
	xp->xp_ops = drivers[i];

	/*  These are just default values - xp_init_from_textfile() can
	 *  override them (the gdb back end does this).
	 */
	u.intval = 0;
	u.charval = 'a';
	big_endian = (char)u.intval == 0;

	xp->xp_words_big_endian = big_endian;
	xp->xp_bits_big_endian = big_endian;
	xp->xp_new_dynamic_libs = FALSE;
	xp->xp_new_dynamic_libs_loaded = FALSE;
	xp->xp_hit_solib_event = FALSE;
	xp->xp_restore_bpts = restore_bpts;

	if (xp_init_from_textfile(xp, fd, corepath, user_gave_core,
							    p_cmdline) != 0) {
		alloc_free_pool(ap);
		close(fd);
		return -1;
	}

	*p_xp = xp;
	return 0;
}

void
kill_or_detach_from_target(xp)
target_t *xp;
{
	if (xp_is_attached(xp))
		xp_detach(xp);
	else
		xp_kill(xp);
}

void
write_target_core(xp)
target_t *xp;
{
	char *path;
	char *new_path;

	if (target_process_exists(xp)) {
		if (prompt_for_string("filename", "Write core to file: ", "",
				      &path) == 0) {
		  	new_path = (char *)arg_expand_twiddle(path, (int)'~');
			xp_write_corefile(xp, new_path);
			free(new_path);
			free(path);
		}
	}
	else {
		errf("Target not running");
	}
}

bool
target_process_exists(xp)
target_t *xp;
{
	tstate_t tstate;

	tstate = xp_get_state(xp);
	return tstate == TS_STOPPED || tstate == TS_HALTED ||
	  tstate == TS_RUNNING;
}

bool
can_get_target_vars(xp)
target_t *xp;
{
	return xp_get_state(xp) == TS_CORE || target_process_exists(xp);
}

symtab_t *
xp_main_symtab(xp)
target_t *xp;
{
	symtab_t *st;

	if (!xp_next_symtab(xp, (symtab_t *)NULL, TRUE, &st))
		panic("can't get main symtab");

	return st;
}

func_t *
xp_get_mainfunc(xp)
target_t *xp;
{
	return xp->xp_mainfunc;
}

void
xp_set_mainfunc(xp, f)
target_t *xp;
func_t *f;
{
	xp->xp_mainfunc = f;
}

func_t *
xp_get_initfunc(xp)
target_t *xp;
{
	return xp->xp_initfunc;
}

void
xp_set_initfunc(xp, f)
target_t *xp;
func_t *f;
{
	xp->xp_initfunc = f;
}

/*  Interface to xp_readreg() that aborts on failure.
 */
taddr_t
xp_getreg(xp, regno)
target_t *xp;
int regno;
{
	taddr_t val;

	if (xp_readreg(xp, regno, &val) != 0)
		panic("ao_readreg failed");
	return val;
}

Stack *
make_stk(f, pc, fil, lnum, last)
func_t *f;
taddr_t pc;
fil_t *fil;
int lnum;
Stack *last;
{
	Stack *stk;

	stk = new_stk();

	stk->stk_func = f;
	stk->stk_pc = pc;
	/* fp */
	/* sp */
	/* ap */
	stk->stk_fil = fil;
	stk->stk_lnum = lnum;
	stk->stk_siginfo = NULL;
	stk->stk_user_changed_vars = FALSE;
	stk->stk_bad = FALSE;
	stk->stk_inner = last;
	/* outer */
	stk->stk_data = NULL;

	return stk;
}

func_t *
make_badfunc()
{
	static func_t badfunc;
	
	if (badfunc.fu_flags == 0) {
		badfunc.fu_flags = FU_NOSYM | FU_DONE_LNOS |
				   FU_DONE_BLOCKS | FU_BAD;
		badfunc.fu_name = "<badfunc>";
		badfunc.fu_demangled_name = badfunc.fu_name;
		badfunc.fu_language = LANG_UNKNOWN;

		/*  DUBIOUS: we set this to non-null so ao_* stuff won't
		 *  get the preamble for the functions.  So far, the other
		 *  back ends aren't upset by this, but this may not last.
		 */
		badfunc.fu_predata = (char *)&badfunc;
	}

	return &badfunc;
}
	
void
destroy_stk(stk)
Stack *stk;
{
	if (stk->stk_siginfo != NULL)
		free((char *)stk->stk_siginfo);

	free_stk(stk);
}

/*  TODO: probably want to lose the siginfo struct.  Too much else being
 *        hacked to do it right now.
 */
Siginfo *
make_siginfo(signo, preamble_nbytes)
int signo, preamble_nbytes;
{
	Siginfo *si;

	si = (Siginfo *)e_malloc(sizeof(Siginfo) + preamble_nbytes);
	si->si_signo = signo;
	si->si_fp = 0;
	si->si_predata = (preamble_nbytes > 0) ? (char *)&si[1] : NULL;

	return si;
}

static cursor_t Old_cursor = 0;

void
indicate_target_running()
{
	if (!td_have_window())
		return;

	if (Old_cursor != 0)
		panic("dup call of itr");

	Old_cursor = wn_get_window_cursor(WN_STDWIN);
	set_bm_cursor(WN_STDWIN, CU_WAIT);
	update_target_menu_state
	  (TS_RUNNING, xp_is_attached(get_current_target()));
}

void
indicate_target_stopped(tstate)
tstate_t tstate;
{
	if (!td_have_window())
		return;
	
	if (Old_cursor == 0)
		panic("dup call of its");
	
	wn_define_cursor(WN_STDWIN, Old_cursor);
	update_target_menu_state(tstate, xp_is_attached(get_current_target()));

	Old_cursor = 0;

}

void
target_stop()
{
	ps_stop(get_current_target());
}

static void
null_ofunc(s)
const char *s;
{
}

int
user_wants_non_frame_functions()
{
  static int non_frame_functions = -1;
  char *def;

  if (non_frame_functions == -1)
  {
    non_frame_functions =
      (def = (char *)wn_get_default("NonFrameFunctions")) != NULL &&
	strcmp(def, "on") == 0;
    if (def == NULL)
      non_frame_functions = (rational_products_running() != 0);
  }
  return non_frame_functions;
}


int
attach_to_target(xp, pid_str, first_attach)
target_t *xp;
char *pid_str;
bool first_attach;
{
#ifdef AO_ELF
  const char *textpath,  *args;
  func_t *f, *f1;
  int res;
  bool restore_bpts;

  textpath = xp->xp_textpath;
  args = NULL;
  if (first_attach == FALSE && xp->xp_restore_bpts == FALSE)
    elf_save_symtab_breakpoints(xp, FALSE);
  restore_bpts = xp->xp_restore_bpts;
  alloc_free_pool(xp->xp_apool);
  if (make_target(textpath, pid_str, TRUE, &xp, &args, restore_bpts) == -1)
    return -1;
  set_current_target(xp);

  if ((f = xp_get_mainfunc(xp)) == NULL) {
    res = find_func_by_name("main", &f, &f1);
    if (res != 0 || IS_FORTRAN(f->fu_language)) {
      find_func_by_name("MAIN", &f, &f1);
    }

    xp_set_mainfunc(xp, f);
  }
  if (first_attach == FALSE && xp->xp_restore_bpts == FALSE)
    elf_restore_symtab_breakpoints();
#endif
  return 0;
}

void
rescan_dynamic_solibs(xp)
target_t *xp;
{
#ifdef AO_ELF
    elf_rescan_dynamic_solibs(xp);
#endif
}

