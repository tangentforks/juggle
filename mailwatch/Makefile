DEST=/usr/local

install:;
	cp mailwatch $(DEST)/sbin
	cp mailwatch.8 $(DEST)/man/man8

rdist:;
	rdist -m spog
	rdist -P /usr/local/bin/ssh -m coyn -m cretuer
