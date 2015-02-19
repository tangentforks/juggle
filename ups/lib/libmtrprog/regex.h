/* regex.h - prototypes for Ozan Yigit's regex functions in regex.c */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)regex.h	1.3 17 Apr 1994 (UKC) */

const char *yre_comp PROTO((const char *pat));
int yre_exec PROTO((const char *lp));
int e_re_exec PROTO((const char *lp, int offset, int *p_start, int *p_end));

void yre_fail PROTO((const char *msg, int op));
