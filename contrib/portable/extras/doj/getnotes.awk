/^N/ {name=$0}

/^#/ {
	if (name) printf ("\n%s:\n", name)
	name=0
	print
}
