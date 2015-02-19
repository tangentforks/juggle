/* config.h - public header file for config.c */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)config.h	1.2 09 Sep 1994 (UKC) */

int save_state PROTO((const char *state_dir, const char *state_path,
		      bool want_save_sigs));

void make_config_paths PROTO((const char *state_dir, const char *basepath,
			      const char **p_state_path,
			      const char **p_user_path));

void load_config PROTO((const char *state_path, const char *user_path,
			bool *p_want_auto_start));

int read_config_file PROTO((const char *path, bool from_statefile,
			    bool must_exist, bool breakpoints_only,
			    bool ignore_breakpoints, bool *p_want_auto_start));

void load_state_file PROTO((void));

void save_state_file PROTO((void));
