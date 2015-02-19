/* win.h - header file for win.c */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)win.h	1.7 09 Apr 1995 (UKC) */

Edit_fontinfo *edit_make_wn_fontinfo PROTO((font_t *font));

Edit_display *edit_create_wn_display PROTO((int wn, int fg, int bg,
					    bool want_cursor,
					    bool keep_cursor_visible));

void edit_handle_wn_key_event PROTO((Edit_display *d, event_t *ev));

bool edit_update_wn_window_size PROTO((Edit_display *d, int wn));
void edit_update_wn_window_colors PROTO((Edit_display *d, int fg, int bg));

void edit_set_wn_selection PROTO((Edit_buffer *buffer,
				  size_t start, size_t count));
