/* ci_libvars.h - C interpreter builtin variables */

/*  Copyright 1992 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

/* @(#)cx_libvars.h	1.4 21 Apr 1994 (UKC) */

#undef V
#undef V2
#undef VA

/*
 * One of WANT_ADDRS, WANT_DECLS or WANT_NAMES will be defined before
 * this file is included.
 */

#ifdef WANT_DECLS

#if HAVE_SYS_ERRLIST && !HAVE_SYS_ERRLIST_DECL
extern char *	sys_errlist[];
#endif
#if HAVE_SYS_NERR && !HAVE_SYS_NERR_DECL
extern int	sys_nerr;
#endif

#endif

#ifdef WANT_ADDRS
#	define V(var)		(char *)&var,
#	define V2(var, name)	(char *)&var,
#	define VA(var, name)	(char *)var,
#endif

#ifdef WANT_DECLS
#	define V(var)
#	define V2(var, name)
#	define VA(var, name)
#endif

#ifdef WANT_NAMES
#	ifdef __STDC__
#		define V(var)		#var,
#	else
#		define V(var)		"var",
#	endif
#	define V2(var, name)	name,
#	define VA(var, name)	name,
#endif

#if !defined errno
	V(errno)
#endif

#if HAVE_SYS_NERR
	V(sys_nerr)
#endif
#if HAVE_SYS_ERRLIST
#if HAVE_SYS_ERRLIST_DECL
	V2(Builtin_sys_errlist, "sys_errlist")
#else
	VA(sys_errlist, "sys_errlist")
#endif
#endif
	V(optind)
	V(optarg)
	V2(Builtin_environ, "environ")
#if HAVE_GLOBAL_IOB
	VA(GLOBAL_IOB, NAME_IOB)
	VA(GLOBAL_IOB, "_iob")
#endif
#if HAVE_GLOBAL_CTYPE
	V2(Builtin_ctype, NAME_CTYPE)
	V2(Builtin_ctype, "_ctype")
/*
	VA(GLOBAL_CTYPE, NAME_CTYPE)
	VA(GLOBAL_CTYPE, "_ctype")
*/
#endif
/* GNU implementation of standard I/O. */
#if defined(__GLIBC__)  && (__GLIBC__ >= 2)
#if defined(__GLIBC_MINOR__) && (__GLIBC_MINOR__ >= 1)
	/* glibc 2.1 */
	V(_IO_2_1_stdin_)
	V(_IO_2_1_stdout_)
	V(_IO_2_1_stderr_)
#else
	/* glibc 2.0 */
	V(_IO_stdin_)
	V(_IO_stdout_)
	V(_IO_stderr_)
#endif
#elif defined(_IO_stdin)
	/* glibc 1.x (and other early Linux ?) */
	V(_IO_stdin_)
	V(_IO_stdout_)
	V(_IO_stderr_)
#endif
#ifdef OS_ULTRIX
	V(_pctype)
#endif
#if HAVE_X_WINDOWS
	V(_Xdebug)
#endif

