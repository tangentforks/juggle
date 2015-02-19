/* ao_asm.h - public header file for ao_asm.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_asm.h	1.1 22/12/93 (UKC) */

jump_t *get_asm_jumps PROTO((taddr_t addr, const char *text, size_t len,
							bool want_calls));
taddr_t get_next_pc PROTO((target_t *xp, taddr_t pc));

const char *disassemble_one_instruction PROTO((taddr_t addr, const char *text,
							   const char **p_buf));

