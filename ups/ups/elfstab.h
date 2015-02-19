/* elfstab.h - ELF debugging symbols */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)elfstab.h	1.1 24/5/95 (UKC) */

/*  A debugging symbol in an ELF file.
 */
struct  nlist {
        long n_offset;
        unsigned char n_type;
        char n_other;
        short n_desc;
        unsigned long n_value;
};
 
#define N_EXT   1

/*  Symbol types, as described in the `SPARCworks 3.0.x Debugger Interface'
 *  document.
 */
#define N_ABS		0x02
#define N_ALIAS		0x6c
#define N_BCOMM		0xe2
#define N_BINCL		0x82
#define N_BROWS		0x48
#define N_BSS		0x08
#define N_CMDLINE	0x34
#define N_COMM		0x12
#define N_CONSTRUCT	0xd2
#define N_DATA		0x06
#define N_DESTRUCT	0xd4
#define N_ECOML		0xe8
#define N_ECOMM		0xe4
#define N_EINCL		0xa2
#define N_ENDM		0x62
#define N_ENTRY		0xa4
#define N_EXCL		0xc2
#define N_ILDPAD	0x4c   /* For SC4.  Was N_FLINE */
#define N_FN		0x1f
#define N_FNAME		0x22
#define N_FUN		0x24
#define N_GSYM		0x20
#define N_LBRAC		0xc0
#define N_LCSYM		0x28
#define N_LENG		0xfe
#define N_LSYM		0x80
#define N_MAIN		0x2a
#define N_OBJ		0x38
#define N_OPT		0x3c
#define N_PATCH		0xd0
#define N_PC		0x30
#define N_PSYM		0xa0
#define N_RBRAC		0xe0
#define N_ROSYM		0x2c
#define N_RSYM		0x40
#define N_SLINE		0x44
#define N_SO		0x64
#define N_SOL		0x84
#define N_SSYM		0x60
#define N_STSYM		0x26
#define N_TEXT		0x04
#define N_UNDF		0x00
#define N_WITH		0xea
#define N_XCOMM		0xe6
#define N_XLINE		0x45

/* RCB: From SC5 stab.h file:
*/
#define N_ISYM  0xc6            /* position independent type symbol, internal */
#define N_ESYM  0xc8            /* position independent type symbol, external */
