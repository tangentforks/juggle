/* idiff: interactive diff */

#include <stdio.h>
#include <ctype.h>

#include <unistd.h>

char *progname;
#define HUGE	10000		/* large number of lines */

main (argc, argv)
int argc;
char *argv[];
{
	FILE *fin, *fout, *f1, *f2, *efopen();
	char buf[BUFSIZ], *mktemp();
	char *outfile;

	progname = argv[0];
	if (argc != 3  && argc != 4) {
		fprintf (stderr, "Usage: %s file1 file2 [mergedfile]\n",
			 progname);
		exit (1);
	}
	f1 = efopen (argv[1], "r");
	f2 = efopen (argv[2], "r");
	outfile = argc==4 ? argv[3] : "imerge.out";
	fout = efopen (outfile, "w");
	sprintf (buf, "diff %s %s", argv[1], argv[2]);
	fin = popen (buf, "r");
	idiff (f1, f2, fin, fout);
	pclose (fin);
	fclose (f1);
	fclose (f2);
	fclose (fout);
	printf ("%s output in file %s\n", progname, outfile);
	exit (0);
}

idiff (f1, f2, fin, fout)	/* process diffs */
FILE *f1, *f2, *fin, *fout;
{
	char *getenv();
	char *tempfile;
	char buf[BUFSIZ], buf2[BUFSIZ];
	FILE *ft, *efopen();
	int cmd, n, from1, to1, from2, to2, nf1, nf2;
	char *editor;

	(editor = getenv("VISUAL")) ||
		(editor = getenv("EDITOR")) ||
			(editor = "vi") ;

	if ( ! (tempfile = tmpnam(NULL))) {
		fprintf (stderr, "%s: tmpnam(3) failed\n", progname);
		exit (1);
	}
	nf1 = nf2 = 0;
	while (fgets (buf, sizeof buf, fin) != NULL) {
		parse (buf, &from1, &to1, &cmd, &from2, &to2);
		n = to1-from1 + to2-from2 + 1; /* #lines from diff */
		if (cmd == 'c')
			n += 2;
		else if (cmd == 'a')
			from1++;
		else if (cmd == 'd')
			from2++;
		printf ("%s", buf);
		while (n-- > 0) {
			fgets (buf, sizeof buf, fin);
			printf ("%s", buf);
		}
		do {
			printf ("? ");
			fflush (stdout);
			fgets (buf, sizeof buf, stdin);
			switch (buf[0]) {
			case '>':
				nskip (f1, to1-nf1);
				ncopy (f2, to2-nf2, fout);
				break;
			case '<':
				nskip (f2, to2-nf2);
				ncopy (f1, to1-nf1, fout);
				break;
			case 'e':
				ncopy (f1, from1-1-nf1, fout);
				nskip (f2, from2-1-nf2);
				ft = efopen (tempfile, "w");
				ncopy (f1, to1+1-from1, ft);
				fprintf (ft, "---\n");
				ncopy (f2, to2+1-from2, ft);
				fclose (ft);
				sprintf (buf2, "%s %s", editor, tempfile);
				system (buf2);
				ft = efopen (tempfile, "r");
				ncopy (ft, HUGE, fout);
				fclose (ft);
				break;
			case '!':
				system (buf+1);
				printf ("!\n");
				break;
			default:
				printf ("%s\n%s\n%s editor '%s'\n%s\n",
					"<	take old hunk",
					">	take new hunk",
					"e	merge hunks in with", editor,
					"!cmd	execute shell cmd");
				break;
			}
		} while (buf[0] != '<' &&
			 buf[0] != '>' &&
			 buf[0] != 'e');
		nf1 = to1;
		nf2 = to2;
	}
	ncopy (f1, HUGE, fout);
	unlink (tempfile);
}

parse (s, pfrom1, pto1, pcmd, pfrom2, pto2)
char *s;
int *pcmd, *pfrom1, *pto1, *pfrom2, *pto2;
{
#define a2i(p) while (isdigit(*s)) p = 10*(p) + *s++ - '0'

	*pfrom1 = *pto1 = *pfrom2 = *pto2 = 0;
	a2i (*pfrom1);
	if (*s == ',') {
		s++;
		a2i (*pto1);
	} else
		*pto1 = *pfrom1;
	*pcmd = *s++;
	a2i (*pfrom2);
	if (*s == ',') {
		s++;
		a2i (*pto2);
	} else
		*pto2 = *pfrom2;
}

nskip (fin, n)
FILE *fin;
int n;
{
	char buf[BUFSIZ];

	while (n-- >0)
		fgets (buf, sizeof buf, fin);
}

ncopy (fin, n, fout)
FILE *fin, *fout;
{
	char buf[BUFSIZ];

	while (n-- > 0) {
		if (fgets (buf, sizeof buf, fin) == NULL)
			return;
		fputs (buf, fout);
	}
}

FILE *efopen (name, mode)
char *name, *mode;
{
	FILE *f;

	if ( ! (f=fopen(name, mode))) {
		fprintf (stderr, "%s: could not open file %s\n",
			 progname, name);
		exit (1);
	} else
		return f;
}
