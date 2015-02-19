pwgen:	pwgen.c
	cc -o pwgen pwgen.c

install: pwgen pwgen.1
	cp pwgen /usr/local/bin
	cp pwgen.1 /usr/local/man/man1

clean:;	rm -f pwgen core
