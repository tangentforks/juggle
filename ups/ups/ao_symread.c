/* ao_symread.c - buffered reading of symbols from an a.out file */

/*  Copyright 1993 Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ups_ao_symread_c_sccsid[] = "@(#)ao_symread.c	1.4 04 Jun 1995 (UKC)";

#include <mtrprog/ifdefs.h>
#include "ao_ifdefs.h"

#ifdef AO_TARGET

#include <sys/types.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#ifndef AO_ELF
#include <a.out.h>
#endif
#include <errno.h>

#ifdef __STDC__
#include <unistd.h>
#endif

#ifndef L_SET
#define L_SET 0
#endif

#include <local/ukcprog.h>
#include <mtrprog/strcache.h>
#include <mtrprog/utils.h>

#include "ups.h"
#include "symtab.h"
#ifdef ARCH_MIPS
#include "mips_frame.h"
#endif
#ifdef AO_ELF
#include "elfstab.h"
#endif
#include "target.h"
#include "st.h"
#include "ao_syms.h"
#include "ao_symread.h"

#ifdef ARCH_VAX
#define N_TXTADDR(x)	0
#endif

#ifdef ARCH_CLIPPER
#ifndef N_TXTADDR
#define N_TXTADDR(x)	0x8000
#endif
#endif


#define STRPAGESIZE	256

/*  This used to be `typedef const char *strpage_t[STRPAGESIZE]', but this
 *  triggers a bug in SC 2.0.1.
 */
typedef struct {
	const char *str[STRPAGESIZE];
} strpage_t;

#ifdef COFF_SUN386
#define DBX_TYPE(n) (((n)->n_leading_zero == 0 && (n)->n_dbx_type != 0) \
					? (n)->n_dbx_type : fake_dbx_type(n))

#define ST_COFF_MAGIC	I386MAGIC
#endif

#ifdef ST_TE
#ifdef MIPSEB
#define ST_COFF_MAGIC	MIPSEBMAGIC
#else
#define ST_COFF_MAGIC	MIPSELMAGIC
#endif
#endif

typedef struct Extra_offset Extra_offset;

struct Extra_offset {
	int symno;		/* Symno from which offset applies */
	size_t offset;		/* Additional offset into strings */
	Extra_offset *next;
};

typedef unsigned Lru_stamp;

typedef unsigned long Bitvec_slot;
enum { BITS_PER_SLOT = sizeof(Bitvec_slot) * 8 };
	
/*  Fields needed for reading symbols from the text file.
 */
struct symio_s {
	alloc_pool_t *apool;
	const char *path;
	Lru_stamp last_used;
	bool own_apool;
	int fd;		/* File descriptor of the a.out file */
	strcache_id_t strcache_id;	/* Symbol strings cache handle */
	strpage_t **strpage_tab;	/* Table of cached sym string values */
	off_t syms_offset;	/* File offset of start of symbols */
	off_t strings_offset;/* File offset of symtab strings */
	int nsyms;		/* Number of symbols in this a.out file */
	Bitvec_slot *bitvec;	/* For mark_sym() and next_unmarked_sym() */
	int num_bitvec_slots;	/* # entries in bitvec */
	int symbuf_nsyms;	/* Size of symbol buffer in symbols */
	nlist_t *symbuf;	/* Symbol buffer */
	int symbase;		/* Symno of first symbol in buffer */
	int symlim;		/* Symno of one after the last sym in buffer */
	Extra_offset *extra_offsets;
	Extra_offset *last_extra_offset;
};

#define MAX_SYMIOS	4
static symio_t *Sitab[MAX_SYMIOS];

static void fill_symbuf PROTO((symio_t *si, int symno));
#ifdef COFF_SUN386
static void get_sec_lno_offsets PROTO((int fd, off_t fpos,
				       int count, fil_t *sfiles));
static int fake_dbx_type PROTO((nlist_t *n));
#endif
static size_t get_extra_offset PROTO((symio_t *si, int symno));
static symio_t **get_free_symio_slot PROTO((void));
static bool prepare_to_use PROTO((symio_t *si));
static void about_to_use PROTO((symio_t *si));

/*  Size of the buffer used by getsym, in units of SYMSIZE.
 *
 *  There are two buffer sizes - a large one for sequential
 *  reading and a small one for random reading.  The sequential scan
 *  routine (findsym) reduces the buffer size when it reads the last
 *  symbol.
 *
 *  Unfortunately SYMSIZE (12) is not an even divisor of 512 or 1024, so
 *  the read() buffer size is almost but not quite entirely unlike 1024.
 */
#define S_SYMBUF_NSYMS	256
#define R_SYMBUF_NSYMS	42

#ifdef COFF_SUN386
/*  Do a prescan of the line number information of an COFF file.
 *  The aim of this function is to set fu_lno_index and fu_num_lnos
 *  for each function with line number entries.  This prepares for
 *  future calls to read_func_coff_lnos().
 */
void
get_func_coff_lno_offsets(si, sfiles)
symio_t *si;
fil_t *sfiles;
{
	struct scnhdr *sectab, *st;
	int sectab_nbytes;
	struct filehdr filehdr;

	about_to_use(si);
	
	if (lseek(si->fd, (long)0, L_SET) == -1)
		panic("lseek failed in gfclo");
	if (read(si->fd, (char *)&filehdr, sizeof(filehdr)) != sizeof(filehdr))
		panic("read error in gfclo");

	sectab_nbytes = filehdr.f_nscns * sizeof(struct scnhdr);
	sectab = (struct scnhdr *)e_malloc(sectab_nbytes);

	if (lseek(si->fd, sizeof(struct aouthdr), L_INCR) == -1)
		panic("lseek failed in gfclo");
	if (read(si->fd, (char *)sectab, sectab_nbytes) != sectab_nbytes)
		panic("read failed in gfclo");
	
	for (st = sectab; st < &sectab[filehdr.f_nscns]; ++st) {
		if (st->s_nlnno != 0)
			get_sec_lno_offsets(si->fd, st->s_lnnoptr,
							      st->s_nlnno, sfiles);
	}

	free((char *)sectab);
}

static void
get_sec_lno_offsets(fd, fpos, count, sfiles)
int fd;
off_t fpos;
int count;
fil_t *sfiles;
{
	int lnnum;
	char *buf;
	const int bufcount = 1024;	/* # entries in buf */
	register char *iptr, *ilim;
	func_t *prev_f;
	taddr_t addr;
	fil_t *fil;
	funclist_t *fl;

	if (lseek(fd, fpos, L_SET) == -1)
		panic("lseek failed in gslo");

	/*  Note that LINESZ != sizeof(struct lineno) - the 386i C compiler
	 *  pads the 6 byte structure to 8 bytes.
	 */
	buf = e_malloc(bufcount * LINESZ);
	iptr = ilim = buf;

	addr = 0;
	fl = NULL;
	prev_f = NULL;
	fil = NULL;
	for (lnnum = 0; lnnum < count; ++lnnum) {
		struct lineno *l;

		if (iptr == ilim) {
			int to_read, nbytes;

			to_read = count - lnnum;
			if (to_read > bufcount)
				to_read = bufcount;
			nbytes = to_read * LINESZ;

			if (read(fd, buf, nbytes) != nbytes)
				panic("read error in gslo");
			iptr = buf;
			ilim = buf + nbytes;
		}
		l = (struct lineno *)iptr;
		iptr += LINESZ;

		/*  If l_lnno is zero, l_symndx points at the symbol table
		 *  entry for the first function in the source file, so we
		 *  must find which source file we are in.
		 */
		if (l->l_lnno == 0) {
			if (prev_f != NULL)
				FU_COFF_LNO_LIM(prev_f) = fpos + lnnum * LINESZ;
			for (fil = sfiles; fil != NULL; fil = fil->fi_next) {
				stf_t *stf;

				stf = (stf_t *)fil->fi_stf;
				if (l->l_addr.l_symndx >= stf->stf_symno &&
				    l->l_addr.l_symndx < stf->stf_symlim)
					break;
			}
			if (fil == NULL)
				panic("bad lnum in gslo");
			
			fl = fil->fi_funclist;
			if (fl == NULL)
				panic("fl botch in gslo");
			addr = fl->fl_func->fu_addr;
			prev_f = NULL;
		}
		else if (addr != 0 && l->l_addr.l_paddr > addr) {
			/*  FRAGILE CODE
			 *
			 *  We use ">" in the test above because the second
			 *  lineno entry for a function seems to correspond
			 *  to the first real line of the function.
			 *  Also, for the first function in the file, there
			 *  is no lineno with l_addr.l_paddr exactly equal
			 *  to the function address.
			 */
			if (prev_f != NULL)
				FU_COFF_LNO_LIM(prev_f) = fpos + lnnum * LINESZ;
			prev_f = fl->fl_func;
			FU_COFF_LNO_START(prev_f) = fpos + lnnum * LINESZ;
			fl = fl->fl_next;
			addr = (fl != NULL) ? fl->fl_func->fu_addr : 0;
		}
	}

	if (prev_f != NULL)
		FU_COFF_LNO_LIM(prev_f) = fpos + lnnum * LINESZ;
	
	free(buf);
}

lno_t *
read_func_coff_lnos(si, f, p_last)
symio_t *si;
func_t *f;
lno_t **p_last;
{
	static char *buf = NULL;
	char *iptr;
	lno_t *lnos, *ln;
	static long buf_nbytes = 0;
	long nbytes;
	int count;

	about_to_use(si);
	
	nbytes = FU_COFF_LNO_LIM(f) - FU_COFF_LNO_START(f);
	if (nbytes == 0) {
		*p_last = NULL;
		return NULL;
	}
	if (nbytes % LINESZ != 0)
		panic("nbytes botch in rfcl");
	count = nbytes / LINESZ;

	if (nbytes > buf_nbytes) {
		if (buf != NULL)
			free(buf);
		buf_nbytes = nbytes + 128;
		buf = e_malloc(buf_nbytes);
	}

	if (lseek(si->fd, FU_COFF_LNO_START(f), L_SET) == -1)
		panic("lseek failed in rfcl");
	if (read(si->fd, buf, nbytes) != nbytes)
		panic("read failed in rfcl");
	
	
	lnos = (lno_t *)alloc(si->apool, count * sizeof(lno_t));

	for (ln = lnos, iptr = buf; iptr < buf + nbytes; ++ln, iptr += LINESZ) {
		struct lineno *l;

		l = (struct lineno *)iptr;

		/*  From looking at 386i symbol tables, there seem to
		 *  be a lot of junk lineno entries after the last function
		 *  in a file.  The first of these seems to start with
		 *  l_lnno == 1, so we stop if we see this on other than
		 *  the first entry for a function.
		 */
		if (ln != lnos && l->l_lnno == 1)
			break;

		ln->ln_addr = l->l_addr.l_paddr;
		ln->ln_num = l->l_lnno;
		ln->ln_next = ln + 1;
	}
	ln[-1].ln_next = NULL;
	*p_last = ln - 1;
	return lnos;
}
#endif


/*  Given an executable file name and some other information, make a
 *  symio_t structure which can be use to read symbols and their strings
 *  from the text file.  Return an opaque handle on the structure.
 */
symio_t *
make_symio(ap, textpath, fd, syms_offset, nsyms, strings_offset)
alloc_pool_t *ap;
const char *textpath;
int fd;
off_t syms_offset;
int nsyms;
off_t strings_offset;
{
	symio_t *si;
	strcache_id_t strcache_id;
	strpage_t **pagetab;
	int npages, pagenum, num_bitvec_slots;
	bool own_apool;
	Bitvec_slot *bitvec;

	own_apool = ap == NULL;
	if (own_apool)
		ap = alloc_create_pool();
	
	strcache_id = sc_make_fd_strcache(fd);

	npages = nsyms / STRPAGESIZE + 1;
	pagetab = (strpage_t **)alloc(ap, sizeof(strpage_t *) * npages);
	for (pagenum = 0; pagenum < npages; ++pagenum)
		pagetab[pagenum] = NULL;

	/*  We allocate one extra slot as an end stop marker.
	 */
	num_bitvec_slots = ((nsyms + BITS_PER_SLOT - 1) / BITS_PER_SLOT) + 2;
	
	bitvec = (Bitvec_slot *)alloc(ap,
				      num_bitvec_slots * sizeof(Bitvec_slot));
	memset(bitvec, '\0', num_bitvec_slots * sizeof(Bitvec_slot));

	si = (symio_t *)alloc(ap, sizeof(symio_t));

	si->apool = ap;
	si->own_apool = own_apool;
/*	si->path = textpath;*/ 
/*RGA Insight says this is freed at end of make_symtab_cache, so save it */
	si->path =  alloc_strdup(ap, textpath);
	
	si->fd = fd;
	si->strcache_id = strcache_id;
	si->strings_offset = strings_offset;
	si->strpage_tab = pagetab;

	si->num_bitvec_slots = num_bitvec_slots;
	si->bitvec = bitvec;
	
	si->syms_offset = syms_offset;
	si->nsyms = nsyms;
	si->symbuf_nsyms = S_SYMBUF_NSYMS;
	si->symbuf = (nlist_t *)alloc(ap, si->symbuf_nsyms * SYMSIZE);
	si->symbase = si->nsyms + 1;
	si->symlim = 0;

	si->extra_offsets = NULL;
	si->last_extra_offset = NULL;

	*get_free_symio_slot() = si;
	
	return si;
}

void
mark_sym(si, symno)
symio_t *si;
int symno;
{
	if (symno < 0 || symno >= si->nsyms)
		panic("symno out of range in ms");

	si->bitvec[symno / BITS_PER_SLOT] |= 1 << (symno % BITS_PER_SLOT);
}

int
next_unmarked_sym(si, symno)
symio_t *si;
int symno;
{
	Bitvec_slot *slot;
	int offset;

	if (symno < 0 || symno > si->nsyms)
		panic("symno out of range in nus");
	
	slot = &si->bitvec[symno / BITS_PER_SLOT];
	
	offset = symno % BITS_PER_SLOT;

	/*  We are guaranteed to find a zero bit eventually, because we
	 *  have an extra slot with zero bits that mark_sym() can never set.
	 */
	for (;;) {
		if (*slot != ~0) {
			Bitvec_slot bits, mask;

			bits = *slot;
			mask = 1 << offset;
		
			for (; offset < BITS_PER_SLOT; ++offset) {
				if ((bits & mask) == 0) {
					return (slot - si->bitvec) *
						             BITS_PER_SLOT +
						offset;
				}

				mask <<= 1;
			}
		}

		offset = 0;
		++slot;
	}
}

/*  Return the number of symbols in the text file referred to by si.
 *  Used by scan_symtab() to detect the end of the symbol table.
 */
int
get_symio_nsyms(si)
symio_t *si;
{
	return si->nsyms;
}

static symio_t **
get_free_symio_slot()
{
	int i;
	symio_t **p_si;

	p_si = NULL;
	
	for (i = 0; i < MAX_SYMIOS; ++i) {
		if (Sitab[i] == NULL)
			return &Sitab[i];
		
		if (p_si == NULL ||
		    (Sitab[i] != NULL &&
		     Sitab[i]->last_used < (*p_si)->last_used)) {
			p_si = &Sitab[i];
		}
	}
			
	if (p_si == NULL)
		panic("lru botch in cls");

	sc_close_strcache((*p_si)->strcache_id);
	close((*p_si)->fd);
	(*p_si)->fd = -1;

	*p_si = NULL;
	return p_si;
}

static bool
prepare_to_use(si)
symio_t *si;
{
	static Lru_stamp stamp;
	symio_t **p_si;
	
	si->last_used = stamp++;
	
	if (si->fd != -1)
		return TRUE;

	p_si = get_free_symio_slot();

	if ((si->fd = open(si->path, O_RDONLY)) == -1) {
		failmesg("Can't reopen", "", si->path);
		return FALSE;
	}

	si->strcache_id = sc_make_fd_strcache(si->fd);

	*p_si = si;
	return TRUE;
}

/*  TODO: error returns from getsym() et al, so we can handle failure
 *        to reopen a symio.
 */
static void
about_to_use(si)
symio_t *si;
{
	if (!prepare_to_use(si))
		panic("failed to reopen si");
}

/*  Close (and conceptually destroy) si.  We don't actually free
 *  the structure here because space for it was allocated via alloc().
 */
void
close_symio(si)
symio_t *si;
{
	if (si->fd != -1) {
		int i;
		
		sc_close_strcache(si->strcache_id);

		close(si->fd);

		for (i = 0; i < MAX_SYMIOS; ++i) {
			if (Sitab[i] == si) {
				Sitab[i] = NULL;
				break;
			}
		}

		if (i == MAX_SYMIOS)
			panic("missing sitab entry in cs");
	}

	if (si->own_apool)
		alloc_free_pool(si->apool);
}

/*  Fill the symbols buffer of si so that symbol symno is at the start of
 *  the buffer.
 */
static void
fill_symbuf(si, symno)
symio_t *si;
int symno;
{
	int n_read, nsyms_to_read;

	if (symno < 0 || symno >= si->nsyms)
		panic("symno botch in fs");

	if (lseek(si->fd, si->syms_offset + symno * (int)SYMSIZE,
								L_SET) == -1)
		panic("lseek failed in fs");

	nsyms_to_read = si->symbuf_nsyms;
	if (si->nsyms - symno < nsyms_to_read)
		nsyms_to_read = si->nsyms - symno;

	n_read = read(si->fd, (char *)si->symbuf,
						nsyms_to_read * SYMSIZE);

	if (n_read == -1)
		panic("read error in symbol table");
	if (n_read == 0)
		panic("unexpected EOF in symbol table");
	if (n_read % SYMSIZE != 0)
		panic("n_read botch in fs");

	si->symbase = symno;
	si->symlim = si->symbase + n_read / SYMSIZE;
}

/*  Get symbol symnum from the symbol table, and copy to *p_nm.
 */
void
getsym(si, symno, p_nm)
symio_t *si;
int symno;
nlist_t *p_nm;
{
	char *src;

	about_to_use(si);
	
	if (symno < si->symbase || symno >= si->symlim)
		fill_symbuf(si, symno);

	/*  On the Sun 386, sizeof(nlist_t) is not the same as the
	 *  size of an nlist entry in the file.  Thus we have to
	 *  play silly games to get to the right entry.
	 */
	src = (char *)si->symbuf + (symno - si->symbase) * SYMSIZE;
	*p_nm = *(nlist_t *)src;
#ifdef COFF_SUN386
	p_nm->n_type = DBX_TYPE(p_nm);
#endif
}

#ifdef COFF_SUN386
/*  Construct an dbx symbol table format type from the various
 *  mangy bits of COFF info.
 */
static int
fake_dbx_type(n)
nlist_t *n;
{
	/*  Map from COFF section numbers to nm types.
	 *
	 *  The sections seem to be numbered from one on the nm.n_scnum stuff,
	 *  so we have a filler at zero.
	 *
	 *  BUG: should probably look at the section names and set this
	 *       array from them.
	 */
	static int sctypes[] = { N_UNDF, N_TEXT, N_DATA, N_BSS };

	if ((unsigned)n->n_scnum >= sizeof sctypes / sizeof *sctypes)
		return N_UNDF;
		
	return sctypes[n->n_scnum] | ((n->n_sclass == C_EXT) ? N_EXT : 0);
}
#endif

#ifdef ST_TE
/*  Return a copy of the NUL terminated string at the given offset
 *  from the start of the strings for si.
 */
const char *
si_get_string(si, offset)
symio_t *si;
off_t offset;
{
	size_t len;
	const char *s;

	about_to_use(si);
	
	s = sc_get_string(si->strcache_id, si->strings_offset + offset,
								  '\0', &len);
	if (s == NULL)
		panic("str botch in sgs");
	
	return strcpy(alloc(si->apool, len + 1), s);
}
#endif /* ST_TE */


#ifndef ST_TE
/*  Search the symbol table starting from symbol number symno for a
 *  symbol whose type is in symset.  A symbol is wanted if symset[nm.n_type]
 *  is non zero.  If we find a wanted symbol, copy it to *p_nm and return
 *  its symbol number.  Otherwise return a symbol number one larger than
 *  that of the last symbol in the table.
 *
 *  This is used by the sequential prescan in scan_symtab().
 *
 *  See the comment in getsym for why p_nm below is "char *" rather
 *  than "nlist_t *".
 *
 *  Not used on the DECstation 3100.
 */
int
findsym(si, symno, p_res, symset)
symio_t *si;
int symno;
nlist_t *p_res;
register const char *symset;
{
	register char *p_nm;
#ifdef COFF_SUN386
	int numaux;
#endif

	about_to_use(si);
	
	if (symno < si->symbase)
		fill_symbuf(si, symno);
	p_nm = (char *)si->symbuf + (symno - si->symbase) * SYMSIZE;
#ifdef COFF_SUN386
	numaux = 0;
#endif
	for (; symno < si->nsyms; p_nm += SYMSIZE, ++symno) {
		if (symno >= si->symlim) {
			fill_symbuf(si, symno);
			p_nm = (char *)si->symbuf;
		}
#ifdef COFF_SUN386
		if (numaux > 0) {
			--numaux;
			continue;
		}
		numaux = ((nlist_t *)p_nm)->n_numaux;
		((nlist_t *)p_nm)->n_type = DBX_TYPE((nlist_t *)p_nm);
#endif
		if (symset[((nlist_t *)p_nm)->n_type] != 0) {
			*p_res = *(nlist_t *)p_nm;
			return symno;
		}
	}

	/*  End of sequential scan, so shrink the buffer.
	 *
	 *  The buffer was allocated via alloc(), so we don't actually
	 *  change the size - we just drop symbuf_nsyms.  The next
	 *  fill of the buffer will use the reduced size.
	 */
	si->symbuf_nsyms = R_SYMBUF_NSYMS;

	return symno;
}

/*  Symbol table perversity #473: gcc on BSD/386 puts N_DATA symbols
 *  in the middle of a symbol whose definition is split over multiple
 *  lines.  So when we see a backslash continuation, we have to keep
 *  reading until we see a symbol of the same type as the first.
 */
const char *
get_cont_symstring(sr)
Symrec *sr;
{
#ifndef ARCH_BSDI386
	return symstring(sr->symio, ++sr->symno);
#else
	int symtype;
	nlist_t nm;

	getsym(sr->symio, sr->symno, &nm);
	symtype = nm.n_type;

	do {
		getsym(sr->symio, ++sr->symno, &nm);
	} while (nm.n_type != symtype);

	return symstring(sr->symio, sr->symno);
#endif
}

/*  Return the string for symbol symno.
 *
 *  Not used on the DECstation 3100.
 */
const char *
symstring(si, symno)
symio_t *si;
int symno;
{
	nlist_t nm;
	int pagenum, slot;
	strpage_t *page;
	
	about_to_use(si);

	if (symno < 0 || symno >= si->nsyms)
		panic("symno botch in ss");
	
	pagenum = symno / STRPAGESIZE;
	page = si->strpage_tab[pagenum];
	
	if (page == NULL) {
		int i;

		page = (strpage_t *)alloc(si->apool, sizeof(strpage_t));
		for (i = 0; i < STRPAGESIZE; ++i)
			page->str[i] = NULL;
		si->strpage_tab[pagenum] = page;
	}
	
	slot = symno % STRPAGESIZE;
	if (page->str[slot] == NULL) {
		const char *line;

		getsym(si, symno, &nm);
#ifdef COFF_SUN386
		if (nm.n_leading_zero != 0) {
			char *buf;

			buf = alloc(si->apool, SYMNMLEN + 1);
			(void) memcpy(buf, nm.n_name, SYMNMLEN);
			buf[SYMNMLEN] = '\0';
			line = buf;
		}
		else /* revolting, but I can't think of a neater way */
#endif
		  /* RGA gcc 2.8.0 sometimes has nm.n_offset == 0 */
		  /* for the first filename. sc_get_string() works  */
		  /* though */
		  /*		      if (nm.n_offset == 0) */
		  /*			line = NULL;*/
		  /*		else*/ {
			off_t offset;
			size_t len;

			offset = nm.n_offset;
			if (si->extra_offsets != NULL)
				offset += get_extra_offset(si, symno);
			
			line = sc_get_string(si->strcache_id,
					     si->strings_offset + offset,
					     '\0', &len);
			line = strcpy(alloc(si->apool, len + 1), line);
		}
		page->str[slot] = line;
	}
	
	return page->str[slot];
}
#endif /* !ST_TE */

static size_t
get_extra_offset(si, symno)
symio_t *si;
int symno;
{
	Extra_offset *eo, *prev;
	
	prev = NULL;

	eo = si->last_extra_offset;
	
	if (eo == NULL || eo->symno > symno)
		eo = si->extra_offsets;

	prev = NULL;
	for (; eo != NULL; eo = eo->next) {
		if (eo->symno > symno)
			break;
		prev = eo;
	}

	si->last_extra_offset = prev;

	return (prev != NULL) ? prev->offset : 0;
}
	
void
add_extra_string_offset(si, symno, offset)
symio_t *si;
int symno;
off_t offset;
{
	Extra_offset *eo, *last;

	if (offset == 0)
		return;
	
	last = NULL;
	for (eo = si->extra_offsets; eo != NULL; eo = eo->next)
		last = eo;

	eo = (Extra_offset *)alloc(si->apool, sizeof(Extra_offset));
	eo->symno = symno;
	eo->offset = offset;
	eo->next = NULL;
	
	if (last == NULL)
		si->extra_offsets = eo;
	else
		last->next = eo;
}

/* RGA use fd of symio instead of symtab, because getsym(), findsym(), etc
   call get_free_symio_slot() which reuses fd numbers, so symtab_t fd 
   can be invalid */
int
get_symio_fd(si)
symio_t *si;
{
  about_to_use(si);
  return si->fd;
}
		
#endif /* AO_TARGET */
