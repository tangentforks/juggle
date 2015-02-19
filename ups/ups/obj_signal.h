/* obj_signal.h - header file for obj_signal.c */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)obj_signal.h	1.12 09 Apr 1995 (UKC) */

int accept_signal PROTO((int sig));
bool sig_causes_refresh PROTO((int sig));
bool sig_stops_target PROTO((int sig));
bool sig_is_fatal PROTO((int sig));
bool sig_kills_target_by_default PROTO((int sig));

void set_signal_attrs PROTO((int sig, bool ignore, bool redraw, bool stop));
int handle_signal_command PROTO((const char *, char **args, int nargs, bool));
int save_signal_state_to_file PROTO((FILE *));

#ifdef OBJ_H_INCLUDED
void add_signals_header PROTO((objid_t par));
void do_sgh PROTO((objid_t obj, int command, char *arg));
void free_sig PROTO((objid_t obj));
char *sig_format_obj PROTO((objid_t code));
void do_sig PROTO((objid_t obj, int command, char *arg));
void sig_getsize PROTO((objid_t obj, objid_t unused_par, sz_t *sz));
const char *sig_getobjname PROTO((objid_t obj));
void sig_getcolor PROTO((objid_t obj, int wn, long *p_fg, long *p_bg));

extern const char Sghead_format[];
extern const char Sig_format[];
#endif
