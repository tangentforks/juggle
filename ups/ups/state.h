/* state.h - public header file for state.c */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)state.h	1.10 09 Apr 1995 (UKC) */

typedef enum {
	TM_START, TM_NEXT, TM_STEP, TM_CONT, TM_STOP, TM_ATTACH, TM_DETACH,
	TM_KILL, TM_NTAGS
} target_menu_index_t;

typedef struct {
	struct {
		int md;
		int wn;
	} tm_mdtab[TM_NTAGS];
	int tm_current_md;
} target_menu_info_t;

void set_target_menu_info PROTO((target_menu_info_t *tm));
target_menu_info_t *get_target_menu_info PROTO((void));

void set_message_wn PROTO((int wn));
int get_message_wn PROTO((void));

#ifdef TARGET_H_INCLUDED
target_t *get_current_target PROTO((void));
void set_current_target PROTO((target_t *xp));
#endif

#ifdef SRCWIN_H_INCLUDED
Srcwin *get_current_srcwin PROTO((void));

void set_current_outwin PROTO((Outwin *ow));
Outwin *get_current_outwin PROTO((void));

void  set_display_area_overlay PROTO((Outwin *dw));
Outwin *get_display_area_overlay PROTO((void));
#endif

void set_current_srcwin_menu PROTO((int md));
int get_current_srcwin_menu PROTO((void));

#ifdef REG_H_INCLUDED
void set_current_srcwin_region PROTO((Region *region));
Region *get_current_srcwin_region PROTO((void));

void set_dynamic_menu_region PROTO((Region *region));
Region *get_dynamic_menu_region PROTO((void));

void set_display_area_region PROTO((Region *region));
Region *get_display_area_region PROTO((void));

void set_typing_line_region PROTO((Region *region));
Region *get_typing_line_region PROTO((void));
void set_extended_typing_line_region PROTO((Region *region));
Region *get_extended_typing_line_region PROTO((void));
#endif

#ifdef CC_H_INCLUDED
void set_ccstate PROTO((ccstate_t *cs));
ccstate_t *get_ccstate PROTO((void));
#endif

int demangling_enabled PROTO((int set, int reset));

