/* ci_opcodes.h - header file for ci_opcodes.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ci_opcodes.h	1.4 22/12/93 (UKC) */

int ci_operand_size PROTO((opcode_t opcode, textword_t *text));
int ci_get_next_pc_and_cf PROTO((machine_t *ma,
				 codefile_t **p_cf, textword_t **p_pc));
