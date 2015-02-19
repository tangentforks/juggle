# The HTML output with the index is good for online viewing:

all: c2j.html c2j-ni.html c2j-data.ijs

c2j.html: c2j.nw
	noweave -html -filter autodefs.ijs -index  c2j.nw > c2j.html

# The HTML output without the index is good for a print publication:
c2j-ni.html: c2j.nw
	noweave -html -filter autodefs.ijs -index  c2j.nw > c2j-ni.html

c2j-data.ijs: c2j.nw
	notangle -t8 -Rc2j-data.ijs -filter emptydefn  c2j.nw > c2j-data.ijs

clean:
	rm -f c2j.html c2j-ni.html c2j-data.ijs *.bak
