/* ao_core.h - header file for ao_core.c */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_core.h	1.3 24 May 1995 (UKC) */

#define AO_CORE_H_INCLUDED

typedef struct {
	taddr_t base;
	taddr_t lim;
	off_t file_offset;
} Core_segment;

typedef struct Coredesc Coredesc;

bool open_corefile PROTO((alloc_pool_t *ap, const char *corename,
		         const char *textname, bool user_gave_core,
			 taddr_t data_addr, Coredesc **p_co, int *p_lastsig));

bool core_dread PROTO((Coredesc *co, taddr_t addr, voidptr buf, size_t nbytes));
bool core_read PROTO((Coredesc *co, off_t offset, voidptr buf, size_t nbytes));
bool core_readstr PROTO((Coredesc *co, taddr_t addr, char *buf, size_t buflen));

char *core_getregs PROTO((Coredesc *co));
const char *core_get_cmdline PROTO((Coredesc *co));
