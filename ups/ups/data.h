/* data.h - header file for data.c */

/*  Copyright 1991 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)data.h	1.6 09 Apr 1995 (UKC) */

typedef union {
	char vl_char;
	unsigned char vl_uchar;
	short vl_short;
	unsigned short vl_ushort;
	int vl_int;
	unsigned int vl_uint;
	long vl_long;
	unsigned long vl_ulong;
#if HAVE_LONG_LONG
	long long vl_longlong;
	unsigned long long vl_ulonglong;
#endif
	float vl_float;
	double vl_double;
#if HAVE_LONG_DOUBLE
	long double vl_longdouble;
	int vl_ints[sizeof(long double)/sizeof(int)];	/* for illegal double values */
#else
	int vl_ints[sizeof(double)/sizeof(int)];	/* for illegal double values */
#endif
	int vl_logical;
	taddr_t vl_addr;
} value_t;

void dump_uarea_to_file PROTO((target_t *xp, const char *name));
void dump_stack_to_file PROTO((target_t *xp, const char *name));

int dgets PROTO((target_t *xp, taddr_t addr, char *optr, int max_nbytes));
int dread PROTO((target_t *xp, taddr_t addr, void *buf, size_t nbytes));
int dread_fpval PROTO((target_t *xp, taddr_t addr,
				bool is_reg, int num_bytes, char *buf));
int dwrite PROTO((target_t *xp, taddr_t addr, const void *buf, size_t nbytes));
taddr_t regno_to_addr PROTO((int regno));
const char *get_real PROTO((bool words_big_endian,
			    value_t vl, bool want_hex, int num_bytes));

taddr_t adjust_saved_reg_addr PROTO((target_t *xp, taddr_t addr, size_t size));
int dump_to_buffer PROTO((target_t *xp, taddr_t addr, int len, int grp,
			  char *buffer));

