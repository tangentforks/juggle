/^[^ |]/ {markup=0}
/^[TH]/	{markup=1}
markup && /^ / {
	# Check against mismatched *(bold)* and _(italic)_:
	s=$0
	gsub (/\*\([^)]*\)\*/, "", s)
	gsub (/_\([^)]*\)_/, "", s)
	if (s ~ /\*\(|\)\*|_\(|\)_/ ) {
		printf ("%s:%d: %s\n", FILENAME, FNR, s)
		print
	}
	# Check against mismatched [[code]]:
	# Many phrases will contain single brackets
	# and be flagged even though they are OK.
	s=$0
	gsub (/[^][]/, "", s)		# brackets only
	gsub (/\[\[\]\]/, "", s)	# remove OK bracket pairs
	if (s ~ /[][]/) {
		printf ("%s:%d: %s\n", FILENAME, FNR, s)
		print
	}
}
