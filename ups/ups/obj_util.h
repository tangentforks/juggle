/* obj_util.h - public header file for obj_util.c */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)obj_util.h	1.4 09 Apr 1995 (UKC) */

typedef struct Field_edit_info Field_edit_info;

typedef void (*Field_edit_move_point_func)PROTO((Edit_display *display,
						 objid_t obj, size_t point));

void edit_field_obj PROTO((objid_t obj, int fnum));

Edit_display *field_edit_start PROTO((struct drawst *dr,
				      const char *what,
				      char *textcopy));

Edit_display* field_edit_get_display PROTO(( char* handle));

void field_edit_set_move_point_func PROTO((Field_edit_info *fe,
					   Field_edit_move_point_func func));

bool field_edit_finish PROTO((char *handle, bool force));

objid_t field_edit_get_object PROTO((Field_edit_info *fe));

void field_edit_update_orig_text PROTO((Field_edit_info *fe, const char *text));

#ifdef REG_H_INCLUDED
void field_edit_handle_key_event PROTO((Region *region,
					char *handle, event_t *ev));
#endif

void field_edit_redraw_display PROTO((char *handle));
objid_t find_or_add_object PROTO((objid_t par, objid_t wanted, 
                                  void (*add_object)PROTO((objid_t wobj))));
void field_edit_handle_insert_text PROTO((char *handle, char *text));
