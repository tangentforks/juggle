/* ao_elflib.h - header file for ao_elflib.c */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_elflib.h	1.1 24/5/95 (UKC) */

#ifndef ELFINFO_TYPEDEFED
typedef struct Elfinfo Elfinfo;
#define ELFINFO_TYPEDEFED
#endif

#ifndef SOLIB_TYPEDEFED
typedef struct Solib Solib;
typedef struct Solib_addr Solib_addr;
#define SOLIB_TYPEDEFED
#endif

#ifdef TARGET_H_INCLUDED
bool elf_next_symtab PROTO((target_t *xp, symtab_t *st, bool load_new,
			    symtab_t **p_next_st));

void elf_zap_solib_addrs PROTO((target_t *xp));

void dump_elf_libs PROTO((target_t *xp));

int elf_save_symtab_breakpoints PROTO((target_t *xp, bool remove_bpts));

void elf_rescan_dynamic_solibs PROTO((target_t *xp));

#endif

#ifdef AO_TARGET_H_INCLUDED
bool elf_note_shlib_addr PROTO((iproc_t *ip, dev_t dev, ino_t ino,
				off_t size, long mtv_sec,  long mtv_nsec,
				off_t offset, taddr_t vaddr, size_t pagesize));

bool elf_get_core_shlib_info PROTO((alloc_pool_t *ap, iproc_t *ip));
#endif

struct func_s;
bool elf_get_dynamic_solibs PROTO((alloc_pool_t *target_ap, const char *path,
				   Solib **p_solib, bool check_only));

bool scan_main_elf_symtab PROTO((alloc_pool_t *target_ap, const char *path,
				 int fd, long modtime, Solib **p_solib,
				 Solib_addr **p_solib_addrs,
				 struct func_s **p_mainfunc,
				 struct func_s **p_initfunc));

void elf_restore_symtab_breakpoints PROTO((void));

#ifdef SYMTAB_H_INCLUDED
bool add_solib_entry PROTO((alloc_pool_t *ap, symtab_t *st, Elfinfo *el,
			    Solib **p_solibs));
#endif

