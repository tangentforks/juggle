/* as.h - header file for the assembler routines */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)as.h	1.5 12/22/93 (UKC) */

/*  Type of a jump.
 */
typedef enum jumptypeen {
	JT_BRANCH,
	JT_CALL,
	JT_END
} jumptype_t;

/*  An element in the list of jumps.
 */
typedef struct jump_s {
	jumptype_t ju_type;	/* call or branch */
	taddr_t ju_addr;	/* instruction addr - 0 for end of jump array */
	taddr_t ju_dstaddr;	/* target of jump - 0 if unknown */
	bool ju_unconditional;	/* is the jump unconditional? */
} jump_t;

/*  Utility routines provided for the machine specific assembler routines.
 */
const char *addr_to_func_and_offset PROTO((taddr_t addr, int allow_offset));
const char *hex PROTO((int n));

/*  Public routines in as_mi.c
 */
void dump_as_assembler PROTO((const char *funcname, int want_source_lines));
