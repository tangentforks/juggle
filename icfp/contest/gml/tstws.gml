% The following tests check whether the lexer deals
% properly with whitespace.
% The first tests check for (non-functioning) \t style escapes:
 tab
 newline
 vertical
 return
 111
	a tab

a newline



after4newlinechars
"an illegal character:" @
"a string with blanks"
"a string
with
newlines"
