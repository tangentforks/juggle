/* obj_util.c - miscellaneous low level object related routines */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ups_obj_util_c_sccsid[] = "@(#)obj_util.c	1.4 09 Apr 1995 (UKC)";

#include <stdlib.h>
#include <string.h>

#include <local/ukcprog.h>
#include <local/wn.h>
#include <local/obj/obj.h>
#include <local/obj/o_priv.h>
#include <local/obj/o_mkobj.h>
#include <local/obj/o_lptrs.h>
#include <local/edit/edit.h>
#include <local/edit/win.h>

#include "reg.h"
#include "objtypes.h"
#include "obj_util.h"
#include "ui.h"
#include "state.h"
#include "tdr.h"

struct Field_edit_info {
	objid_t obj;
	int fnum;
	const char *what;
	bool null_string_ok;
	char *textcopy;
	const char *text;
	int wn;
	bool cancel;
	Edit_display *display;
	Edit_keymap *keymap;
	Field_edit_quitfunc quitfunc;
	Field_edit_move_point_func move_point_func;
};

static bool confirm_field_edit PROTO((Field_edit_info *fe,
				      const char **p_display_string));
static void do_cancel PROTO((Edit_display *display));
static fnamemap_t *get_field_edit_info PROTO((objid_t obj, int fnum));

void
edit_field_obj(obj, fnum) /* RGA added "_obj" to avoid conflict with fed.c */
objid_t obj;
int fnum;
{
	event_t event;

	/*  BUG: fix the lousy field editing interface.
	 */
	if (td_have_window()) {
		event.ev_type = EV_MOUSE_MOVED;
		event.ev_x = 0;
		event.ev_y = 0;
		event.ev_wn = WN_STDWIN;
		wn_pushback_event(&event);
		
		obj_edit_field(obj, fnum, 0, 0);
	}
}

Edit_display *
field_edit_start(dr, what, textcopy)
struct drawst *dr;
const char *what;
char *textcopy;
{
	Field_edit_info *fe, *oldfe;
	size_t point;
	Region *old_region, *display_area_region;
	event_t event;
	objid_t obj;
	fnamemap_t *fm;
	int indent = 0;

	if (td_replaying())
		return NULL;
	
	obj = (objid_t)dr->dr_code;
	fm = get_field_edit_info(obj, dr->dr_fnum);
	
	old_region = re_get_keyboard_focus_region();
	oldfe = (Field_edit_info *)re_get_keyboard_focus_data(old_region);
	
	display_area_region = get_display_area_region();

	/*  We know that display_area_input() has pushed back an event for us.
	 *
	 *  BUG: fix the obj field editing interface.
	 */
	wn_next_event(dr->dr_wn, EV_BUTTON_DOWN | EV_MOUSE_MOVED, &event);
	
	if (old_region == display_area_region && oldfe != NULL &&
	    oldfe->obj == obj && oldfe->quitfunc == fm->quitfunc) {
		fe = oldfe;
		re_clear_force_quit_flag(display_area_region);
	}
	else {
		int display_wn, new_wn, x, y, width, height;
		Edit_keymap *keymap;
		
		fe = (Field_edit_info *)e_malloc(sizeof(Field_edit_info));

		if (!re_set_keyboard_focus(display_area_region, (char *)fe)) {
			free((char *)fe);
			return NULL;
		}
					 
		clear_selection();

		/*  The obj code thinks the edit is finished when we return,
		 *  so it closes the window.  Thus we must make a copy.
		 *
		 *  TODO: fix all this.
		 */
		display_wn = re_get_wn(display_area_region);
		wn_trans_coords(dr->dr_wn, 0, 0, display_wn, &x, &y);
		wn_get_window_size(dr->dr_wn, &width, &height);

		/* RGA probably not the right solution, but it works.
		 * Use this to shorten the width when editing fields
		 * in sub blocks of functions.
		 * First check for an indent from a function, then
		 * check for indent from an expanded source file to
		 * cover the case of globals.
		 */
		if (!strcmp(what, "value"))
		{
		  indent = get_indent_from_objtype(code_to_obj(obj), OT_FUNC);
		  if (!indent)
		    indent = get_indent_from_objtype(code_to_obj(obj), OT_SFILE_EX);
		}
		new_wn = wn_create_subwin(display_wn, x, y,
					  width - indent, height,
					  WN_INPUT_OUTPUT);
		wn_set_win_data(new_wn, (long)display_area_region);

		fe->wn = new_wn;
		fe->cancel = FALSE;
		fe->what = what;
		fe->null_string_ok = fm->null_string_ok;
		fe->textcopy = textcopy;
		fe->text = (textcopy != NULL) ? textcopy : (char *)dr->dr_fval;
		fe->display = make_text_display(fe->wn, dr->dr_fg, dr->dr_bg,
						fe->text);
		if ( fm->edit_history)
		    edit_set_history(fe->display, *fm->edit_history);
		fe->quitfunc = fm->quitfunc;
		fe->move_point_func = NULL;
		fe->obj = obj;
		fe->fnum = dr->dr_fnum;

		keymap = edit_create_keymap(edit_get_keymap(fe->display));
		edit_add_keymap_control_entry(keymap, 'c', do_cancel);
		edit_set_keymap(fe->display, keymap);

		fe->keymap = keymap;
	
		edit_set_user_data(fe->display, (char *)fe);

/*		edit_update_wn_window_size(fe->display, fe->wn);*/
/* RGA try to get editing of long fields initialized correctly */
		if (fe->move_point_func != NULL)
		  (*fe->move_point_func)(fe->display, obj, 0);
		else
		  edit_move_point(fe->display, 0);
	}

	if (!edit_pixel_to_point(fe->display, event.ev_x, event.ev_y, &point))
		point = 0;

	if (fe->move_point_func != NULL)
		(*fe->move_point_func)(fe->display, obj, point);
	else
		edit_move_point(fe->display, point);

	return fe->display;
}

void
field_edit_set_move_point_func(fe, move_point_func)
Field_edit_info *fe;
Field_edit_move_point_func move_point_func;
{
	fe->move_point_func = move_point_func;
}

static void
do_cancel(display)
Edit_display *display;
{
	Field_edit_info *fe;
	
	fe = (Field_edit_info *)edit_get_user_data(display);
	fe->cancel = TRUE;
	edit_f_request_quit(display);
}

objid_t
field_edit_get_object(fe)
Field_edit_info *fe;
{
	return fe->obj;
}

void
field_edit_update_orig_text(fe, text)
Field_edit_info *fe;
const char *text;
{
	fe->text = text;
}

void
field_edit_redraw_display(handle)
char *handle;
{
	edit_redraw_display(((Field_edit_info *)handle)->display);
}

Edit_display*
field_edit_get_display(handle)
char *handle;
{
	return ((Field_edit_info *)handle)->display;
}

void
field_edit_handle_key_event(region, handle, ev)
Region *region;
char *handle;
event_t *ev;
{
	Field_edit_info *fe;
	
	fe = (Field_edit_info *)handle;
	
	target_menu_search_disabled(1, 0); /* set */
	if (fe)
	{
	  edit_handle_wn_key_event(fe->display, ev);

	  if (edit_quit_requested(fe->display))
	    re_set_keyboard_focus((Region *)NULL, (char *)NULL);
	  else
	    re_clear_force_quit_flag(region);
	}
	target_menu_search_disabled(0, 1); /* reset */
}


bool
field_edit_finish(handle, force)
char *handle;
bool force;
{
	Field_edit_info *fe;
	bool confirmed;
	Edit_buffer *buffer;
	Edit_keymap *keymap;
	const char *display_string;

	fe = (Field_edit_info *)handle;
	
	if (!fe->cancel && confirm_field_edit(fe, &display_string)) {
		confirmed = TRUE;
	}
	else if (!force && !fe->cancel) {
		return FALSE;
	}
	else {
		confirmed = FALSE;
	}
	
	buffer = edit_get_buffer(fe->display);
	keymap = edit_get_keymap(fe->display);

	edit_set_want_cursor(fe->display, FALSE);
	
	if (!confirmed || display_string != NULL) {
		edit_delete(buffer, 0, edit_get_buffer_length(buffer));

		if (confirmed)
			edit_insert(buffer, 0,
				    display_string, strlen(display_string), TRUE);
		else
			edit_insert(buffer, 0, fe->text, strlen(fe->text), TRUE);
	}
	
	edit_display_from(fe->display, 0, 0);
	
	edit_close_display(fe->display);
	wn_close_window(fe->wn);
	edit_destroy_buffer(buffer);

	/*  Lose any keymaps added by the calling function as well as the
	 *  one we added.
	 */
	for (;;) {
		Edit_keymap *next;
		
		next = edit_get_next_keymap(keymap);
		edit_destroy_keymap(keymap);

		if (keymap == fe->keymap)
			break;

		keymap = next;
	}

	if (!confirmed && *fe->text == '\0' && !fe->null_string_ok) {
		td_record_object_removal(fe->obj);
		remove_object(fe->obj, OBJ_SELF);
	}

	if (fe->textcopy != NULL)
		free(fe->textcopy);
	free((char *)fe);

	return TRUE;
}

static bool
confirm_field_edit(fe, p_display_string)
Field_edit_info *fe;
const char **p_display_string;
{
	char *text;
	bool ok;

	*p_display_string = NULL;
	
	text = get_buffer_contents(edit_get_buffer(fe->display));

	if (!fe->null_string_ok && *text == '\0') {
		errf("Zero length %s illegal", fe->what);
		ok = FALSE;
	}
	else if (strcmp(fe->text, text) == 0) {
		ok = TRUE;
	}
	else {
		td_record_field_edit(fe->obj, fe->fnum, text);

		ok = (*fe->quitfunc)(fe->obj, text, p_display_string);

		if (ok) {
			edit_save_in_history(fe->display);
			obj_update_size(fe->obj);
		}
		else {
			/*  BUG: the redraw is because the change_field()
			 *  in expr_quitfunc() wipes out the expression
			 *  display.  We need a better way of doing this.
			 */
			edit_redraw_display(fe->display);
		}
	}

	free(text);

	return ok;
}

static fnamemap_t *
get_field_edit_info(obj, fnum)
objid_t obj;
int fnum;
{
	int objtype;
	fnamemap_t *fmtab, *fm;
	
	objtype = ups_get_object_type(obj);

	if (objtype < 0 || objtype > OT_MAXTYPE)
		panic("objtype bad in ce");
	fmtab = Objtab[objtype].ot_fnamemap;

	if (fmtab == NULL)
		panic("no editible fields in object");
	
	for (fm = fmtab; fm->name != NULL; ++fm) {
		if (fm->fnum == fnum)
			return fm;
	}
	
	panic("no matching editable field for object");
	return NULL;		/* to satisfy gcc */
}

objid_t
find_or_add_object(par, wanted, add_object)
objid_t par, wanted;
void (*add_object)PROTO((objid_t wobj));
{
	objid_t obj;

	obj = get_code(par, OBJ_CHILD);
	
	for (; obj != NULL; obj = get_code(obj, OBJ_NEXT)) {
		if (obj == wanted)
			break;
	}
	
	if (obj == NULL)
		(*add_object)(wanted);

	return wanted;
}

/* RGA insert text string from UPS_F*_STR menus */
void
field_edit_handle_insert_text(handle, text)
char *handle;
char *text;
{
  size_t i;
  Field_edit_info *fe;
        
  fe = (Field_edit_info *)handle;
  if (fe)
    for (i = 0; i < strlen(text); i++)
      edit_handle_key_event(fe->display, (int)text[i], 0);
}
