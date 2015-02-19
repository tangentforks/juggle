/* obj_bpt.h - public header file for obj_bpt.c */
/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)obj_bpt.h	1.14 24 May 1995 (UKC) */

extern struct Edit_history* bpt_history;

#ifdef TARGET_H_INCLUDED
void recalculate_bpt_addrs PROTO((target_t *xp));
bool execute_bp_code PROTO((breakpoint_t *bp, taddr_t fp, taddr_t ap));
#endif

int save_all_breakpoints_to_file PROTO((const char *path, FILE *fp));
void save_all_breakpoints PROTO((char *handle));

int breakpoint_is_disabled PROTO((long bp_data));

void set_breakpoint_statefile_path PROTO((const char *path));

int handle_add_breakpoint_command PROTO((const char *cmd,
					 char **args, int nargs,
					 bool from_statefile, bool ignore,
					 FILE *fp, int *p_lnum));

int handle_add_code_command PROTO((const char *cmd, char **args, int nargs,
				   bool from_statefile, bool ignore,
				   FILE *fp, int *p_lnum));

void reinitialise_bpt_code_data PROTO((void));
void restore_cached_bpts PROTO((void));
void collapse_files PROTO((void));

#ifdef SYMTAB_H_INCLUDED
void remove_matching_breakpoints PROTO((symtab_t *st, fil_t *fil));
void save_matching_bpts PROTO((symtab_t *st, fil_t *fil, char *handle));
#endif

void remove_all_breakpoints PROTO((void));
void save_all_bpts PROTO((char *handle));


#ifdef OBJ_H_INCLUDED

#ifdef SYMTAB_H_INCLUDED
int bpt_accelerator_action PROTO(( objid_t obj ));	/* RCB */
objid_t add_breakpoint_object PROTO((func_t *f, fil_t *fil, int lnum));
objid_t add_interpreted_code PROTO((fil_t *fil, int lnum, char *text));

/* RCB: New to provide access for typing line shortcut */
int add_breakpoints_for_fname PROTO(( const char* fname, func_t** pfirst ));
#endif

const char *bpt_getobjname PROTO((objid_t code));
char *bpt_format_obj PROTO((objid_t code));

int pre_do_bpt PROTO((int command, char **p_arg));
void do_bpt PROTO((objid_t obj, int command, char *arg));
void post_do_bpt PROTO((int command, char *arg));

void add_breakpoint_header PROTO((objid_t par));
void do_bps PROTO((objid_t obj, int command, char *arg));
void remove_breakpoint_object PROTO((objid_t obj));
void bpt_select PROTO((int wn, objid_t obj, int x, int y,
					int width, int height, int flags));

int change_bd_text PROTO((objid_t obj, const char *text));
int global_bp_enabled PROTO((int set, int reset));
void bpt_getcolor PROTO((objid_t obj, int wn, long *p_fg, long *p_bg));

extern const char Bpt_format[];
extern const char Bphead_format[];

#endif /* OBJ_H_INCLUDED */

#ifdef OBJTYPES_H_INCLUDED
extern fdef_t Bpt_fdefs[];
extern fnamemap_t Bpt_fnamemap[];
#endif

