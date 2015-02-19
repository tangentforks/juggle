PROGS = urlencode urldecode
DEST=/usr/local

all: $(PROGS)

install: $(PROGS)
	cp $(PROGS) $(DEST)/bin
	cp *.1 $(DEST)/man/man1

clean:; rm -f $(PROGS)
