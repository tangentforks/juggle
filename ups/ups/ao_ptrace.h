/* ao_ptrace.h - header file for ao_ptrace.c */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_ptrace.h	1.1 24/5/95 (UKC) */

#if AO_USE_PTRACE

/* Cope with 'ptrace()' variations across systems. */
/* ----------------------------------------------- */

#if HAVE_PTRACE_H
#include <ptrace.h>
#elif HAVE_SYS_PTRACE_H
#include <sys/ptrace.h>
#endif

#if defined(OS_SUNOS)
typedef enum ptracereq ptracereq_t;
#endif 

#if defined(OS_LINUX)
#if HAVE_SYS_REG_H
#include <sys/reg.h>
#endif
/*
 *  Request values for the ptrace system call
 */
#if defined(PTRACE_PEEKUSR) && !defined(PTRACE_PEEKUSER)
#define PTRACE_PEEKUSER PTRACE_PEEKUSR
#define PTRACE_POKEUSER PTRACE_POKEUSR
#endif
typedef int ptracereq_t;
#endif

#if defined (OS_BSD44)
/*
 *  Request values for the ptrace system call
 */
#define PTRACE_TRACEME	PT_TRACE_ME	/* by tracee to begin tracing */
#define PTRACE_PEEKTEXT	PT_READ_I	/* read word from text segment */
#define PTRACE_PEEKDATA	PT_READ_D	/* read word from data segment */
#define PTRACE_PEEKUSER	PT_READ_U	/* read word from user struct */
#define PTRACE_POKETEXT	PT_WRITE_I	/* write word into text segment */
#define PTRACE_POKEDATA	PT_WRITE_D	/* write word into data segment */
#define PTRACE_POKEUSER	PT_WRITE_U	/* write word into user struct */
#define PTRACE_CONT	PT_CONTINUE	/* continue process */
#define PTRACE_KILL	PT_KILL		/* terminate process */
#define PTRACE_SINGLESTEP PT_STEP	/* single step process */

#if defined(PT_ATTACH) && defined(PT_DETACH)
#define PTRACE_ATTACH	PT_ATTACH
#define PTRACE_DETACH	PT_DETACH
#else
#define PTRACE_ATTACH	10
#define PTRACE_DETACH	11
#endif

#if defined(PT_GETREGS) && defined(PT_SETREGS)
#define PTRACE_GETREGS	PT_GETREGS
#define PTRACE_SETREGS	PT_SETREGS
#endif

typedef int ptracereq_t;
#endif

#if defined(ARCH_MIPS) && (defined(OS_ULTRIX) || defined(OS_RISCOS))
/*
 *  Request values for the ptrace system call
 */
enum ptracereq {
	PTRACE_TRACEME = PT_TRACE_ME,	/* by tracee to begin tracing */
	PTRACE_PEEKTEXT = PT_READ_I,	/* read word from text segment */
	PTRACE_PEEKDATA = PT_READ_D,	/* read word from data segment */
	PTRACE_PEEKUSER = PT_READ_U,	/* read word from user struct */
	PTRACE_POKETEXT = PT_WRITE_I,	/* write word into text segment */
	PTRACE_POKEDATA = PT_WRITE_D,	/* write word into data segment */
	PTRACE_POKEUSER = PT_WRITE_U,	/* write word into user struct */
	PTRACE_CONT = PT_CONTINUE,	/* continue process */
	PTRACE_KILL = PT_KILL,		/* terminate process */
	PTRACE_SINGLESTEP = PT_STEP,	/* single step process */
};
typedef enum ptracereq ptracereq_t;
#endif


/*
 *  Structure to hold registers got via 'ptrace()'.
 */
struct Ptrace_info {
#if defined(ARCH_CLIPPER)
	taddr_t fpreg_sp;
	ureg_t fp_uregs[16];
#elif defined(OS_SUNOS_4)
	sunregs_t sunregs;
#elif AO_HAS_PTRACE_REGS
	ptrace_regs_t ptrace_regs;
#elif defined(UAREA_REGS)
	ureg_t uregs[N_UREGS];
#endif
};


/*
 *
 */
#ifdef ARCH_SUN3
#define BPT_PC_OFFSET			2
#else
#ifdef ARCH_386
#define BPT_PC_OFFSET			1
#else
#define BPT_PC_OFFSET			0
#endif
#endif


/*
 *  Routine declarations.
 */
int ptrace_setreg PROTO((iproc_t *ip, int regno, taddr_t value));
int ptrace_create_child PROTO((target_t *xp,
                               const char **argv, const char **envp, 
                               long rdlist, stopres_t *p_stopres));
int ptrace_attach_to_process PROTO((target_t *xp, int pid));
void ptrace_kill PROTO((target_t *xp));
void ptrace_stop PROTO((target_t *xp));
void ptrace_detach_from_process PROTO((target_t *xp));
stopres_t ptrace_continue PROTO((target_t *xp, taddr_t addr, int sig));
stopres_t ptrace_single_step PROTO((target_t *xp, int sig));
int ptrace_readreg PROTO((iproc_t *ip, int regno, taddr_t *p_val));
int ptrace_read_fpreg PROTO((iproc_t *ip, int regno, int num_bytes, 
                             fpval_t *p_val));
int ptrace_tswap PROTO((iproc_t *ip, taddr_t addr, xp_opcode_t opcode, 
                        xp_opcode_t *p_old_opcode));
sigstate_t ptrace_get_sigstate PROTO((iproc_t *ip, int signo));
int ptrace_read_text_from_process PROTO((iproc_t *ip, taddr_t addr, char *buf, 
                                         size_t nbytes));
int ptrace_read_data PROTO((iproc_t *ip, taddr_t addr, char *buf, 
                            size_t nbytes));
int ptrace_write_data PROTO((iproc_t *ip, taddr_t addr, const char *buf, 
                             size_t nbytes));
int ptrace_write_text PROTO((iproc_t *ip, taddr_t addr, const char *buf, 
                             size_t nbytes));
int ptrace_write_corefile PROTO((iproc_t *ip, const char *name));

void ptrace_init_pid PROTO((iproc_t *ip, int pid, bool attached));
void ptrace_wait_for_target PROTO((target_t *xp));
int ptrace_update_regs PROTO((target_t *xp));
int e_ptrace PROTO((ptracereq_t req, int pid, char *addr, int data));
int x86_gcc_register PROTO((int regno));


#ifdef OS_SUNOS_4
int ptrace_set_all_regs PROTO((iproc_t *ip, sunregs_t *regtab));
void ptrace_get_regtab PROTO((iproc_t *ip, sunregs_t *regtab));
#endif
int ptrace_get_last_attach_pid PROTO((void));

#ifdef PTRACE_DEBUG
int ptrace_debug PROTO((int request, int pid, int addr, int data));
#define ptrace ptrace_debug
#endif

#if defined(OS_SUNOS)
int ptrace PROTO((ptracereq_t req, int pid, char *addr, int data, char *addr2));
#define std_ptrace(req, pid, addr, data)	ptrace(req, pid, addr, data, (char *)NULL)
#elif defined(OS_BSD44)
#define std_ptrace(req, pid, addr, data)	ptrace(req, pid, addr, data)
#elif defined(OS_LINUX)
#define std_ptrace(req, pid, addr, data)	ptrace(req, pid, (int)addr, data)
#else
int ptrace PROTO((ptracereq_t req, int pid, char *addr, int data));
#define std_ptrace(req, pid, addr, data)	ptrace(req, pid, addr, data)
#endif

#endif /*AO_USE_PTRACE*/
