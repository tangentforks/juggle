#!/usr/bin/awk -f

# { print > "log" }
# do the job of emptydefn right here, too:
/^@defn ./ {chunk_name=$0; sub (/^@defn /, "", chunk_name)}
/^@defn $/ {sub (/$/, chunk_name)}

# do the job of html paragraph insertions right here, too:
/^@begin doc/			{ indoc=1; }
indoc && ($0 == "@text ")	{ $0="@text <p>" }
/^@end doc/			{ indoc=0 }

/^@text [a-zA-Z][a-zA-Z0-9_]*[ 	]*=:/ {
	tmp=$0; sub (/[ 	]*=:.*/, "", tmp); sub (/^@text /, "", tmp)
	globals[tmp]++
}
/^@end code/ {
	for (id in globals) print "@index defn", id
	print "@index nl"
	delete globals
}

{ print }
