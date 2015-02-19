##
## Makefile for ntail					Feb 1996
## (schoenfr@gaertner.de)
##

## 
## my name and version:
##
N=ntail
V=0.2

##
## compiler and flags:
##
# CC = gcc -Wall -O
CC = cc
CFLAGS = -g
LDFLAGS = -g

##
## installation path:
##
prefix = /usr/local
BINDIR = $(prefix)/bin
MANDIR = $(prefix)/man
MANSUF = 1

##
## hopyfully this is independent...
##
XTRA = README Makefile COPYRIGHT
SRCS = ntail.c
OBJS = ntail.o
DOCS = ntail.1

PRGS = ntail

all:	$(PRGS)

ntail:	ntail.o $(OBJS)
	@if [ -f ntail ] ; then rm -f ntail ; else true ; fi
	$(CC) $(LDFLAGS) -o ntail $(OBJS) $(LIBS)

##

install:	ntail
	install -c ntail $(BINDIR)
	install -c ntail.1 $(MANDIR)/man$(MANSUF)/ntail.$(MANSUF)

tar dist:
	rm -rf $N-$V || /bin/true
	mkdir $N-$V
	cp -p $(XTRA) $(SRCS) $(DOCS) $N-$V
	tar cvf $N-$V.tar $N-$V
	gzip -v -9 -f $N-$V.tar
	rm -rf $N-$V || /bin/true

##

clean:
	rm -f  *.o *.a $(PRGS) core *~

realclean distclean clobber:	clean
	rm -f *.tar.gz TAGS
