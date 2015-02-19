/* ao_target.h - common interface to the ao_ptrace.c and ao_proc.c */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_target.h	1.3 24 May 1995 (UKC) */

#define AO_TARGET_H_INCLUDED

#if AO_USE_PROCFS
typedef struct Procfs_info Procfs_info;
#else
typedef struct Ptrace_info Ptrace_info;
#endif

typedef struct iproc {
	int ip_pid;
	struct Coredesc *ip_core;
	taddr_t ip_base_sp;
	taddr_t ip_restart_pc;
	bool ip_lastsig;
	bool ip_attached;
	stopres_t ip_stopres;
#if AO_USE_PROCFS
	Procfs_info *ip_procfs_info;
#else
	Ptrace_info *ip_ptrace_info;
#endif
#ifdef AO_ELF
	struct Solib *ip_solibs;
	struct Solib_addr *ip_solib_addrs;
#else
	symtab_t *ip_main_symtab;
	symtab_t *ip_shlib_symtabs;
	symtab_t *ip_symtab_cache;
#endif
} iproc_t;

#define GET_IPROC(xp)	((iproc_t *)(xp)->xp_data)
