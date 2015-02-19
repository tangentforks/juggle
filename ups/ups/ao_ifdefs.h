/* ao_ifdefs.h - define AO_TARGET and AO_USE_PROCFS or AO_USE_PTRACE */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)ao_ifdefs.h	1.1 24/5/95 (UKC) */

/*
 *  Define AO_TARGET for the hosts that we have native a.out back ends for.
 *  Other machines have the gdb based back end only.
 */

#ifdef OS_SUNOS
#define AO_TARGET		1
#endif

#ifdef OS_ULTRIX
#define AO_TARGET		1
#endif

#ifdef OS_BSD44
#define AO_TARGET		1
#endif

#ifdef ARCH_CLIPPER
#define AO_TARGET		1
#endif

#ifdef OS_LINUX
#define AO_TARGET		1
#endif

#if WANT_GDB
#ifdef AO_TARGET
#undef AO_TARGET
#endif
#define GDB_TARGET		1
#endif


/*
 *  If we do have native support, should we use 'ptrace()' or /proc ?
 *  Is the executable format ELF or "classic" 'a.out' ?
 */

#ifdef AO_TARGET
#if WANT_ELF
#define AO_ELF			1
#endif
#endif

#ifdef AO_TARGET
#ifdef OS_SUNOS_5
#define AO_USE_PROCFS		1
#else
#define AO_USE_PTRACE		1
#endif
#endif


/*
 *  Does the core file on this system have a copy of the u-area ?
 *  Also implies register values in core files come out of the u-area.
 *  As usual SunOS has its own code.
 */

#ifdef AO_TARGET
#if !defined(OS_SUNOS)
#define USERCORE		1
#endif
#endif


/*
 *  Shared library support ?
 *  ELF on ELF systems
 *  AOUT on SunOS 4.x, BSD 4.4 derivatives, non-ELF Linux.
 */

#if defined(AO_ELF)
#define AO_ELF_SHLIBS		1
#elif defined(OS_SUNOS_4) || defined(OS_BSD44) || defined(OS_LINUX)
#define AO_AOUT_SHLIBS		1
#endif


/*
 *  What are the capabilities/limitations of 'ptrace()' on the system ?
 *
 *  Note - SunOS has its own routines for get/set registers via 'ptrace()'.
 */

#ifdef OS_SUNOS
#define AO_HAS_PTRACE_RANGE	1	/* Can read/write n bytes at a time. */
#define AO_HAS_PTRACE_DUMPCORE	1	/* Can dump core with 'ptrace()'. */
#define AO_HAS_PTRACE_REGS	1	/* 'ptrace()' can get/set registers. */
#endif

#if defined(OS_SUNOS) || defined(OS_LINUX)
#define AO_HAS_PTRACE_ATTACH	1
#elif	defined(OS_BSD44)
#define AO_USE_PROCFS_ATTACH	1	/* Attach via 'ptrace()' is broken. */
#endif

#if defined (OS_BSD44)
#define AO_HAS_PTRACE_REGS	1	/* 'ptrace()' can get/set registers. */
#endif


