/* ao_stack.h - public header file for ao_stack.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_stack.h	1.1 22/12/93 (UKC) */

Stack *ao_get_stack_trace PROTO((target_t *xp));
taddr_t ao_get_reg_addr PROTO((target_t *xp, Stack *stk, int reg));
const char *ao_get_signal_tag PROTO((target_t *xp, int signo));
