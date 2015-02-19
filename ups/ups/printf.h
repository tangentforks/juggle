/* printf.h - header file for printf.c */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)printf.h	1.4 12/22/93 (UKC) */

ci_exec_result_t ups_printf PROTO((target_t *xp, machine_t *machine,
						taddr_t *args, int nargs));
