/* util.h - public header file for util.c */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)util.h	1.4 04 Jun 1995 (UKC) */

bool parse_line PROTO((const char *line, char ***p_words, int *p_nwords));

#ifdef EOF
void put_quoted_string PROTO((FILE *fp, const char *str));
void dump_text PROTO((const char *text, FILE *fp));
FILE *fopen_with_twiddle PROTO((const char *path, const char *mode));
#endif

int open_with_twiddle PROTO((const char *path, int mode));
bool same_string PROTO((const char *s1, const char *s2));

bool get_debug_output_path PROTO((const char *cmdline, const char *defpath,
				  const char **p_cmdline, const char **p_path,
				  bool *p_overwrite));
