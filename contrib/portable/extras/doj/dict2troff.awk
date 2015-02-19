function troffify (s)
{
	gsub (/\\/, "\\e", s)
	gsub (/<=>/, "\\(<>", s)
	return s
}
function untroffify (s)
{
	gsub (/\\e/, "\\", s)
	return s
}

BEGIN {
	innerlinks=0
	idxfile = "t-symbol-index"
	idx_by_name_file = "t-name-index"
	
	variants["m"] = "monad"
	variants["d"] = "dyad"
	variants["a"] = "adverb"
	variants["c"] = "conjunction"
	variants["p"] = "punctuation"
	variants["i"] = "copula"	# "is"
	variants["f"] = "foreign"
	variants["u"] = "miscellaneous"

	# print ".ps 12\n.vs 14\n.na\n"
	print ".na"
	print ".ce 1\n\\s+4The Dictionary of J\\s0\n.sp 2"
}

/^#/	{ next }

/^$/ {
	delete rr
	Variant=variant=""
	if (example) print ".fi"
	if (aa) print ".fi"
	aa=reference=example=0
	print ".sp 1"
}

# before any substituions, save the line as is:
{
	original_line = $0
}

# quote special characters:
{
	$0= troffify($0)
}

# HTMLify special Dictionary markup:
!example {
	gsub (/\[\[ */, "\\fB")		# <code> would be more adequate.
	gsub (/ *\]\]/, "\\fP")
	gsub (/_\(/, "\\fI")
	gsub (/\)_/, "\\fP")
	gsub (/\*\(/, "\\fB")
	gsub (/\)\*/, "\\fP")
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
	if (Variant=="F" && (rr["F"] ~ /!:./))
		rr["N"]= foreign_group " - " rr["N"]

	printf ("\\fB\\s+2%s%s\\s0\\fP\n",
		rr["N"],
		Variant ? (": " rr[Variant]) : "" )
	if (Variant) printf ("(%s)\n", variants[variant]);
	if ("R" in rr)
		printf ("Rank%s: %s\n",
			(variant ~ /[ac]/) ? "s of derived verb" : "",
			rr["R"])
}

/^T/	{ if (example) print ".fi"; reference=1 ; example=0}
/^H/	{ if (example) print ".fi"; reference=0 ; example=0}
/^E/	{ print ".nf"; example=1 }

/^[THE ]$/	{ print ".sp 1" }

/^ ./ {
	sub (/^ /, "")
	if (example)
		print "\t" $0
	else
		print
	next
}

# ascii art regions

/^\|/ {
	if (!aa) {
		print ".nf"
		aa=1
	}
	print "\t" substr ($0, 2)
}
aa && !/^\|/ {
	print ".fi"
	aa=0
}
