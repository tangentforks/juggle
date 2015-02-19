JLIB = /usr/local/lib/j

syslog.ijs:  syslog.sym
	$(JLIB)/system/extras/util/sym2ijs syslog.sym

install: syslog.ijs
	mv syslog.ijs $(JLIB)/contrib/unix/main/syslog.ijs

clean:;
	rm -f syslog.ijs
