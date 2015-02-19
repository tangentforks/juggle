/* xc_builtins.h - header file for xc_builtins.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)xc_builtins.h	1.1 22/12/93 (UKC) */

libfunc_addr_t *cx_get_libfuncs PROTO((size_t count));
char **cx_get_libvars PROTO((size_t count));
void cx_set_environ PROTO((char **envp));

