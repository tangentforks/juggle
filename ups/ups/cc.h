/* cc.h - header file for cc.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)cc.h	1.1 22/12/93 (UKC) */

#define CC_H_INCLUDED

typedef struct ccstate_s ccstate_t;

ccstate_t *cc_create_ccstate PROTO((const char *extra_flags,
				    unsigned compile_flags));
void cc_free_ccstate PROTO((ccstate_t *cs));
const char *cc_checkarg PROTO((ccstate_t *cs, char **argv));
bool cc_handle_arg PROTO((ccstate_t *cs, char ***p_argv));
linkinfo_t *cc_parse_and_compile PROTO((ccstate_t *cs, const char *srcpath,
					parse_id_t *p_parse_id,
					ci_checkarg_proc_t checkarg_proc));
void cc_get_libinfo PROTO((size_t *p_nlibfuncs, size_t *p_nlibvars));
bool cc_report_error PROTO((lexinfo_t *lx, const char *mesg));
ci_nametype_t cc_getaddr PROTO((const char *name, taddr_t *p_addr));

const char *cc_get_usage PROTO((ccstate_t *cs));
bool cc_get_syminfo_flag PROTO((ccstate_t *cs));
