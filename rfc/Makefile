DEST = /usr/local

default:;	@echo "nothing to do per default"

install: rfc rfc.1
	cp rfc $(DEST)/bin
	cp rfc.1 $(DEST)/man/man1
	@[ -d /var/rfc ] || echo "Prepare the initial cache dir!"

# This "make cachedir" recipe is just a dumb !suggestion!.
# Rather than using the extremely liberal mode 666, have all users
# in a common group and use 775.  Also make sure that your prepared
# indexes can be overwritten later.  Or set up a monthly cronjob.

cachedir:
	mkdir /var/rfc
	chmod 666 /var/rfc
	rfc -r rfc
	rfc -r std
	rfc -r bcp
	rfc -r fyi
