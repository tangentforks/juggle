CFLAGS=-O

imerge: imerge.c
	cc $(CFLAGS) -o imerge imerge.c

clean:;	rm -f core imerge *.o

install: imerge
	strip imerge
	cp imerge /usr/local/bin
	cp imerge.1 /usr/local/man/man1
