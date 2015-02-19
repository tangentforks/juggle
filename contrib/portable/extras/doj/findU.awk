/^N/ { n=$0 }
/^U/ { printf ("%s:%d: %s %s\n", FILENAME, FNR, n, $0) }
