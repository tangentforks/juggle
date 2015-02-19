#include <stdio.h>

main()
{
	int c;

	while ((c = getchar()) != EOF) {
		if ((c >= 'a' && c <= 'z')
		    || (c >= 'A' && c <= 'Z')
		    || (c >= '0' && c <= '9')) {
			putchar(c);
		} else if (c == ' ') {
			putchar('+');
		} else {
			printf("%%%02X", c);
		}
	}
	return 0;
}
