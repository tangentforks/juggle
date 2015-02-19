TXTS= \
	intro.txt \
	part-I.txt \
	part-II.txt \
	part-III-0.txt \
	part-III-1.txt \
	part-III-2.txt \
	ref+acks.txt \
	foreigns.txt

PROGS= dict2html.awk dict2troff.awk mkqi

all: full.html full.cat full.ps

full.html: $(TXTS) dict2html.awk mkqi
	awk -f dict2html.awk $(TXTS) > full.html
	./mkqi
	awk -f dict2html.awk $(TXTS) > full.html

full.tr: $(TXTS) dict2troff.awk
	awk -f dict2troff.awk $(TXTS) > full.tr

full.cat: full.tr
	groff -Tlatin1 full.tr > full.cat

full.ps: full.tr
	groff -Tps full.tr > full.ps

trx: full.tr
	groff -X full.tr
