/* render.h - header file for render.c */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)render.h	1.2 04 Sep 1994 (UKC) */

typedef struct Render_desc Render_desc;

typedef struct {
	size_t point;
	int ch_offset;		/* Offset within multibyte character */
	size_t column;		/* Display column # */
	Render_desc *rdesc;	/* Info from convert_line() to render_line() */
	
	int height;		/* Height of line in pixels */
	int baseline;		/* Baseline for rendering text */
	bool line_continues;	/* More of this logical line to come */
} Lmap;

Render_context *edit__make_render_context PROTO((int tabspaces,
						 bool stop_at_newline,
						 bool fold_lines,
						 int lmore_width,
						 int lmore_lmargin,
						 int rmore_width,
						 int rmore_lmargin,
						 int more_vmargin));

void edit__draw_lmap_cursor PROTO((Edit_display *d, Lmap *lm, size_t point,
				   int ypos, bool on));

void edit__init_rdesc PROTO((Lmap *lmap));
void edit__copy_lmap PROTO((Lmap *dst, Lmap *src));
void edit__free_rdesc PROTO((Lmap *lmap));

void edit__set_lmap PROTO((Lmap *lm, size_t point));

void edit__convert_line PROTO((Edit_display *d, Lmap *lm, Lmap *nextlm, 
			       Edit_propchange **p_pc));

bool edit__xpos_to_point PROTO((Edit_display *d, Lmap *lm, int xpos,
				size_t *p_point));

bool edit__lmap_point_to_pixel PROTO((Edit_display *d, Lmap *lm, size_t point, 
				      int *p_x, int *p_width,
				      int *p_height, int *p_baseline));


void edit__render_line PROTO((Edit_display *d, Lmap *lm, int ypos,
			      Lmap *oldrd));

void edit__update_rdesc_points PROTO((Render_desc *rd, size_t point,
				      long delta));

void edit__check_rdescs_same PROTO((Render_desc *rd1, Render_desc *rd2));

bool edit__extra_char_would_fit PROTO((Edit_display *d, Lmap *lm, int ch));
