/* props.h - header file for props.c - private to the edit library */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)props.h	1.2 31 Aug 1994 (UKC) */

struct Edit_fontinfo {
	char *font_handle;
	short *char_width_tab;
	int height;
	int baseline;
};

struct Edit_propchange {
	size_t point;
	char *user_data;
	bool new_font;
	Edit_fontinfo *fi;
	Edit_flags flags;
	Edit_flags flagmask;
	bool backsliding;
	Edit_propchange *next;
};

void edit__update_proplist_points PROTO((Proplist *pl, size_t pos, long delta));
