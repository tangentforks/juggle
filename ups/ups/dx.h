/* dx.h - prototypes for routines common to ao_* and xc_* target types */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)dx.h	1.1 16 Apr 1994 (UKC) */

/*  These routines are an implementation of the high level process control
 *  routines using low level routines provided by both the C interpreter
 *  and the native a.out file back ends.
 */

/*  Process control
 */
stopres_t dx_start PROTO((target_t *xp));
stopres_t dx_step PROTO((target_t *xp));
stopres_t dx_next PROTO((target_t *xp));
stopres_t dx_cont PROTO((target_t *xp));

/*  Breakpoints.
 */
breakpoint_t *dx_add_breakpoint PROTO((target_t *xp, taddr_t addr));
int dx_remove_breakpoint PROTO((target_t *xp, breakpoint_t *bp));
int dx_enable_breakpoint PROTO((target_t *xp, breakpoint_t *bp));
int dx_disable_breakpoint PROTO((target_t *xp, breakpoint_t *bp));
breakpoint_t *dx_addr_to_breakpoint PROTO((target_t *xp, taddr_t addr));
taddr_t dx_get_breakpoint_addr PROTO((target_t *xp, breakpoint_t *bp));

