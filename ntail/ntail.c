/*
 * ntail.c:						Feb 1996
 * (schoenfr@gaertner.de)				Jan 1997
 *
 * Ntail is a a tail -f replacement, which takes more than one file to
 * show and optionally filters the datastream by a regexp.
 *
 * This is especially useful to monitor log files with a signle command.
 *
 * use:  ntail [-f] [-F <filter 1>] <file 1> [[-F <filter n>] <file n>] ...
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/time.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

/* our version: */
#define VERSION	"v0.2b Oct 2000"

/* maybe better use FDSETSIZE ? */
#define MAX_FILES	32

#ifdef linux
# define _REGEX_RE_COMP
# include <regex.h>
#endif


/*
 * a job to do:
 */
typedef struct _job {
  char *fname;
  int fd;
  char *filter;
  char *info;			/* show some chars from filename */
} job;

static job all_jobs [MAX_FILES];
static int n_jobs = 0;

/* mask for the select: */
static fd_set mask;
static int n_fd = 0;


/*
 * wassup ?
 */
static void
usage ()
{
  fprintf (stderr, 
	   "use: ntail [-i] [-f] [-F <fil>] file [[-F <fil>] <file>] ...\n");
  fprintf (stderr, "version %s\n", VERSION);
  exit (1);
}


/*
 * create a short name from the filename:
 */
static char *
make_file_info (fname)
     char *fname;
{
  char *buf = strdup (fname);
  char *ptr = strrchr (buf, '/');

  if (! ptr) {
    ptr = fname;
  } else {
    ptr++;
  }

  strncpy (buf, ptr, 3); buf [3] = 0;
  strcat (buf, "-");
  strcat (buf, ptr + strlen (ptr) - 1);
  strcat (buf, ": ");

  return buf;
}


/*
 * add file with filter to the job table:
 */
static void
add_file (fname, filter, file_info)
     char *fname;
     char *filter;
     int file_info;
{
  int fd;

  if (n_jobs >= MAX_FILES) {
    fprintf (stderr, "sorry, max #files reached ... `%s' ignored\n", fname);
    return;
  }

  if ((fd = open (fname, O_RDONLY)) < 0) {
    fprintf (stderr, "cannot open `%s'; ", fname);
    perror ("reason");
  }

  /* seek to end: */
  lseek (fd, 0, SEEK_END);

  all_jobs[n_jobs].fname = fname;
  all_jobs[n_jobs].fd = fd;
  all_jobs[n_jobs].filter = filter;
  if (file_info) {
    all_jobs[n_jobs].info = make_file_info (fname);
  } else {
    all_jobs[n_jobs].info = 0;
  }
  n_jobs++;

  FD_SET(fd, &mask);
#define max(a,b)	a > b ? a : b
  n_fd = max(fd, n_fd);
}


/* 
 * work for this filedescriptor:
 * (return -1 on error)
 */
static int
filter (j)
     job *j;
{
  char buf [4096+1];  /* allow pipe-sized reads + 1 chop character */
  char *ptr;
  int i, rc, len, match;

  /*
   * XXX  The following read & match assumes that chunks are presented
   * at (multiple) line boudaries.  This may not really be the case,
   * causing wrong filter actions.  Skip that problem for now.
   */
  rc = read (j->fd, buf, sizeof(buf)-1);
  if (rc < 0) {
    return rc;
  } else if (! rc) {
    return 0;
  }

  i = 0; ptr = buf;

  while (i < rc) {

    /*
     * At this point:
     *		buf[0 .. rc-1] has data.
     *		buf[0..i-1] has been dealt with
     *		buf[i..rc] needs to be dealt with
     *		buf+i == ptr
     * Goal for the end of every iteration: 
     *		isolate ptr[0..len-1] as current line.
     */
    len = 0; 

    while (i < rc && buf [i] != '\n')
      i++, len++;

    if (i < rc && buf[i] == '\n')
      i++, len++;

    match = 0;

    if (j->filter) {
	char *msg;
	if (ptr[len-1] != '\n')
	    fprintf (stderr, "ntail bug: dubious matching on partial input %s\n",
		     j->info);
	if ((msg = re_comp (j->filter))) {
	    fprintf (stderr, "error in pattern: %s\n", msg);
	    j->filter = 0;
	} else {
	    /*
	     * The GNU rx derived re_exec can be a bit eager and match
	     * beyond the first \n.  This hoses the printing of the current
	     * fragment if the filter matches within the *trailing* data.
	     * We chop off the fragment temporarily to avoid this.
	     */
	    char char_after_this_line = ptr[len];
	    ptr[len]='\0';

	    if ((match = re_exec (ptr)) == -1) {
		fprintf (stderr, "error in re_exec; patter %s\n", j->filter);
		match = 0;
	    }
	    ptr[len]=char_after_this_line;  /* unchop the fragment */
	}
    } else {
      match = 0;
    }
    
    if(! match) {
      if (j->info) {
	write (fileno(stdout), j->info, strlen(j->info));
      }
      write (fileno(stdout), ptr, len);
    }

    ptr += len;
  }
  return 0;
}


/*
 * monitor the files: 
 */
static void
doit (follow)
     int follow;
{
  struct timeval tv;
  fd_set m;
  job *j;
  int rc, i;

  while (follow) {

    tv.tv_sec = 0;
    tv.tv_usec = 0;
    
    m = mask;
    
    rc = select (n_fd + 1, &m, (fd_set *) 0, (fd_set *) 0, &tv);
    if (rc < 0) {
      perror ("select failed; reason");
      return;
    } else if (! rc) {
      return;
    }
    
    for (j = all_jobs, i = 0; i < n_jobs; i++, j++) {
      if (FD_ISSET(j->fd, &m)) {
	if (filter (j) < 0) {
	  fprintf (stderr, "oerg ? fd %d (`%s') excluded\n",
		   j->fd, j->fname);
	  FD_CLR(j->fd, &mask);
	}
      }
    }
    if (follow)
      sleep (1);
  }
}


/*
 * M A I N:
 */
int
main (argc, argv)
     int argc;
     char *argv[];
{
  int follow = 0;			/* -f option */
  int file_info = 0;			/* -i option */
  char *f_arg = 0;			/* -F seen */

  FD_ZERO (&mask);
  
  while (++argv, --argc > 0) {
    if (! strcmp (*argv, "-f")) {
      follow = 1;
    } else if (! strcmp (*argv, "-i")) {
      file_info = 1;
    } else if (argc > 1 && ! strcmp (*argv, "-F")) {
      ++argv, --argc;
      f_arg = *argv;
    } else if (**argv != '-') {
      add_file (*argv, f_arg, file_info);
      f_arg = 0;
    } else {
      usage ();
    }
  }

  if (! n_jobs) {
    usage ();
  }
  
  doit (follow);

  return 0;
}

/* end of ntail.c */
