/* textbuf.h - generic text buffer interface */

/*  Copyright 1994 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)textbuf.h	1.2 09 Sep 1994 (UKC) */

#define TEXTBUF_H_INCLUDED

#ifndef TEXT_BUFFER_DEFINED
typedef struct Text_buffer Text_buffer;
#define TEXT_BUFFER_DEFINED
#endif /* !TEXT_BUFFER_DEFINED */

typedef struct Text_bufdata Text_bufdata;

typedef struct {
	void (*destroy)PROTO((Text_bufdata *tb));

	void (*insert)PROTO((Text_bufdata *tb, size_t pos,
			     const char *text, size_t len));
	void (*delete)PROTO((Text_bufdata *tb, size_t pos, size_t len));

	bool (*get_bytes)PROTO((Text_bufdata *tb, size_t pos,
				const char **p_line, const char **p_lim));
	bool (*get_bytes_before)PROTO((Text_bufdata *tb, size_t pos,
				       const char **p_line,
				       const char **p_lim));

	size_t (*get_length)PROTO((Text_bufdata *tb));
	void (*set_debug_flag)PROTO((Text_bufdata *tb));
} Text_buffer_ops;

struct Text_buffer {
	Text_bufdata *bufdata;
	Text_buffer_ops *ops;
};

/*  I/O callbacks used with some buffer types.
 */
typedef bool (*Text_info_func)PROTO((char *handle,
				     size_t *p_size, time_t *p_mtime));
typedef bool (*Text_read_func)PROTO((char *handle, char *buf,
				     long pos, size_t count));
typedef void (*Text_close_func)PROTO((char *handle));
