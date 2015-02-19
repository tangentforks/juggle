#include <stdio.h>
#include <string.h>

main()
{
	int c;

	while ((c=getchar())!=EOF) switch (c) {
	case '+': putchar(' '); break;
	case '%': {
		static char *hexchars = "0123456789ABCDEF";
		int code;
		int h16, h0;

		h16=toupper(getchar()); h0=toupper(getchar());
		code = 16*(strchr(hexchars, h16)-hexchars)
			+ (strchr(hexchars, h0 )-hexchars);
		putchar (code=='\r' ? '\n' : code);
		break;
        }
	default: putchar(c);
	}
	exit (0);
}
