/* breakpoint.h - public header file for bp.c */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)breakpoint.h	1.6 16 Apr 1994 (UKC) */

#define BREAKPOINT_H_INCLUDED

/*  The following routines are used only by the dx implementation routines.
 */
int breakpoint_is_installed PROTO((breakpoint_t *bp));
void set_breakpoint_data PROTO((breakpoint_t *breakpoint, long));
long get_breakpoint_data PROTO((breakpoint_t *breakpoint));
int install_breakpoint PROTO((breakpoint_t *bp, target_t *xp));
int uninstall_breakpoint PROTO((breakpoint_t *bp));
int install_all_breakpoints PROTO((target_t *xp));
bool can_install_all_breakpoints PROTO((target_t *xp));
int uninstall_all_breakpoints PROTO((target_t *xp));
breakpoint_t *get_breakpoint_at_addr PROTO((target_t *xp, taddr_t addr));
void mark_breakpoints_as_uninstalled PROTO((target_t *xp));
void set_breakpoint_as_solib_event PROTO((breakpoint_t *bp));
bool breakpoint_is_solib_event PROTO((breakpoint_t *bp));
void install_solib_event_breakpoint PROTO((target_t *xp));

/*  FIX: this routine is called from recalculate_bpt_addrs() in obj_bpt.c
 */
void change_breakpoint_address PROTO((target_t *xp, breakpoint_t *bp,
				      taddr_t addr));

