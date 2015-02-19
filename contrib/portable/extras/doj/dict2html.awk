function htmlify (s)
{
	gsub (/&/, "\\&amp;", s)
	gsub (/</, "\\&lt;", s)
	gsub (/>/, "\\&gt;", s)
	return s
}
function dishtmlify (s)
{
	gsub (/&amp;/, "\\&", s)
	gsub (/&gt;/, ">", s)
	gsub (/&lt;/, "<", s)
	gsub (/&nbsp;/, " ", s)
	return s
}

BEGIN {
	innerlinks=1
	idxfile = "symbol-index"
	idx_by_name_file = "name-index"
	
	variants["m"] = "monad"
	variants["d"] = "dyad"
	variants["a"] = "adverb"
	variants["c"] = "conjunction"
	variants["p"] = "punctuation"
	variants["i"] = "copula"	# "is"
	variants["f"] = "foreign"
	variants["u"] = "miscellaneous"

	print "<html><head>"
	print "<title>The Dictionary of J</title>"
	print "</head><body>"
	print "<h1>The Dictionary of J</h1>"
}

/^#/	{ next }

/^$/ {
	delete rr
	Variant=variant=""
	aa=reference=example=0
	print "<hr>"
}

innerlinks && /^$/ {
	print "<center>"
	print "<a href=\"#qi\">Quick index</a> -"
	print "<a href=\"#fi\">Full index</a>"
	print "</center>"
	print "<hr>"
}

# before any substituions, save the line as is:
{
	original_line = $0
}

# HTMLify special characters:
{
	gsub (/&/, "\\&amp;")
	gsub (/</, "\\&lt;")
	gsub (/>/, "\\&gt;")
}

# HTMLify special Dictionary markup:
{
	gsub (/\[\[ */, "<em>")		# <code> would be more adequate.
	gsub (/ *\]\]/, "</em>")
	gsub (/_\(/, "<i>")
	gsub (/\)_/, "</i>")
	gsub (/\*\(/, "*")
	gsub (/\)\*/, "*")
}

/^[NMDACPFIUR]/ {
	rr[code=substr($0, 1, 1)] = substr ($0, 3)
	if (code ~ /[MDACPFIU]/) {
		variant=tolower (Variant=code)
	}
}

# catch foreign group names for later patching

/^F.*!:$/	{ foreign_group=rr["N"] }

/^T/ && !reference {
	compressed_symbol = rr[Variant];
	gsub (/ /, "\\&nbsp;", compressed_symbol);

	if (! seen[compressed_symbol]++) {
		cs=compressed_symbol; gsub (/"/, "\\&quot;", cs)
		if (cs)
			printf ("<a name=\"%s\">\n", cs)
	}

	if (Variant=="F" && (rr["F"] ~ /!:./))
		rr["N"]= foreign_group " - " rr["N"]

	printf ("<h2><a name=\"label%d\">%s</a>: <code>%s</code></h2>\n",
		++lbl, rr["N"],
		Variant=="P" ? "control word" : rr[Variant] )
	if (Variant) printf ("<br>(%s)", variants[variant]);
	if ("R" in rr)
		printf ("<br>Rank%s: %s\n",
			(variant ~ /[ac]/) ? "s of derived verb" : "",
			rr["R"])
	if (cs) {
		print "</a>"
		cs=""
	}

	# write various index files:
	compressed_symbol=dishtmlify(compressed_symbol)
	gsub (/[()]/, " ", compressed_symbol)
	sub (/^ +/, "", compressed_symbol)
	if (1 || ! seen[compressed_symbol]++) {
		s = sprintf ("%-18s %s (%s)\tlabel%d",
			compressed_symbol, rr["N"], variants[variant], lbl)
		sub (/ \(([a-z_]+\.|foreign)?\)/, "", s)
		s=dishtmlify(s)
		print s > idxfile
	}
	s = sprintf ("%s (%s) %s\tlabel%d",
		rr["N"], variants[variant], compressed_symbol, lbl)
	sub (/ \(([a-z_]+\.)?\)/, "", s)
	s=dishtmlify(s)
	print s > idx_by_name_file
}

/^T/	{ reference=1 ; example=0}
/^H/	{ reference=0 ; example=0}
/^E/	{ example=1 }

/^[THE ]$/	{ print "<p>" }

/^ ./ {
	if (example) {
		print "<pre>"
		print "<br>   &gt;\t"$0
		print "</pre>"
	} else {
		print
	}
}

# ascii art regions

/^\|/ {
	if (!aa) {
		print "<pre>"
		aa=1
	}
	sub (/^\|/, "\t")
	print
}
aa && !/^\|/ {
	print "</pre>"
	aa=0
}

END {
	close (idxfile)
	print "<hr>"
	print "<h1><a name=\"fi\">Full Index</a></h1>"
	FS="\t"
	while ((getline <idxfile) > 0) {
		gsub (/ /, "\\&nbsp;", $1)
		printf ("<br><a href=\"#%s\">%s</a>\n", $2, $1)
	}
	close (idxfile)
}

QQEND {
	close (idx_by_name_file)
	print "<h1><a name=\"ni\">Name Index</a></h1>"
	FS="\t"
	while ((getline <idx_by_name_file) > 0) {
		printf ("<br><a href=\"#%s\">%s</a>\n", $2, $1)
	}
	close (idx_by_name_file)
	print "<hr>"
}

END {
	quick_index_file = "qi"
	print "<hr>"
	print "<h1><a name=\"qi\">Abridged Index</a></h1>"
	FS="\t"
	while ((getline <quick_index_file) > 0) {
		printf ("<a href=\"#%s\">%s</a>\n", $2, $1)
	}
	print "<hr>"
}

END {
	print "</body></html>"
}
