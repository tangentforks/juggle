/* ao_elfcore.h - header file for ao_elfcore.c */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_elfcore.h	1.1 24/5/95 (UKC) */

#if HAVE_SYS_PROCFS_H
#include <sys/procfs.h>
#endif

#if HAVE_PRGREG_T
/* Solaris 2.5.1 etc */

#define AO_ELF_CORE_REGS	1
typedef prgreg_t		elf_core_greg_t;
typedef prgregset_t		elf_core_gregset_t;
typedef prfpregset_t		elf_core_fpregset_t;

#elif HAVE_GREG_T || HAVE_GREGSET_T
/* FreeBSD, Linux */

#define AO_ELF_CORE_REGS	1
#if HAVE_GREG_T
typedef greg_t			elf_core_greg_t;
#else
typedef unsigned int		elf_core_greg_t;	/* Not in FreeBSD. */
#endif
typedef gregset_t		elf_core_gregset_t;
typedef fpregset_t		elf_core_fpregset_t;

#else

#define AO_ELF_CORE_REGS	0
/* Dummies to allow compilation. */
typedef int			elf_core_greg_t;
typedef int			elf_core_gregset_t;
typedef int			elf_core_fpregset_t;

#endif

#if AO_ELF_CORE_REGS
typedef struct {
	elf_core_gregset_t *regtab;
	elf_core_fpregset_t *p_fpregs;
} Elf_core_regs;
#endif

bool elf_get_core_info PROTO((alloc_pool_t *ap, const char *corepath, int fd,
			      bool want_messages, int *p_signo,
			      char **p_cmdname, const char **p_cmdline,
			      Core_segment **p_segments, int *p_nsegments,
			      char **p_regs));

int elf_get_core_reg PROTO((Coredesc *co, int regno, taddr_t *p_val));

