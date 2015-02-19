/* ao_ptrace.c - process manipulation for a.out files using ptrace */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ups_ao_ptrace_c_sccsid[] = "@(#)ao_ptrace.c	1.2 04 Jun 1995 (UKC)";

#include <mtrprog/ifdefs.h>
#include "ao_ifdefs.h"

/*
 *  This file contains general routines concerned with using the 'ptrace()'
 *  system call to debug processes.  The gory detail is in "ao_ptuarea.c".
 *
 *  Look in "ao_ifdefs.h" for the definitions of AO_... symbols.
 *
 */

#if AO_USE_PTRACE

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <signal.h>
#include <setjmp.h>
#include <local/ukcprog.h>
#include <mtrprog/utils.h>
#include <local/arg.h>
#include <errno.h>

#include "ups.h"
#include "ui.h"
#include "mreg.h"
#include "symtab.h"
#include "target.h"
#include "ao_target.h"
#include "ao_ptrace.h"
#include "debug.h"


/* Definitions. */
/* ------------ */

#ifndef AO_HAS_PTRACE_RANGE
/* Word size (and alignment) for ptrace read/write data requests.  */
#define WORDSIZE	4
#endif

#if defined(OS_SUNOS) || defined(OS_BSD44) || defined(OS_LINUX)
typedef int wait_arg_t;
#define WAIT_STATUS_IS_INT
#else
typedef union wait wait_arg_t;
#endif

#ifdef ARCH_SUN4
#define NO_SINGLE_STEP
#include "dx.h"
#endif

#ifndef WSTOPSIG
#define WSTOPSIG(w)	((w).w_stopsig)
#endif


/* Used for reattaching to same target */
static int Last_attach_pid; 

/* Used by 'stop_target()'. */
static jmp_buf Longjmp_env;


static void stop_target PROTO((void));
static char *get_restart_pc PROTO((iproc_t *ip));
static int wait_with_intr PROTO((wait_arg_t *p_status));
static int get_words PROTO((int pid, ptracereq_t ptrace_req,
			    taddr_t addr, char *buf, size_t nbytes));

#ifndef AO_HAS_PTRACE_RANGE

static int
get_words(pid, ptrace_req, addr, buf, nbytes)
int pid;
ptracereq_t ptrace_req;
taddr_t addr;
char *buf;
size_t nbytes;
{
	char *optr;
	int word, trailing_nbytes;
	taddr_t lim;

	optr = buf;

	/*  Round down the address to a four byte alignment
 */
	if ((addr & (WORDSIZE - 1)) != 0) {
		taddr_t aligned;
		int offset, count;

		offset = addr & (WORDSIZE - 1);
		aligned = addr - offset;
		errno = 0;
		word = std_ptrace(ptrace_req, pid, (char *)aligned, 0);
		if (errno != 0)
			return -1;


		count = WORDSIZE - offset;
		if (count > nbytes)
			count = nbytes;
		memcpy(buf, (char *)&word + offset, count);

		optr += count;
		addr += count;
		nbytes -= count;
	}

	/*  At this point addr is on a 32 bit word boundary.
	 */
	trailing_nbytes = nbytes & 03;
	nbytes -= trailing_nbytes;

	lim = addr + nbytes;
	errno = 0;

	/*  Copy the whole words into the buffer.  We still have to use
	 *  memcpy because optr might not be four byte aligned (in our
	 *  address space) and some machines (e.g. MIPS) would object.
	 */
	while (addr < lim) {
		word = std_ptrace(ptrace_req, pid, (char *)addr, 0);
		memcpy(optr, (char *)&word, WORDSIZE);
		addr += WORDSIZE;
		optr += WORDSIZE;
	}

	if (trailing_nbytes != 0) {
		word = std_ptrace(ptrace_req, pid, (char *)addr, 0);
		memcpy(optr, (char *)&word, trailing_nbytes);
	}
	
	return errno != 0 ? -1 : 0;
}

#endif


static char *
get_restart_pc(ip)
iproc_t *ip;
{
#ifdef ARCH_CLIPPER
	if (ip->ip_ptrace_info->fpreg_sp != 0)
		return (char *)ip->ip_restart_pc;
#endif
	if (ip->ip_stopres != SR_BPT)
		return (char *)1;

	return (char *)ip->ip_restart_pc;
}


/*  A pointer to this is passed to wn_set_abort_func() by ptrace_wait_for_target().
 */
static void
stop_target()
{
	longjmp(Longjmp_env, 1);
}

static int
wait_with_intr(p_status)
wait_arg_t *p_status;
{
	int ret;
	if (setjmp(Longjmp_env) == 1)
		return 0;

#ifdef OS_LINUX
	ret = wait3(p_status, WNOHANG, NULL);
#else
	if (get_run_alarm_time() > 0)
	    ret = wait3(p_status, WNOHANG, NULL);
	else
	    ret = wait(p_status);
#endif

	return ret;
}


/*  Wait for process xp to stop.  If the process didn't die, update the
 *  stored register values.   Set ip_stopres to the reason why the
 *  process stopped, and ip_restart_pc to the address the process
 *  should be restarted from.
 */
void
ptrace_wait_for_target(xp)
target_t *xp;
{
	static int want_errors = -1;
	iproc_t *ip;
	stopres_t stopres;
	int pid, at_bpt;
	bool user_stopped_target;
	wait_arg_t status;
	bool want_timer = FALSE;
	struct timeval when, t;

	ip = GET_IPROC(xp);

	if (want_errors == -1)
		want_errors = getenv("WANT_ERRORS") != NULL;

	if (get_run_alarm_time() > 0) {
	    want_timer = TRUE;
	    gettimeofday (&when, NULL);
	    when.tv_sec  += get_run_alarm_time() / (1000*1000);
	    when.tv_usec += get_run_alarm_time() % (1000*1000);
	    if (when.tv_usec > (1000*1000))
		when.tv_sec++;
	    when.tv_usec  = when.tv_usec % (1000*1000);
	}

	user_stopped_target = FALSE;
	for (;;) {
		abort_func_t oldfunc;

		if ((Debug_flags & DBFLAG_NO_STOP) != 0)
			pid = wait(&status);
		else {
			oldfunc = set_user_abort_func(stop_target);
			pid = wait_with_intr(&status);
			(void) set_user_abort_func(oldfunc);
		}

		if (pid == 0) {
			/* Non-blocking wait() */
			if (user_wants_stop(FALSE)) {
				kill(ip->ip_pid, SIGTRAP);
				user_stopped_target = TRUE;
			}
			if (want_timer > 0) {
				gettimeofday (&t, NULL);
				if ((t.tv_sec >= when.tv_sec) && (t.tv_usec > when.tv_usec))
				{
					run_alarm_time_expired();
					want_timer = 0;
				}
			}
			continue;
		}
		else if (user_wants_stop(FALSE)) /* RGA so Stop button breaks */
		    user_stopped_target = TRUE;  /* out of a Step */
		if (pid == ip->ip_pid)
			break;
		else if (pid == -1) {
			if (errno != EINTR)
				errf("Wait returned -1: %s", get_errno_str());
		}
		else {
			if (want_errors)
				errf("Wait returned bad pid %d (expected %d)",
								pid, ip->ip_pid);
		}
	}

	if (WIFSTOPPED(status)) {
		ip->ip_lastsig = 0;
		at_bpt = ptrace_update_regs(xp);
		if (WSTOPSIG(status) != SIGTRAP) {
			stopres = SR_SIG;
			ip->ip_lastsig = WSTOPSIG(status);
		}
		else if (user_stopped_target)
			stopres = SR_USER;
		else if (at_bpt)
			stopres = SR_BPT;
		else
			stopres = SR_SSTEP;
	}
	else {
		ip->ip_lastsig = -1;
		ip->ip_restart_pc = 0;
		stopres = SR_DIED;
		mark_breakpoints_as_uninstalled(xp);
	}
	ip->ip_stopres = stopres;

	if (stopres == SR_DIED) {
	ip->ip_pid = 0;
		unload_shared_library_symtabs(xp);
	}
}


void
ptrace_stop(xp)
target_t *xp;
{
	iproc_t *ip;

	ip = GET_IPROC(xp);

	if (ip != 0) {
	  kill(ip->ip_pid, SIGSTOP);
	}
}


stopres_t
ptrace_continue(xp, addr, sig)
target_t *xp;
taddr_t addr;
int sig;
{
	iproc_t *ip;

	ip = GET_IPROC(xp);

	e_ptrace(PTRACE_CONT,
		 ip->ip_pid,
		 (addr != 0) ? (char *)addr : get_restart_pc(ip),
		 sig);
	
	ptrace_wait_for_target(xp);
	return ip->ip_stopres;
}


stopres_t
ptrace_single_step(xp, sig)
target_t *xp;
int sig;
{
	iproc_t *ip;
#ifdef NO_SINGLE_STEP
	taddr_t npc;
	breakpoint_t *bp;
	bool must_remove_bp, must_uninstall_bp;
#endif

	ip = GET_IPROC(xp);

#ifdef NO_SINGLE_STEP
	/*  Ask an as_*.c routine where it thinks the pc is going.
	 */
	npc = get_next_pc(xp, ip->ip_restart_pc);

	bp = dx_addr_to_breakpoint(xp, npc);
	must_remove_bp = bp == NULL;
	if (bp == NULL)
		bp = dx_add_breakpoint(xp, npc);

	must_uninstall_bp = !breakpoint_is_installed(bp);
	if (must_uninstall_bp && install_breakpoint(bp, xp) != 0)
		panic("can't install bp in sst");

	e_ptrace(PTRACE_CONT, ip->ip_pid, get_restart_pc(ip), sig);
	ptrace_wait_for_target(xp);

	if (ip->ip_stopres != SR_DIED) {
		if (must_uninstall_bp && uninstall_breakpoint(bp) != 0)
			panic("can't uninstall bp in sst");
		if (must_remove_bp && dx_remove_breakpoint(xp, bp) != 0)
			panic("can't remove bp in sst");
		if (ip->ip_restart_pc == npc && ip->ip_stopres == SR_BPT)
			ip->ip_stopres = SR_SSTEP;
	}
#else
	(void) e_ptrace(PTRACE_SINGLESTEP, ip->ip_pid,
			get_restart_pc(ip), sig);
	ptrace_wait_for_target(xp);
#endif /* !NO_SINGLE_STEP */

	return ip->ip_stopres;
}


/*  Kill off the target process
 */
void
ptrace_kill(xp)
target_t *xp;
{
	wait_arg_t status;
	iproc_t *ip;

	ip = GET_IPROC(xp);

	std_ptrace(PTRACE_KILL, ip->ip_pid, (char *)NULL, 0);

	if (ip->ip_attached) {
		/*  wait() hangs on a PTRACE_ATTACH process which
		 *  has been killed, so fake the status.
	 */
#ifdef WAIT_STATUS_IS_INT
		status = SIGKILL;
#else
		status.w_T.w_Termsig = SIGKILL;
		status.w_T.w_Retcode = 0;
#endif
	}
	else {
		ptrace_wait_for_target(xp);
	}
        mark_breakpoints_as_uninstalled(xp);
	unload_shared_library_symtabs(xp);
	ip->ip_pid = 0;
}


int 
ptrace_create_child(xp, argv, envp, rdlist, p_stopres)
target_t *xp;
const char **argv, **envp;
long rdlist;
stopres_t *p_stopres;
{
	iproc_t *ip;
	int pid;
	taddr_t main_addr, main_min_bpt_addr;

	ip = GET_IPROC(xp);

	fflush(stdout);
	fflush(stderr);

	if ((pid = vfork()) == 0) {
		arg_do_redirs_in_child(rdlist);
		if (std_ptrace(PTRACE_TRACEME, 0, (char *)NULL, 0) != 0)
			panic("ptrace TRACEME request failed in child");
		execve(xp->xp_textpath, (char **)argv, (char **)envp);
		perror(xp->xp_textpath);
		_exit(1);
	}

	arg_tidy_redirs_in_parent(rdlist);
	if (pid == -1) {
		failmesg("Can't fork to run", "", xp->xp_textpath);
		*p_stopres = SR_DIED;
		return -1;
	}

#ifndef OS_LINUX
	if (ip->ip_core != NULL)
		unload_shared_library_symtabs(xp);
#endif
		
	ptrace_init_pid(ip, pid, FALSE);

	ptrace_wait_for_target(xp);
		
	if (ip->ip_stopres == SR_DIED) {
		errf("Can't start %s", xp->xp_textpath);
		*p_stopres = SR_DIED;
		return -1;
	}

	*p_stopres = ip->ip_stopres;
	if (!target_process_exists(xp))
		return -1;

	if (get_startup_stop_addrs(xp, &main_addr, &main_min_bpt_addr) != 0)
		return -1;

	/*  We want the target stopped at the start of main so we can
	 *  get the minimum sp value (xp_set_base_sp) - this is used
	 *  to decide when we have stepped off the end of main.
	 *
	 *  Under SunOS we also need to load shared library information
	 *  after the target has started and the runtime linking has been
	 *  done.  In this case (OS_SUNOS_4) we have to first stop right
	 *  at the start of main, then set another breakpoint after the
	 *  stack setup code (the usual place) and continue the target to
	 *  that.  The reason for this is that run-time linking invoked
	 *  from [start] will overwrite the first user instruction in main
	 *  if it refers to a shared library global, blowing away any
	 *  breakpoint that has been written there.  We assume that the
	 *  stack setup code will not contain such an instruction.
	 *
	 *  RCB: above does not work with g++, can't plant breakpoints in
	 *  static constructor.
	 */
	if (*p_stopres == SR_SSTEP) {
#ifdef OS_SUNOS_4
		*p_stopres = xp_execto(xp, main_addr);
		/* FIX: This should really be a test on LANG_CC and CT_GNU_CC. */
		if (get_mainfunc_lang() != LANG_CC) {
		    if (*p_stopres == SR_BPT && main_addr != main_min_bpt_addr)
			    *p_stopres = xp_execto(xp, main_min_bpt_addr);
		}
#else
		*p_stopres = xp_execto(xp, main_min_bpt_addr);
#ifdef AO_ELF
		xp->xp_new_dynamic_libs = 
		elf_get_dynamic_solibs(xp->xp_apool, xp->xp_textpath,
				       &ip->ip_solibs, FALSE);
#endif
#endif
	}

	return 0;
}
	

int 
ptrace_get_last_attach_pid()
{
  return Last_attach_pid;
}


int
ptrace_attach_to_process(xp, pid)
target_t *xp;
int pid;
{
#if AO_HAS_PTRACE_ATTACH || AO_USE_PROCFS_ATTACH
	iproc_t *ip;
	int reattach;

	if (pid == 0)
	  pid = Last_attach_pid;
	else
	  Last_attach_pid = pid;

	ip = GET_IPROC(xp);

#if AO_USE_PROCFS_ATTACH
	{
	    int fd;
	    char *procfs_file;
	    procfs_file = strf ("/proc/%d/ctl", pid);
	    if (((fd = open (procfs_file, O_WRONLY, 0)) < 0)
		    || (write (fd, "attach", 7) != 7)) {
		errf("Can't attach to %s (%s)", procfs_file, get_errno_str());
		return -1;
	    }
	    close (fd);
	}
#elif AO_HAS_PTRACE_ATTACH
	if (std_ptrace(PTRACE_ATTACH, pid, (char *)NULL, 0) != 0) {
		errf("Can't attach to process %d (%s)", pid, get_errno_str());
			return -1;
	}
#endif
	ptrace_init_pid(ip, pid, TRUE);

	ptrace_wait_for_target(xp);

	if (ip->ip_stopres == SR_DIED) {
		errf("Process %d died on being attached to!", pid);
		ip->ip_pid = 0;
		return -1;
	}

	reattach = ptrace_get_last_attach_pid() != 0;
	if (reattach)
	{
	  free_library_load_list();
	  if (td_init_from())
	  {
	    bool eof;
	    int res;

	    res = td_load_loop(&eof);

	    if (res != 0)
	      fprintf(stderr, "Error in init file\n");
	    td_restore_replay_fp();
	 }
	}
#if defined(AO_AOUT_SHLIBS)
	load_shared_library_symtabs(xp, FALSE);
#endif

	return 0;
#else
	errf("This machine does not support attaching to running processes");
	return -1;
#endif
}


/*  Detach from a process which we earlier attached to.
 *  Leave the process running.
 */
void
ptrace_detach_from_process(xp)
target_t *xp;
{
	iproc_t *ip;

	ip = GET_IPROC(xp);
	
#if AO_USE_PROCFS_ATTACH
	{
	    int fd;
	    char *procfs_file;
	    procfs_file = strf ("/proc/%d/ctl", ip->ip_pid);
	    if (((fd = open (procfs_file, O_WRONLY, 0)) < 0)
		    || (write (fd, "detach", 7) != 7)) {
		errf("Can't detach from %s (%s)", procfs_file, get_errno_str());
	    }
	    close (fd);
	}
#elif AO_HAS_PTRACE_ATTACH
	(void) e_ptrace(PTRACE_DETACH, ip->ip_pid,
			get_restart_pc(ip), ip->ip_lastsig);
#endif
	unload_shared_library_symtabs(xp);
	ip->ip_pid = 0;
	ip->ip_attached = FALSE; /* RGA added */
}


int
ptrace_write_text(ip, addr, buf, nbytes)
iproc_t *ip;
taddr_t addr;
const char *buf;
size_t nbytes;
{
#if AO_HAS_PTRACE_RANGE
	if (ptrace(PTRACE_WRITETEXT, ip->ip_pid,
		   (char *)addr, (int)nbytes, (char *)buf) != 0)
		return -1;
	return 0;
#else
	int word;

	if (nbytes != sizeof(int))
		panic("ptrace_write_text for nbytes!=sizeof(int) NYI");

	memcpy((char *)&word, buf, sizeof(word));
	
	errno = 0;
	std_ptrace(PTRACE_POKETEXT, ip->ip_pid, (char *)addr, word);

	return (errno == 0) ? 0 : -1;
#endif
}


/*  Read nbytes bytes into buf starting at address addr in the text area
 *  of process xp.  The byte count is returned or -1 case of error.
 */
int
ptrace_read_text_from_process(ip, addr, buf, nbytes)
iproc_t *ip;
taddr_t addr;
char *buf;
size_t nbytes;
{
	int pid;

	pid = ip->ip_pid;

	if (pid == 0)
		panic("ao_read_text_from_process with no proc");

#if AO_HAS_PTRACE_RANGE
	if (ptrace(PTRACE_READTEXT, pid, (char *)addr, (int)nbytes, buf) != 0)
		return -1;
	return 0;
#else
	return get_words(pid, PTRACE_PEEKTEXT, addr, buf, nbytes);
#endif
}


/*  Read nbytes of data into buf from process xp, starting at target
 *  address addr.
 *  Return the number of bytes read, or -1 if there was an error.
 *  We never return a short count - the return value is always nbytes or -1.
 */
int
ptrace_read_data(ip, addr, buf, nbytes)
iproc_t *ip;
taddr_t addr;
char *buf;
size_t nbytes;
{
	if (ip->ip_pid == 0)
		return core_dread(ip->ip_core, addr, buf, nbytes) ? 0 : -1;

#ifdef PURIFY
	/*  Purify doesn't know about ptrace ...
	 */
	memset(buf, '\0', nbytes);
#endif
#if AO_HAS_PTRACE_RANGE
	if (ptrace(PTRACE_READDATA, ip->ip_pid, (char *)addr,
							(int)nbytes, buf) == 0)
		return 0;
	else
		return -1;
#else
	return get_words(ip->ip_pid, PTRACE_PEEKDATA, addr, buf, nbytes);
#endif
}


int
ptrace_write_data(ip, addr, buf, nbytes)
iproc_t *ip;
taddr_t addr;
const char *buf;
size_t nbytes;
{
#if AO_HAS_PTRACE_RANGE
	if (ptrace(PTRACE_WRITEDATA, ip->ip_pid, (char *)addr, (int)nbytes,
							(char *)buf) == 0)
		return 0;
	else
		return -1;
#else
	const char *iptr;
	taddr_t lim;
	int word, trailing_nbytes;
	int pid;

	pid = ip->ip_pid;
	iptr = buf;

	/*  Round down the address to a four byte alignment
	 */
	if ((addr & (WORDSIZE - 1)) != 0) {
		taddr_t aligned;
		int offset, count;

		offset = addr & (WORDSIZE - 1);
		aligned = addr - offset;

		errno = 0;
		word = std_ptrace(PTRACE_PEEKDATA, pid, (char *)aligned, 0);
		if (errno != 0)
			return -1;

		count = WORDSIZE - offset;
		if (count > nbytes)
			count = nbytes;
		memcpy((char *)&word + offset, buf,  count);

		errno = 0;
		std_ptrace(PTRACE_POKEDATA, pid, (char *)aligned, word);
		if (errno != 0)
			return -1;

		iptr += count;
		addr += count;
		nbytes -= count;
	}
	/*  At this point addr is on a 32 bit word boundary.
	 */

	trailing_nbytes = nbytes & 03;
	nbytes -= trailing_nbytes;

	lim = addr + nbytes;
	errno = 0;

	/*  Copy the whole words into the buffer.  We still have to use
	 *  memcpy because iptr might not be four byte aligned (in our
	 *  address space) and some machines (e.g. MIPS) would object.
	 */
	while (addr < lim) {
		memcpy((char *)&word, iptr, WORDSIZE);
		std_ptrace(PTRACE_POKEDATA, pid, (char *)addr, word);
		addr += WORDSIZE;
		iptr += WORDSIZE;
	}

	if (trailing_nbytes != 0) {
		word = std_ptrace(PTRACE_PEEKDATA, pid, (char *)addr, 0);
		memcpy((char *)&word, iptr, trailing_nbytes);
		std_ptrace(PTRACE_POKEDATA, pid, (char *)addr, word);
	}

	return errno != 0 ? -1 : 0;
#endif
}


int
ptrace_write_corefile(ip, name)
iproc_t *ip;
const char *name;
{
#if AO_HAS_PTRACE_DUMPCORE
	if (std_ptrace(PTRACE_DUMPCORE, ip->ip_pid, (char *)name, 0) == 0)
		return 0;

	failmesg("Can't dump core file to", "file", name);
	return -1;
#else
	errf("Sorry, this machine/OS does not support core snapshots");
	return -1;
#endif
}


/*  Call ptrace(2), but abort if errno gets set.
 */
int
e_ptrace(req, pid, addr, data)
ptracereq_t req;
int pid;
char *addr;
int data;
{
	int res;

#ifdef ARCH_LINUX386
	if (req == PTRACE_CONT || req == PTRACE_SINGLESTEP) {
		if (addr != (char *) 1) {
			std_ptrace(PTRACE_POKEUSER, pid, 4*EIP, addr);
			addr = (char *) 1;
		}
	}
#endif
	errno = 0;
	res = std_ptrace(req, pid, addr, data);
	if (errno != 0)
		panic("ptrace failed in e_ptrace");
	return res;
}

/*
 *  This routine *MUST* be the last in the file.
 */
#ifdef PTRACE_DEBUG
#undef ptrace

int
ptrace_debug(request, pid, addr, data)
int request, pid, addr, data;
{
	static char *reqnames[] = {
		"TRACEME", "PEEKTEXT", "PEEKDATA", "PEEKUSER", "POKETEXT",
		"POKEDATA", "POKEUSER", "CONT", "KILL", "SINGLESTEP"
	};
	char buf[50], ebeforebuf[20], eafterbuf[20], *reqname, *ebefore, *eafter;
	int errno_before, errno_after, res;
	static bool first_call = TRUE, no_debug;

	if ((Debug_flags & DBFLAG_PTRACE) == 0)
		return ptrace(request, pid, addr, data);

	if (request < 0 || request > 9) {
		sprintf(buf, "<req %d>", request);
		reqname = buf;
	}
	else
		reqname = reqnames[request];

	errno_before = errno;
	res = ptrace(request, pid, addr, data);
	errno_after = errno;
	if (errno_before != 0) {
		sprintf(ebeforebuf, "[errno=%d]", errno_before);
		ebefore = ebeforebuf;
	}
	else
		ebefore = "";

	if (errno_after != 0) {
		sprintf(eafterbuf, "[errno=%d]", errno_after);
		eafter = eafterbuf;
	}
	else
		eafter = "";

	fprintf(stderr, "\tproc %d%s: ptrace(%s, %d, 0x%x, 0x%x)",
							getpid(), ebefore,
							reqname, pid, addr, data);
	if (res != 0 || errno_after != 0)
		fprintf(stderr, " -> 0x%x%s", res, eafter);
	fputc('\n', stderr);

	fflush(stderr);
	
	errno = errno_after;
	return res;
}



#endif /* PTRACE_DEBUG */

#endif /* AO_USE_PTRACE */
