/* obj_target.c - target argv and envp munging */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ups_obj_target_c_sccsid[] = "@(#)obj_target.c	1.28 09 Apr 1995 (UKC)";

#include <mtrprog/ifdefs.h>
#include "ao_ifdefs.h"

#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <local/wn.h>
#include <local/obj/obj.h>
#include <local/ukcprog.h>
#include <local/arg.h>
#include <local/edit/edit.h>

#include "ups.h"
#include "symtab.h"
#include "va.h"
#include "objtypes.h"
#include "target.h"
#include "obj_target.h"
#include "obj_env.h"
#include "exec.h"
#include "ui.h"
#include "obj_stack.h"
#include "obj_util.h"
#include "obj_misc.h"
#include "state.h"
#include "tdr.h"
#include "menudata.h"
#include "config.h"

 /* RGA linux merge */
#ifdef OS_LINUX
#define NCARGS ARG_MAX
#endif

static void args_edit PROTO((struct drawst fdets));
static bool args_quitfunc PROTO((objid_t obj, char *new_text,
				 const char **p_display_string));

/* RGA use elastic format ... */
/*const char Com_format[] = "Target %[-]40ca\n        %[-]120ce\n";*/
const char Com_format[] = "Target %[-]40ca\n        %[-]:120ce\n";

fdef_t Com_fdefs[] = {
	{ 'e', e_draw, args_edit, NULL	},
	{ 'a', e_draw, no_edit, NULL	},
	{ '\0', NULL, NULL, NULL	},
};

static objid_t Com_objcode = NULL;

#define FN_COM_EFILE	0
#define FN_COM_ARGS	1
#define FN_COM_LAST	2

Edit_history* cmd_history = NULL;
fnamemap_t Com_fnamemap[] = {
	{ FN_COM_ARGS,	"arguments",	TRUE,	args_quitfunc, &cmd_history	},
	{ 0,		NULL,		FALSE,	NULL		},
};

#define MAX_ARG_LEN	((size_t)500)
#define MAX_EFILE_LEN	((size_t)40)

int
setup_shellcmd(want_execfile, p_shell_line)
bool want_execfile;
char **p_shell_line;
{
	const char *cmdline, *argline;

	if (Com_objcode)
		cmdline = (char *)get_field_value(Com_objcode, FN_COM_ARGS);
	else
		cmdline = "";

	if (want_execfile) {
		argline = cmdline;
	}
	else {
		if ((argline = strchr(cmdline, ' ')) != NULL)
			++argline;
		else
			argline = "";
	}

	return arg_make_shell_line(argline, p_shell_line);
}

int
setup_args(p_argv, p_rdlist)
const char ***p_argv;
long *p_rdlist;
{
	static dvec_t dv = 0;
	const char *cmdline;
	const char **av;
	long len, maxlen;

	if (dv != 0)
		free_dvec_and_strings(dv);

	cmdline = (char *) get_field_value(Com_objcode, FN_COM_ARGS);

	if (arg_lparse(cmdline, &dv, p_rdlist) == -1)
		return -1;
	*p_argv = (const char **)get_dvec_vec(dv);

	/*  Check that the arg list is not too long.
	 */
	len = 0;
	av = *p_argv; 
	while (*av != NULL)
		len += strlen(*av++);

	maxlen = sysconf(_SC_ARG_MAX);
	
	if (len > maxlen) {
		errf("Argument list too long (%ld characters: max is %ld)",
		     len, maxlen);
		return -1;
	}

	return 0;
}

/* ARGSUSED */
static bool
args_quitfunc(obj, new_text, p_display_string)
objid_t obj;
char *new_text;
const char **p_display_string;
{
	change_field(obj, FN_COM_ARGS, (fval_t)new_text);
	return TRUE;
}

static void
args_edit(fdets)
struct drawst fdets;
{
	field_edit_start(&fdets, "command line", (char *)NULL);
}

/*  Create an object for the command and enviroment
 */
void
add_target_object(par, efile, cmdline, use_full_path)
objid_t par;
const char *efile, *cmdline;
bool use_full_path;
{
	char *command_line, *pos, *cptr;
	fval_t fields[FN_COM_LAST + 1];
	int efile_len;

	efile_len = strlen(efile);

	cptr = e_malloc(MAX_EFILE_LEN + 1);
	if (efile_len <= MAX_EFILE_LEN) {
		(void) strcpy(cptr, efile);
	}
	else {
		const char *s;

		s = efile + (efile_len - MAX_EFILE_LEN) + 3; /* 3 for ... */
		while (*s == '/' && *s != '\0')
			++s;
		(void) sprintf(cptr, "...%s", s);
	}
	fields[FN_COM_EFILE] = (fval_t) cptr;

	if ( !use_full_path)
	{
	   /* RCB: Added use_full_path command line arg. to disable this.
	   ** useful when programs need their full path name to locate
	   ** resource files or to let purify monitor them.
	   */
	   if ((pos = strrchr(efile, '/')) != NULL)
		efile = pos + 1;
	   efile_len = strlen(efile);
	}

	command_line = e_malloc(MAX_ARG_LEN + 1);
	command_line[MAX_ARG_LEN] = '\0';

	if (cmdline != NULL) {
		if (strlen(cmdline) > MAX_ARG_LEN - efile_len)
			errf("-a args too long - ignored");
		else
			(void) sprintf(command_line, "%s %s", efile, cmdline);
	}
	else {
		(void) strncpy(command_line, efile, MAX_ARG_LEN);
	}

	fields[FN_COM_ARGS] = (fval_t) command_line;
	fields[FN_COM_LAST] = (fval_t) NULL;

	Com_objcode = (objid_t) Com_format;
	new_object(Com_objcode, OT_COM, par, OBJ_CHILD);
	set_all_fields(Com_objcode, fields, (fval_t)NULL);
}

char *
target_format_obj(code)
objid_t code;
{
	return strf("%s", get_field_value(code, FN_COM_ARGS));
}

/*  Menu function for the target menu (this is the menu that appears
 *  when the target object is selected, not the target control menu).
 */
/* ARGSUSED */
void
do_target(par, command, arg)
objid_t par;
int command;
char *arg;
{
	switch(command) {
	case MR_WRITE_CORE:
		write_target_core(get_current_target());
		break;
	case MR_SAVE_STATE:
		save_state_file();
		break;
	case MR_LOAD_STATE:
		load_state_file();
		if (can_get_target_vars(get_current_target()))
		  restore_file_displays();
		break;
	case MR_RESCAN_INIT_FILE:
		free_library_load_list();
		if (td_init_from())
		{
		  bool eof;
		  int res;
		  
		  res = td_load_loop(&eof);
		  
		  if (res != 0)
		    fprintf(stderr, "Error in init file\n");
		  td_restore_replay_fp();
		}
#ifdef AO_TARGET
#if defined(AO_AOUT_SHLIBS)
		unload_shared_library_symtabs(get_current_target());
		load_shared_library_symtabs(get_current_target(), TRUE);
#endif /* AO_AOUT_SHLIBS */
		rescan_dynamic_solibs(get_current_target());
		if (can_get_target_vars(get_current_target()))
		  refresh_target_with_rescan(get_current_target(), SR_BPT, FALSE);
#endif /* AO_TARGET */
		redo_displayed_source_files();
		break;
	default:
		panic("bad cmd in dt");
	}
}

void
free_com(obj)
objid_t obj;
{
	free((char *)get_field_value(obj, FN_COM_EFILE));
	free((char *)get_field_value(obj, FN_COM_ARGS));
}
