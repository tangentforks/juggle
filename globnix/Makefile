# $Id: Makefile,v 1.1.1.1 2000/04/14 17:11:32 neitzel Exp $

P = globnix

$P:	$P.sh
	cp $P.sh $P
	chmod +x $P

install: $P
	install $P /usr/local/bin
	install $P.1 /usr/local/man/man1

clean:;
	rm -f $P
	sh $P.sh -r
