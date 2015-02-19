#include <stdio.h>
#include <sys/time.h>

/* decide if you want to use a /dev/random device, eg. under linux */

#define DEVRANDOM 0

#if DEVRANDOM
static FILE *rnd;
#endif

/*
 * Some predefined character sets to choose elements from.
 */

/* safeset: nuke whatever could be ambigous when sent on a bad facsimile,
 * spoken over a noise telephone line, or displayed in a serifless font:
 *  I/1/l,  Oh/Zer0, mixed case
 */
static char *safeset = "abcdefghkmnpqrstuvwxyz23456789";
static char *lower = "abcdefghijklmnopqrstuvwxyz";
static char *upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static char *alpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIHKLMNOPQRSTUVWXYZ";
static char *alnumset =
"abcdefghijklmnopqrstuvwxyzABCDEFGHIHKLMNOPQRSTUVWXYZ0123456789";
static char *decset = "0123456789";
static char *hexset = "0123456789ABCDEF";

static usage (pname)
char *pname;
{
	fprintf (stderr,
		"usage: %0 [-sadh] [-c characters] [-n count] [-l length]\n",
		pname);
	fprintf (stderr, "predefined character sets:\n");
	fprintf (stderr, "-s: %s [default]\n", safeset);
	fprintf (stderr, "-L: %s\n", lower);
	fprintf (stderr, "-U: %s\n", upper);
	fprintf (stderr, "-A: %s\n", alpha);
	fprintf (stderr, "-a: %s\n", alnumset);
	fprintf (stderr, "-d: %s\n", decset);
	fprintf (stderr, "-h: %s\n", hexset);
}

static gen_pw (charset, setsize, length)
char *charset;
int setsize, length;
{
	while (length-- >0) {
		unsigned int i;
#if DEVRANDOM
		fread (&i, sizeof(int), 1, rnd);
#else
		i = random();
#endif
		putchar (charset[i%setsize]);
	}
	putchar ('\n');
}

main (argc, argv)
int argc;
char **argv;
{
	extern char *optarg;
	extern int optind;
	int c;
	char *charset=safeset;
	int setsize;
	int cnt = 1;
	int length=8;
	int errflg=0;

#if DEVRANDOM
	if ( ! (rnd=fopen ("/dev/urandom", "r"))) {
		perror ("/dev/random");
		exit (1);
	}
#else
	struct timeval tv;
	gettimeofday(&tv, (struct timezone*)0);
	srandom (tv.tv_sec + tv.tv_usec + getpid());
#endif

	while ((c = getopt(argc, argv, "LUAsadhc:l:n:")) != -1)
	switch (c) {
	case 'L': charset = lower;	break;
	case 'U': charset = upper;	break;
	case 'A': charset = alpha;	break;
	case 's': charset = safeset;	break;
	case 'a': charset = alnumset;	break;
	case 'd': charset = decset;	break;
	case 'h': charset = hexset;	break;
	case 'c': charset = optarg;	break;
	case 'l': length = atoi (optarg); break;
	case 'n': cnt = atoi (optarg);	break;
	case 'u':
	case '?':
	default: ++errflg;
	}
	if (errflg) {
		usage (argv[0]);
		exit (1);
	}

	setsize = strlen (charset);
	while (cnt--)
		gen_pw (charset, setsize, length);

#if DEVRANDOM
	fclose (rnd);
#endif
	exit (0);
}
