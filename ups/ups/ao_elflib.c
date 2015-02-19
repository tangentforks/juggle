/* ao_elflib.c - ELF shared library support */

/*  Copyright 1995 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ups_ao_elflib_c_sccsid[] = "@(#)ao_elflib.c	1.1 24/5/95 (UKC)";

#include <mtrprog/ifdefs.h>
#include "ao_ifdefs.h"
	
#ifdef AO_ELF

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>                /* for MAXPATHLEN */
#include <elf.h>
#define FREEBSD_ELF 1
#include <link.h>
#undef FREEBSD_ELF
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <local/ukcprog.h>
#include <mtrprog/utils.h>
#include <local/wn.h>
#include <mtrprog/io.h>

#include "ups.h"
#include "symtab.h"
#include "target.h"
#include "st.h"
#include "ao_syms.h"
#include "ao_core.h"
#include "ao_target.h"
#include "ao_elfpriv.h"
#include "ao_elfread.h"
#include "ao_elflib.h"
#include "ao_elfsym.h"
#include "ao_symscan.h"
#include "breakpoint.h"
#include "data.h"		/* RGA for dread & dgets */
#include "state.h"
#include "obj_bpt.h"

struct Solib_addr {
	dev_t dev;
	ino_t ino;
        off_t size;		/* RGA added for Clearcase */
#ifdef OS_SUNOS
        long mtv_sec;		/* RGA added for Clearcase */
        long mtv_nsec;		/* RGA added for Clearcase */
#endif
	off_t offset;
	taddr_t vaddr;
	size_t pagesize;
	Solib_addr *next;
};

struct Solib {
	symtab_t *symtab;
	
	const char *soname;
	const char *rpath;
	
	taddr_t min_file_vaddr;
	taddr_t debug_vaddr;
	
	dev_t dev;
	ino_t ino;
        off_t size;		/* RGA added for Clearcase */
#ifdef OS_SUNOS
        long mtv_sec;		/* RGA added for Clearcase */
        long mtv_nsec;		/* RGA added for Clearcase */
        bool mvfs_file;		/* RGA added for Clearcase */
#endif
	
	Libdep *latest_libdep;

	bool is_last_symtab;
	Solib *next;
};

struct Libdep {
	const char *name;
	const char *name_only;
	Solib *so;
	Libdep *par;
	Libdep *deps;
	Libdep *next;
	long mtime;		/* RGA */
	bool emitted_noload_msg; /* RGA so verbose messages not repeated*/
	bool no_reload; /* RGA set when scan_elf_symtab() fails */
	bool wants_load; /* RGA set by user_wants_library_loaded() */
};

static Libdep *next_ld PROTO((Libdep *cur));
static bool
elf_get_dynamic_shlib_info PROTO((alloc_pool_t *ap, Libdep *ld, const char *textpath,
			   taddr_t debug_vaddr,
			   Libdep **last_child));

#ifdef AO_USE_PTRACE /* interp */
static bool
get_preload_shlib_list PROTO((alloc_pool_t *ap, const char *textpath,
			Solib **p_solibs, Solib_addr **p_solib_addrs));
static const char **
add_to_env PROTO((const char *s));
#endif

static unsigned long Main_debug_vaddr = 0;

static void
dump_libdep(Libdep *par, int level)
{
	Libdep *ld;
	
	printf("%*s%p: %s", level * 8, "", par, par->name);

	if (par->so != NULL)
		printf(" so=%s", par->so->symtab->st_path);

	fputc('\n', stdout);

	for (ld = par->deps; ld != NULL; ld = ld->next)
		dump_libdep(ld, level + 1);
}

void
dump_elf_libs(target_t *xp)
{
	Solib *so;
	iproc_t *ip;

	ip = GET_IPROC(xp);

	for (so = ip->ip_solibs; so != NULL; so = so->next) {
		printf("%s: soname=%s latest_libdep=%p\n",
		       so->symtab->st_path,
		       (so->soname != NULL) ? so->soname : "NULL",
		       so->latest_libdep);
	}

	fputc('\n', stdout);
	
	dump_libdep(ip->ip_solibs->latest_libdep, 0);
}

static Libdep *
make_libdep(alloc_pool_t *ap, const char *name, Libdep *par, long mtime)
{
	Libdep *ld;
	const char *c;

	ld = (Libdep *)alloc(ap, sizeof(Libdep));
	ld->name = name;
	if (name)
	{
	  if ((c = strrchr (name, '/')) != NULL)
	    c++;
	  else
	    c = name;
	  ld->name_only = c;
	}
	else
	  ld->name_only = name;
	ld->so = NULL;
	ld->par = par;
	ld->deps = NULL;
	ld->next = NULL;
	ld->mtime = mtime;
	ld->emitted_noload_msg = FALSE;
	ld->no_reload = FALSE;
	ld->wants_load = user_wants_library_loaded((char *)name);
	
	return ld;
}

static bool
search_lib_path(const char *dirs, const char *seps, const char *name,
		char **p_path)
{
	char **dirvec, **dp;

	if (dirs == NULL)
		return FALSE;
	
	dirvec = ssplit(dirs, seps);

	for (dp = dirvec; *dp != NULL; ++dp) {
		char *path;
		
		path = strf("%s/%s", *dp, name);

		if (access(path, F_OK) == 0) {
			*p_path = path;
			free(dirvec);
			return TRUE;
		}

		free(path);
	}

	free(dirvec);
	return FALSE;
}

/*  Apply the rules on page 5-20 of the System V ABI book to find the
 *  path (relative or absolute) of the shared library.
 *
 *  Latest ld.so man page (Linux) says
 *  1) $LD_LIBRARY_PATH
 *  2) /etc/ld/so.cache  (this is binary)
 *  3) /usr/lib:/lib
 */
static char *
get_ld_path(Libdep *ld)
{
	char *path, *ptr;
	
	if (strchr(ld->name, '/') != NULL)
		return strsave(ld->name);

	if (search_lib_path(ld->par->so->rpath, ":", ld->name, &path))
		return path;
	if ((ptr = getenv ("LD_LIBRARY_PATH")) != NULL) {
		if (search_lib_path (ptr, ":;", ld->name, &path))
			return path;
	}
	if (search_lib_path ("/usr/lib:/lib", ":", ld->name, &path))
		return path;

	return strf("/usr/lib/%s", ld->name);
}

static void
set_base_address(Solib *so, off_t offset, taddr_t vaddr, size_t pagesize)
{
	taddr_t base_address;

	if (pagesize == 0) {
		base_address = vaddr;
	}
	else {
		taddr_t min_mem_vaddr, pagemask;
		
		pagemask = ~(pagesize - 1);
		
		min_mem_vaddr = (vaddr - offset) & pagemask;
		base_address = (min_mem_vaddr & pagemask) -
			(so->min_file_vaddr & pagemask);
	}
		
	change_base_address(so->symtab, base_address);
}

static bool
load_elf_shlib(target_t *xp, Libdep *ld)
{
	iproc_t *ip;
	char *path;
	int fd = 0, reload = 0;
	bool ok;
	Solib *so;
	long mtime = 0;
	struct stat stbuf;
	static int verbose = -1;

	ip = GET_IPROC(xp);

	if (ld->no_reload == TRUE)
	  return TRUE;
  
	if (verbose == -1)
	{
	  verbose = getenv("VERBOSE") != NULL;
	  if (verbose && !strcmp(getenv("VERBOSE"), "NOLOAD"))
	    verbose = 2;
	}
	path = get_ld_path(ld);

	for (so = ip->ip_solibs; so != NULL; so = so->next) {
	  if (!so->symtab->st_eclipsed &&
	      strcmp(so->symtab->st_path, path) == 0) {
	    ld->so = so;
	    so->latest_libdep = ld;
	    
	    /*  We leave ld->deps as NULL, as they will
	     *  always be visited first under the earlier
	     *  instance of the symbol table.
	     */
	    if (ld->wants_load == TRUE)
	    {
	      ok = open_for_reading(path, "shared library", &fd);
	      if (ok)
	      {
		if (fstat(fd, &stbuf) == 0)
		  mtime = stbuf.st_mtime;
		close(fd);
		if (mtime == so->symtab->st_modtime)
		{
		  free(path);
		  return TRUE;
		}
		else
		{
		  so->symtab->st_eclipsed = 1;
		  reload = 1;
		  break;
		}
	      }
	    }
	    free(path);
	    return TRUE;
	  }
	}

	if (ld->wants_load == FALSE)
	{
	  if (verbose && get_message_wn() == -1)
	    if (ld->emitted_noload_msg == FALSE)
	    {
	      ld->emitted_noload_msg = TRUE;
	      fprintf(stderr, "NOT loading symtab %s\n", path);
	    }
	  ok = FALSE;
	}
	else
	{
	  ok = (open_for_reading(path, "shared library", &fd) &&
		check_elf_file_type(fd, path, ET_DYN, "load symbols from"));
	  if (ok)
	  {
	    int wn = get_message_wn();

	    if (fstat(fd, &stbuf) == 0)
	      mtime = stbuf.st_mtime;
	    if (wn != -1)
	    {
	      wn_updating_off(wn);
	      errf("\b%s symtab %s...", reload ? "Reloading" :
		   "Loading", path);
	      wn_updating_on(wn);
	    }
	    if (verbose == 1)
	      fprintf(stderr, "%s symtab %s...", reload ? "Reloading" :
		      "Loading", path);
	    ok = scan_elf_symtab(xp->xp_apool, path, fd, ld, (func_t **)NULL,
				 (func_t **)NULL, &ip->ip_solibs);
	    if (xp->xp_hit_solib_event == TRUE)
	      xp->xp_new_dynamic_libs_loaded = TRUE;
	    if (wn != -1)
	    {
	      wn_updating_off(wn);
	      errf("\b%s symtab %s...done", reload ? "Reloading" :
		     "Loading", path);
	      wn_updating_on(wn);
	    }
	    if (verbose == 1)
		fputs("done\n", stderr);
	  }
	}

	free(path);

	if (ok) {
		Solib_addr *sa;
		
		so = ld->so;
		
		so->symtab->st_modtime = stbuf.st_mtime;

		/*  TODO: should pass load address to scan_elf_symtab().
		 */
		for (sa = ip->ip_solib_addrs; sa != NULL; sa = sa->next) {
		  if (sa->dev == so->dev && sa->ino == so->ino)
		    break;
		  }

#ifdef OS_SUNOS
		/* RGA if solib was a mvfs file (e.g. Rational Clearcase), */
		/* procfs file may point to a nfs equivalent, so use the */
		/* st_size, mtv_sec and mtv_nsec fields to match */
		
		if (sa == NULL)
		  for (sa = ip->ip_solib_addrs; sa != NULL; sa = sa->next) {
		    if (sa->size == so->size && sa->mtv_sec == so->mtv_sec &&
			sa->mtv_nsec == so->mtv_nsec)
		      break;
		  }
#endif	    
		if (sa != NULL) {
		  set_base_address(so,
				   sa->offset, sa->vaddr, sa->pagesize);
		}
				
	}
	else
	{
	  ld->no_reload = TRUE;
	  if (fd)
	    close(fd);
	}

	return ok;
}

void
elf_zap_solib_addrs(xp)
target_t *xp;
{
	Solib_addr *sa, *next;
	iproc_t *ip;

	ip = GET_IPROC(xp);
	
	for (sa = ip->ip_solib_addrs; sa != NULL; sa = next) {
		next = sa->next;
		free(sa);
	}

	ip->ip_solib_addrs = NULL;
}

bool
elf_get_dynamic_solibs(alloc_pool_t *target_ap, const char *path,
		       Solib **p_solibs, bool check_only)
{
    Libdep *ld, first_child, *last_child, *ld1, *ld2;
    int same;

    if (Main_debug_vaddr != 0)
    {
	ld = make_libdep(target_ap, path, (Libdep *)NULL, 0);
	last_child = &first_child;
	elf_get_dynamic_shlib_info (target_ap, ld, path, Main_debug_vaddr,
				    &last_child);
	last_child->next = NULL;
	ld->deps = first_child.next;
	for (same = 1, ld1 = (*p_solibs)->latest_libdep->deps, ld2 = ld->deps;
		 ld1 && ld2; ld1 = ld1->next, ld2 = ld2->next)
	    if ((strcmp(ld1->name_only, ld2->name_only)  && ld2->wants_load == TRUE) ||
		  (ld1->wants_load == FALSE && ld2->wants_load == TRUE))
	    {
		/* RGA was noload before, now is not, after init file rescan */
		same = 0;
		break;
	    }
	if (same == 0 || ld2) /* New list is longer */
	{
	    if (!check_only)
		(*p_solibs)->latest_libdep->deps = ld->deps; /* RGA is this right? */
	    return TRUE;
	}
    }
    return FALSE;
}

bool
elf_note_shlib_addr(iproc_t *ip, dev_t dev, ino_t ino, 
		    off_t size, long mtv_sec,  long mtv_nsec, 
		    off_t offset, taddr_t vaddr, size_t pagesize)
{
	Solib *so;
	
	for (so = ip->ip_solibs; so != NULL; so = so->next) {
		if (so->dev == dev && so->ino == ino)
			break;
	}

#ifdef OS_SUNOS
	/* RGA if solib was a mvfs file (e.g. Rational Clearcase), */
	/* procfs file may point to a nfs equivalent, so use the */
	/* st_size, mtv_sec and mtv_nsec fields to match */

	if (so == NULL)
	  for (so = ip->ip_solibs; so != NULL; so = so->next) {
	    if (so->mvfs_file == TRUE && so->size == size &&
		so->mtv_sec == mtv_sec && so->mtv_nsec == mtv_nsec)
	      break;
	}
#endif	    
	if (so != NULL) {
		set_base_address(so, offset, vaddr, pagesize);
	}
	else {
		Solib_addr *sa;
		
		sa = e_malloc(sizeof(Solib_addr));
		sa->dev = dev;
		sa->ino = ino;
		sa->size = size;
#ifdef OS_SUNOS
		sa->mtv_sec = mtv_sec;
		sa->mtv_nsec = mtv_nsec;
#endif
		sa->offset = offset;
		sa->vaddr = vaddr;
		sa->pagesize = pagesize;
		sa->next = ip->ip_solib_addrs;
		ip->ip_solib_addrs = sa;
	}
	
	return TRUE;
}

bool
elf_get_core_shlib_info(alloc_pool_t *ap, iproc_t *ip)
{
	struct r_debug debug;
	Solib *so;
	const char *path;
	taddr_t dbaddr, lmaddr;
	Coredesc *co;
	struct link_map lmap;
	
	so = ip->ip_solibs;
	co = ip->ip_core;
	path = so->symtab->st_path;

	if (so->debug_vaddr == 0) {
		errf("No DT_DEBUG entry in .dynamic section of %s", path);
		return FALSE;
	}

	if (!core_dread(co, so->debug_vaddr, &dbaddr, sizeof(dbaddr)) ||
	    !core_dread(co, dbaddr, (char *)&debug, sizeof(debug))) {
		errf("Can't read r_debug structure from %s", path);
		return FALSE;
	}

	for (lmaddr = (taddr_t)debug.r_map;
	     lmaddr != TADDR_NULL;
	     lmaddr = (taddr_t)lmap.l_next) {
		char libpath[1024]; /* TODO: use MAXPATHLEN or similar */
		struct stat stbuf;

		if (!core_dread(co, lmaddr, &lmap, sizeof(lmap))) {
			errf("Error reading lmap at address %lx in %s",
			     lmaddr, path);
			return FALSE;
		}
		/*  Skip the first entry - it refers to the executable file
		 *  rather than a shared library.
		 */
		if (lmap.l_prev == NULL)
			continue;
#if HAVE_L_PHNUM_F
		if (lmap.l_phnum == 0) {
			errf("Ignoring lmap at address %lx in %s",
			     lmaddr, path);
			continue;
		}
#endif
		if (!core_readstr(co, (taddr_t)lmap.l_name,
				  libpath, sizeof(libpath))) {
			errf("Error reading lmap.l_name at address %lx in %s",
			     lmap.l_name, path);
			return FALSE;
		}

		if (stat(libpath, &stbuf) != 0) {
			errf("Can't stat shared library %s: %s (ignored)",
			     libpath, get_errno_str());
			continue;
		}

		elf_note_shlib_addr(ip, stbuf.st_dev, stbuf.st_ino,
				    0, 0, 0,
				    0, (taddr_t)lmap.l_addr, 0);
		/* Here libpath is a full path, when we first got the
		   shared library details we just got a name. */
		/* Possibly not necessary as library should be findable
		   by 'get_ld_path()' anyway. */
		if (*libpath == '/') {
			char *ptr;
			Libdep *ld;
			ptr = strrchr (libpath, '/') + 1;
			for (ld = next_ld(so->latest_libdep);
			     ld != NULL;
			     ld = next_ld(ld)) {
				if (strcmp (ld->name, ptr) == 0) {
					ld->name = strsave(libpath);
					break;
				}
			}
		}
	}

	return TRUE;
}

static bool
elf_get_dynamic_shlib_info(alloc_pool_t *ap, Libdep *ld, const char *textpath,
			   taddr_t debug_vaddr,
			   Libdep **last_child)
{
	struct r_debug debug;
	const char *path = "DT_DEBUG";
	const char *libpath_copy;
	taddr_t dbaddr, lmaddr;
	struct link_map lmap;
	target_t *xp;
	iproc_t *ip;
	breakpoint_t *bp;
	static bool dl_bp_installed = FALSE;

	xp = get_current_target();

	ip = GET_IPROC(xp);
	if (debug_vaddr == 0) {
		errf("No DT_DEBUG entry in .dynamic section of %s", path);
		return FALSE;
	}

	if (dread(xp, debug_vaddr, &dbaddr, sizeof(taddr_t)) == -1 ||
	    dread(xp, dbaddr, (char *)&debug, sizeof(struct r_debug)) == -1) {
	  errf("Can't read r_debug structure from %s", path);
	  return FALSE;
	}

	if (debug.r_brk && dl_bp_installed == FALSE)
	{
	  bp = xp_add_breakpoint(xp, (taddr_t)debug.r_brk);
	  if (install_breakpoint(bp, xp) != 0)
	    errf("can't install breakpoint in dynamic linker");
	  else
	  {
	    dl_bp_installed = TRUE;
	    set_breakpoint_as_solib_event(bp);
	  }
	}
	  
	for (lmaddr = (taddr_t)debug.r_map;
	     lmaddr != TADDR_NULL;
	     lmaddr = (taddr_t)lmap.l_next) {
		char libpath[MAXPATHLEN], buf[MAXPATHLEN], *path_ptr; 
		struct stat stbuf;

		if (dread(xp, lmaddr, &lmap, sizeof(struct link_map)) == -1)
		{
		  errf("Error reading lmap at address %lx in %s",
		       lmaddr, path);
		  return FALSE;
		}
		if (lmaddr == (taddr_t)lmap.l_next) /* break possible */
						   /* infinite loop */
		  break;

		/*  Skip the first entry - it refers to the executable file
		 *  rather than a shared library.
		 */
		if (lmap.l_prev == NULL || !lmap.l_name)
		  continue;
		
		if (dgets(xp, (taddr_t)lmap.l_name,
			  libpath, MAXPATHLEN-1) == -1)
		{
		  errf("Error reading lmap name %lx in %s",
		       lmap.l_name, path);
		  return FALSE;
		}
		
		if (libpath[0] == '.')
		{
		  int i;
		  char name[MAXPATHLEN];

		  strcpy(buf, libpath);
		  for(i = strlen(textpath) - 1;
		      i >= 0 && textpath[i] != '/'; i--);
		  i++;
		  if (i > 0)
		  {
		    strcpy(name, buf);
		    strncpy(buf, textpath, i);
		    buf[i] = 0;
		    strcat(buf, name);
		  }
		  path_ptr = buf;
		}
		else
		  path_ptr = libpath;

		if (stat(path_ptr, &stbuf) != 0) {
		  errf("Can't stat shared library %s: %s (ignored)",
		       path_ptr, get_errno_str());
		  continue;
		}

		libpath_copy = alloc_strdup(ap, path_ptr);
		(*last_child)->next = make_libdep(ap, libpath_copy, ld,
						  stbuf.st_mtime);
		(*last_child) = (*last_child)->next;

#ifdef AO_USE_PTRACE
		elf_note_shlib_addr(ip,
				    stbuf.st_dev, stbuf.st_ino,
				    stbuf.st_size,
				    0, 0,
				    0, (taddr_t)lmap.l_addr, 0);
#endif
	      }
	return TRUE;
}

bool
scan_main_elf_symtab(alloc_pool_t *target_ap, const char *path, int fd,
		     long modtime, Solib **p_solibs, Solib_addr **p_solib_addrs,
		     struct func_s **p_mainfunc, struct func_s **p_initfunc)
{
	Libdep *ld;
	bool ok;

	*p_solibs = NULL;
	ld = make_libdep(target_ap, path, (Libdep *)NULL, 0);
	ok = scan_elf_symtab(target_ap, path, fd, ld,
			       p_mainfunc, p_initfunc, p_solibs);
	if (ld->so)
	{
	  ld->so->symtab->st_modtime = modtime;
#ifdef AO_USE_PTRACE /* interp */
	  if (!get_preload_shlib_list (target_ap, path, p_solibs, p_solib_addrs))
	    return FALSE;
#endif
	  Main_debug_vaddr = ld->so->debug_vaddr;
	}
	return ok;
}

static Libdep *
find_first_descendent(Libdep *par, int level)
{
	Libdep *ld;

	if (par == NULL)
		return NULL;
	
	if (level == 0)
		return par->deps;

	for (ld = par->deps; ld != NULL; ld = ld->next) {
		Libdep *res;

		res = find_first_descendent(ld, level - 1);

		if (res != NULL)
			return res;
	}

	return NULL;
}

static Libdep *
next_ld(Libdep *cur)
{
	Libdep *ld;
	int level;

	if (cur->next != NULL)
		return cur->next;

	if (cur->par == NULL)
		return cur->deps;

	level = 0;
	for (ld = cur->par; ld != NULL; ld = ld->par) {
		Libdep *res;
		
		res = find_first_descendent(ld->next, level);

		if (res != NULL)
			return res;
		
		++level;
	}

	return find_first_descendent(cur->par, 1);
}

bool
elf_next_symtab(target_t *xp, symtab_t *st, bool load_new, symtab_t **p_next_st)
{
	Solib *so;
	Libdep *ld;
	
	if (st == NULL) {
		*p_next_st = GET_IPROC(xp)->ip_solibs->symtab;

		if (!(*p_next_st)->st_eclipsed)
		  return TRUE;
	}

	so = AO_STDATA(st)->st_solib;

	/* RGA 07/18/00 add a check so the extensive lookup is done
	   only when the dynamic linker breakpoint has been set */
	if (xp->xp_hit_solib_event == FALSE)
	{
	  if (so->next != NULL) {	 
	    *p_next_st = so->next->symtab;
	    return TRUE;
	  }
	  
	  if (!load_new || so->is_last_symtab) 
	    return FALSE;
	}

	for (ld = next_ld(so->latest_libdep); ld != NULL; ld = next_ld(ld)) {
		if (!load_elf_shlib(xp, ld))
			continue;

		if (so->next != NULL) {
			/*  Loaded a new symbol table.
			 */
			*p_next_st = so->next->symtab;
			if (!(*p_next_st)->st_eclipsed)
			  return TRUE;
		}
	}
	while (so->next != NULL) {
	  if (!so->next->symtab->st_eclipsed) {
	    *p_next_st = so->next->symtab;
	    return TRUE;
	  }
	  else
	    so = so->next;
	}
	
	so->is_last_symtab = TRUE;
	return FALSE;
}

static bool
get_elf_shlib_info(alloc_pool_t *ap, Elfinfo *el,
		   const char **p_soname, const char **p_rpath,
		   taddr_t *p_debug_vaddr)
{
	Elf32_Shdr *dynsh, *strsh;
	Elf32_Dyn *dyntab;
	int i, count;
	char *strings;
	Libdep first_child, *last_child;

	if (!elf_find_section(el, ".dynamic", "shared library information",
			      &dynsh))
		return FALSE;
	
	if (!check_elf_entsize(dynsh, ".dynamic", sizeof(Elf32_Dyn)))
		return FALSE;
	count = dynsh->sh_size / sizeof(Elf32_Dyn);
	
	if (dynsh->sh_link >= el->num_sections) {
		errf("String table index (%ld) for .dynamic section "
		     "not in range 0..%d in %s %s",
		     dynsh->sh_link, el->num_sections - 1, el->what, el->path);
		return FALSE;
	}
	
	strsh = &el->sections[dynsh->sh_link];
	
	dyntab = e_malloc(dynsh->sh_size);
	strings = e_malloc(strsh->sh_size);

	if (!read_elf_section(el, ".dynamic section", dynsh, dyntab) ||
	    !read_elf_section(el, ".dynamic section strings", strsh, strings)) {
		free(dyntab);
		free(strings);
		return FALSE;
	}

	last_child = &first_child;

	*p_soname = *p_rpath = NULL;
	*p_debug_vaddr = 0;
	
	for (i = 0; i < count; ++i) {
		Elf32_Dyn *d;
		const char **p_str, *depname;
		off_t offset;

		d = &dyntab[i];
		
		switch (d->d_tag) {
		case DT_SONAME:
			p_str = p_soname;
			break;
		case DT_RPATH:
			p_str = p_rpath;
			break;
		case DT_NEEDED:
			p_str = &depname;
			break;
		case DT_DEBUG:
			*p_debug_vaddr = dynsh->sh_addr +
				((char *)&d->d_un.d_ptr - (char *)dyntab);
			continue;
		default:
			continue;
		}

		offset = d->d_un.d_val;

		if (offset >= strsh->sh_size) {
			errf("\bString offset for .dynamic entry %d in %s %s "
			     "not in range 0..%ld - ignored",
			     i, el->what, el->path, strsh->sh_size - 1);
			continue;
		}
		
		*p_str = alloc_strdup(ap, &strings[offset]);

		if (d->d_tag == DT_NEEDED) {
			last_child->next = make_libdep(ap, depname, el->libdep,
						       0);
			last_child = last_child->next;
		}
	}

	free(dyntab);
	free(strings);

	last_child->next = NULL;
	el->libdep->deps = first_child.next;
	
	return i == count;
}

bool
add_solib_entry(alloc_pool_t *ap, symtab_t *st, Elfinfo *el, Solib **p_solibs)
{
	Solib *so, *so2, *last;
	const char *soname, *rpath;
	ao_stdata_t *ast;
	taddr_t debug_vaddr;
	struct stat stbuf;
	
	ast = AO_STDATA(st);
	
	if (fstat(ast->st_textfd, &stbuf) != 0) {
		errf("Can't fstat %s (fd=%d): %s",
		     st->st_path, ast->st_textfd, get_errno_str());
		return FALSE;
	}

	if (!get_elf_shlib_info(ap, el, &soname, &rpath, &debug_vaddr))
	{
	  /* RGA completely statically linked targets used to return
	     FALSE at this point, terminiating the debug seesion.
	     Changed to continue with null data.
	     */
	  soname = 0;
	  rpath = "";
	  debug_vaddr = 0;
	}

	so = alloc(ap, sizeof(Solib));
	so->symtab = st;
	so->soname = soname;
	so->rpath = rpath;
	so->min_file_vaddr = el->min_file_vaddr;
	so->debug_vaddr = debug_vaddr;
	so->dev = stbuf.st_dev;
	so->ino = stbuf.st_ino;
	so->size = stbuf.st_size;
#ifdef OS_SUNOS
	so->mtv_sec = stbuf.st_mtim.tv_sec;
	so->mtv_nsec = stbuf.st_mtim.tv_nsec;
	if (stbuf.st_fstype && !strcmp(stbuf.st_fstype, "mvfs"))
	  so->mvfs_file = TRUE;
	else
	  so->mvfs_file = FALSE;
#endif
	so->latest_libdep = el->libdep;
	so->is_last_symtab = FALSE;
	so->next = NULL;

	ast->st_solib = so;

	last = NULL;
	for (so2 = *p_solibs; so2 != NULL; so2 = so2->next)
		last = so2;

	if (last != NULL)
		last->next = so;
	else
		*p_solibs = so;

	el->libdep->so = so;

	return TRUE;
}

int
elf_save_symtab_breakpoints(xp, remove_bpts)
target_t *xp;
bool remove_bpts;
{
	FILE *fp;
	iproc_t *ip;
	
	ip = GET_IPROC(xp);
	if (!ip->ip_solibs)
	  return 0;

	if ((fp = fopen(get_temp_bpt_filename(), "w")) == NULL)
	{
	  errf("Can't create temp saved breakpoints file `%s'",
	       get_temp_bpt_filename());
	  return 0;
	}
	save_all_breakpoints((char *)fp);
	if (remove_bpts == TRUE)
	  remove_all_breakpoints();
	fclose(fp);
	return 1;
}

void
elf_restore_symtab_breakpoints()
{
  restore_cached_bpts();
}

void
unload_shared_library_symtabs(xp)
target_t *xp;
{
    /* Just to satisfy a link reference. */
}

void
elf_rescan_dynamic_solibs(xp)
target_t *xp;
{
#ifdef AO_ELF
  iproc_t *ip;
  
  ip = GET_IPROC(xp);
  if (ip->ip_pid)
    xp->xp_new_dynamic_libs = 
      elf_get_dynamic_solibs(xp->xp_apool, xp->xp_textpath,
			     &ip->ip_solibs, FALSE);
#endif
}

#ifdef AO_USE_PTRACE /* interp */
/*  Get the list of shared libraries that the textpath will load
 *  when it is run.  We do this in the same way as ldd(1), by
 *  running the target with LD_TRACE_LOADED_OBJECTS set in its
 *  environment and parsing the output.
 *
 *  (IDE) taken out of ao_shlib.c - FreeBSD/Linux sometimes need the
 *  correct addresses of functions *before* the target has been started,
 *  e.g. interpreted code at breakpoints calling library functions.
 *  All we do here is create the 'Solib_addr' structures for later code
 *  to pick up.
 */
static bool
get_preload_shlib_list(ap, textpath, p_solibs, p_solib_addrs)
alloc_pool_t *ap;
const char *textpath;
Solib **p_solibs;
Solib_addr **p_solib_addrs;
{
    int pid, wpid, n;
    int fds[2];
    char buf[MAXPATHLEN+256], name[MAXPATHLEN];
    char *pos, *libpath_copy;
    const char **envp;
    FILE *fp;
    taddr_t addr;
    struct stat stbuf;
    Solib_addr *sa;
/*
    Libdep first_child, *last_child;
    last_child = &first_child;
*/

    envp = add_to_env("LD_TRACE_LOADED_OBJECTS=1");
    if (pipe(fds) != 0) {
	    errf("Pipe failed: %s", get_errno_str());
	    free((char *)envp);
	    return FALSE;
    }
    if ((fp = fdopen(fds[0], "r")) == NULL) {
	    errf("Fdopen failed: %s", get_errno_str());
	    free((char *)envp);
	    return FALSE;
    }
    if ((pid = vfork()) == -1) {
	    errf("Vfork failed: %s", get_errno_str());
	    fclose(fp);
	    close(fds[1]);
	    free((char *)envp);
	    return FALSE;
    }
    if (pid == 0) {
	    close(fds[0]);
	    if (fds[1] != 1)
		    dup2(fds[1], 1);
	    execle(textpath, textpath, (char *)NULL, envp);
	    failmesg("Can't exec", "", textpath);
	    _exit(1);
    }

    free((char *)envp);
    close(fds[1]);

    while (fgets(buf, sizeof(buf), fp) != NULL)
    {
	/*  We seem to get carriage returns as well as newlines
	 */
	if ((pos = strchr(buf, '\r')) != NULL)
		*pos = '\0';
	if ((pos = strchr(buf, '\n')) != NULL)
		*pos = '\0';
	pos = buf;
	addr = 0;
	if ((sscanf(buf, "%*s => %s (%x)", name, &addr) == 2)
		|| (sscanf(buf, "%*s => %s", name) == 1))
	{
	    if (stat(name, &stbuf) != 0)
	    {
		errf("Can't stat shared library %s: %s (ignored)",
		     name, get_errno_str());
		continue;
	    }
/*
	    libpath_copy = alloc_strdup(ap, name);
	    last_child->next = make_libdep(ap, libpath_copy, (Libdep *)NULL,
					      stbuf.st_mtime);
	    last_child = last_child->next;
*/
	    sa = e_malloc(sizeof(Solib_addr));
	    sa->dev = stbuf.st_dev;
	    sa->ino = stbuf.st_ino;
	    sa->size = stbuf.st_size;
#ifdef OS_SUNOS
	    sa->mtv_sec = stbuf.mtv_sec;
	    sa->mtv_nsec = stbuf.mtv_nsec;
#endif
	    sa->offset = 0;
	    sa->vaddr = addr;
	    sa->pagesize = 0;
	    sa->next = *p_solib_addrs;
	    *p_solib_addrs = sa;
	}
    }
    fclose(fp);
    while ((wpid = wait((int *)NULL)) != pid && wpid != -1)
	    ;
/*
    last_child->next = NULL;
*/
    return TRUE;
}

/*  Return a pointer to an array of strings which consists of the
 *  environment plus string s, which should be of the form
 *  "name=value".
 */
static const char **
add_to_env(s)
const char *s;
{
	extern const char **environ;
	const char **sptr, **envp, **src, **dst;

	for (sptr = environ; *sptr != NULL; ++sptr)
		;
	envp = dst = (const char **)e_malloc(sizeof(char *) * (sptr - environ + 2));
	src = environ;
	while (*src != NULL)
		*dst++ = *src++;
	*dst++ = s;
	*dst = NULL;
	return envp;
}
#endif

#endif /* AO_ELF */
