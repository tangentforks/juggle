/* obj_env.h - header file for obj_env.c */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)obj_env.h	1.7 09 Apr 1995 (UKC) */

extern struct Edit_history* env_history;
const char **get_environment PROTO((void));

#ifdef OBJ_H_INCLUDED
const char *env_getobjname PROTO((objid_t obj));
void add_env_header PROTO((objid_t par));
char *env_format_obj PROTO((objid_t code));
void do_envhead PROTO((objid_t obj, int command, char *arg));
void do_env PROTO((objid_t obj, int command, char *arg));
void free_env PROTO((objid_t obj));
void env_getsize PROTO((objid_t obj, objid_t unused_par, sz_t *sz));
void env_getcolor PROTO((objid_t obj, int wn, long *p_fg, long *p_bg));

extern const char Envhead_format[];
extern const char Env_format[];

#ifdef OBJTYPES_H_INCLUDED
extern fdef_t Env_fdefs[];
extern fnamemap_t Env_fnamemap[];
#endif

#endif
