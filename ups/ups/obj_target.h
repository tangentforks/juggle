/* obj_target.h - public header file for obj_target.c */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)obj_target.h	1.11 09 Apr 1995 (UKC) */

#define OBJ_TARGET_H_INCLUDED

extern struct Edit_history* cmd_history;
int setup_shellcmd PROTO((bool want_execfile, char **p_shell_line));
int setup_args PROTO((const char ***p_argv, long *p_rdlist));

#ifdef OBJ_H_INCLUDED
void add_target_object PROTO((objid_t par, const char *textpath,
			      const char *minus_a_cmdline,
			      bool use_full_path));
char *target_format_obj PROTO((objid_t code));
void do_target PROTO((objid_t par, int command, char *arg));
void free_com PROTO((objid_t obj));
#endif

extern const char Com_format[];

#ifdef OBJTYPES_H_INCLUDED
extern fdef_t Com_fdefs[];
extern fnamemap_t Com_fnamemap[];
#endif
