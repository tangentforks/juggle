/* obj_misc.h - public header file for src.c */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)obj_misc.h	1.11 09 Apr 1995 (UKC) */

void add_globals_header PROTO((objid_t par));
int addvars PROTO((objid_t par));
void hide_source_vars PROTO((void));

#ifdef ST_H_INCLUDED
void add_common_block_object_if_necessary PROTO((common_block_t *cblock));
void add_source_file_object_if_necessary PROTO((fil_t *fil,
						bool restore_file_displays));
void add_source_file_object_if_required PROTO((fil_t *fil,
						bool restore_file_displays,
						bool use_src_cmp));
#endif

int show_source_path_assumed PROTO((fil_t *fil, bool show_error));
int show_source_path_used PROTO((fil_t *fil, bool show_error));
int src_cmp PROTO((objid_t obj1, objid_t obj2));
objid_t find_or_add_object PROTO((objid_t par, objid_t wanted,
				  void (*add_object)PROTO((objid_t wobj))));

void do_globals PROTO((objid_t obj, int command, char *arg));
void do_srchead PROTO((objid_t obj, int command, char *arg));
void do_cbhead PROTO((objid_t obj, int command, char *arg));
void do_mhead PROTO((objid_t obj, int command, char *arg));

char *header_format_obj PROTO((objid_t code));

char *file_format_obj PROTO((objid_t code));
int pre_do_file PROTO((int command, char **p_arg));
void do_file PROTO((objid_t obj, int command, char *arg));

const char *cblock_getobjname PROTO((objid_t obj));
void do_cblock PROTO((objid_t obj, int command, char *arg));
char *cblock_format_obj PROTO((objid_t code));

const char *module_getobjname PROTO((objid_t obj));
void do_module PROTO((objid_t obj, int command, char *arg));
char *module_format_obj PROTO((objid_t code));
void module_getsize PROTO((objid_t obj, objid_t pat, struct szst *sz));

const char *module_func_getobjname PROTO((objid_t obj));
void do_module_func PROTO((objid_t obj, int command, char *arg));
char *module_func_format_obj PROTO((objid_t code));
void module_func_getsize PROTO((objid_t obj, objid_t pat, struct szst *sz));

const char *srcfile_getobjname PROTO((objid_t obj));
void srcfile_getsize PROTO((objid_t obj, objid_t pat, struct szst *sz));
void srcfile_getcolor PROTO((objid_t obj, int wn, long *p_fg, long *p_bg));
void func_getcolor PROTO((objid_t obj, int wn, long *p_fg, long *p_bg));

void free_common_block_object PROTO((objid_t obj));

/*  Objcodes for header objects which must be visible in more than one file.
 *  To make a unique objcode, we cast the address of an arbitrary data object.
 *  Here, we use the address of the format string.
 */
extern const char Globals_format[];
#define GLOBALS_OBJCODE	((objid_t)Globals_format)

extern const char Srchead_format[];
#define SRCHEAD_OBJCODE	((objid_t)Srchead_format)

extern const char Cbhead_format[];
#define CBHEAD_OBJCODE	((objid_t)Cbhead_format)

extern const char Fhead_format[];
#define FHEAD_OBJCODE   ((objid_t)Fhead_format)

extern const char Mhead_format[];
#define MHEAD_OBJCODE   ((objid_t)Mhead_format)

extern const char Cblock_format[];
extern const char Module_format[];
extern const char Module_ex_format[];
extern const char Module_func_format[];
extern const char Sfile_format[];
extern const char Sfile_ex_format[];
