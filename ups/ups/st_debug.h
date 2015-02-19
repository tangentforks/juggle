/* st_debug.h - header file for st_debug.c */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)st_debug.h	1.1 04 Jun 1995 (UKC) */

void debug_load_symbols PROTO((target_t *xp, const char *name));
void debug_dump_symbols PROTO((target_t *xp, const char *name));
