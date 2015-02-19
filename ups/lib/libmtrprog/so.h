/* so.h - header file for the so file reading module */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)so.h	1.11 22/12/93 (UKC) */

#ifndef SO_H_INCLUDED
#define SO_H_INCLUDED

typedef struct so_s so_t;

typedef struct {
	time_t si_mtime;
	size_t si_size;
} so_info_t;

/*  A type for the line callback function passed to so_open().
 */
typedef int (*so_line_callback_t)PROTO((so_t *so, size_t nlines, off_t pos));

typedef long (*so_input_func_t)PROTO((char *arg,
				      off_t offset, void *buf, size_t nbytes));
typedef void (*so_close_func_t)PROTO((char *arg));
typedef int (*so_info_func_t)PROTO((char *arg, so_info_t *si));

so_t *so_open_file PROTO((const char *name, so_line_callback_t line_callback));
so_t *so_open_via_func PROTO((const char *name,
				so_input_func_t input_func,
				so_close_func_t close_func,
				so_info_func_t get_info_func,
				char *arg,
				so_line_callback_t line_callback));
			   
void so_close PROTO((so_t *so));
size_t so_get_size PROTO((so_t *so));
const char *so_get_name PROTO((so_t *so));
int so_get_max_linelen PROTO((so_t *so));
size_t so_get_nlines PROTO((so_t *so));
void so_read_more PROTO((so_t *so, bool reread));
bool so_has_changed PROTO((so_t *so, int *p_reread));
char *so_getline PROTO((so_t *so, int lnum));
char *so_peekline PROTO((so_t *so, int lnum));
time_t so_mod_time PROTO((so_t *so));
int so_set_default_tabwidth PROTO((int tabwidth));
int so_set_tabwidth PROTO((so_t *so, int tabwidth));
#endif /* !SO_H_INCLUDED */
