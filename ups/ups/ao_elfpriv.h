/* ao_elfpriv.h - stuff private to the ao_elf*.c routines */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_elfpriv.h	1.2 04 Jun 1995 (UKC) */

#define AO_ELFPRIV_H_INCLUDED

typedef struct Libdep Libdep;
#define LIBDEP_TYPEDEFED

struct Elfinfo {
	alloc_pool_t *apool;
	
	const char *path;
	int fd;
	const char *what;

	taddr_t min_file_vaddr;
	Libdep *libdep;

	Elf32_Shdr *sections;
	int num_sections;
	const char *sec_strings;

	Elf32_Shdr *symtab_sh;
	
	Elf32_Shdr *indexsh;
	Elf32_Shdr *indexstrsh;
};
