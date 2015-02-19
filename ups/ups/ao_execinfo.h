/* ao_exec.h - generic interface to low level exec file info */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_execinfo.h	1.1 24/5/95 (UKC) */

#define AO_EXECINFO_H_INCLUDED

typedef struct {
	taddr_t text_mem_addr;	/* Start addr in memory where text is loaded */
	size_t text_size;	/* #bytes of text */
	off_t text_addr_delta;	/* What to add to fu_addr etc to get mem addr */
	
	off_t addr_to_fpos_offset; /* Delta from mem addr to file offset  */
	
	off_t file_syms_offset;
	int nsyms;
	off_t file_symstrings_offset;
	
	bool dynamic;		/* Is SunOS 4 shared lib (BUG: lose this) */
} Execinfo;
