/* obj_buildf.h - header file for obj_buildf.c */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)obj_buildf.h	1.9 12/22/93 (UKC) */

void do_formats PROTO((bool have_window));
void close_target_display PROTO((void));
void update_variable_values PROTO((void));

#ifdef TARGET_H_INCLUDED
void initialise_display_area PROTO((target_t *xp, const char *args, bool use_full_path));
objid_t rebuild_display PROTO((target_t *xp));
#endif
