require 'regex files strings'

coclass 'base'

NB. regex patterns for comments, numbers, identifiers, strings, ...
NB. The last part (the ".") catches "any remaining illegal character".
NB. We cannot say whether a one-letter identifier would be matched
NB. through the id subpattern or the "remaining" subpattern.
NB. However, that's not important anyway -- the big "select." in
NB. token_analyze will recognize a one-letter id as such.

NB. The second-to-last expression for "white-space" is just [SPC TAB]
NB. and does not recognize \v \n \r.  Neither \v nor \013 does the
NB. job within the [].
NB. While the lack of \n \r is not so bad because \r are suppressed
NB. during fread, the \v is a problem.  We could charsub those. XXX

NB. Multi-line strings are not allowed -- phew.

lexemes =: LF -.~ noun define
(%.*)|
(-?[0-9]+(\.[0-9]+)?([eE]-?[0-9]+)?)|
(/?[a-zA-Z][-_a-zA-Z0-9]*)|
("[^"]*")|
([][{}])|
([ 	]+)|
.
)

digits =: '0123456789'
alpha  =: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

NB. *id_protector v
NB. Map a GML id into a J name uniquely and safely:
NB. map - and _ into _d_ and _u_ and add a safe "anti-locale" suffix.

id_protect =: monad define
  ((y. rplc '_';'_u_') rplc '-';'_d_') , '_x_xx'
)

NB. *token_analyze v
NB. Argument: an isolated token.
NB. Result is a boxed pair:  tokencode;token

token_analyze =: monad define
  first =. {. tk =. y.

  NB. We'll return negative type codes for elements to be
  NB. suppressed later.

  if. first='%' do.
     _1 ; tk
  elseif. first e. 9 10 11 13 32 { a. do.
     _2 ; a. i. tk
  elseif. first e. '-',digits do.
     NB. Number.
     NB. XXX shouldn't we separate ints and reals for
     NB. later correctness checking?
     ((+./ '.eE' e. tk) { 0 9 ) ; ". '-_' charsub tk
  elseif. first = '"' do.
     NB. String
     1 ; }.}: tk
  elseif. (<tk) e. 'true';'false' do.
     NB. Catch these constants before general keywords / ids.
     8 ; tk -: 'true'
  elseif. (<tk) e. operatorlist do.
     NB. Built-in operator.
     2 ; tk
  elseif. first e. alpha do.
     NB. Identifier.
     2 ; id_protect tk
  elseif. (first = '/') *. (#tk) > 1 do.
     3 ; '/', id_protect }. tk
  elseif. first e. '[]{}' do.
     NB. Some self-returning tokens.  Type code are 3..7.
     (4 + '[]{}' i. first) ; tk
  elseif. 1 do.
     NB. Whoa -- something yet unknown!  Give it a negative code:
     _3 ; '*unknown lexeme* :', tk
  end.
)

NB. clean_tokenlist v
NB. remove comments and unknowns, whatever has a negative code:
clean_tokenlist =: #~ (0: <: *@>@{."1)

NB. *tokenizer v
NB. Right argument is a filename.
NB. Optional Boolean left argument suppresses / activates (default)
NB. the removal of comments and such.
NB.
NB. Result is a list of boxed code;token pairs (goes into parser).
NB.
NB. 1. Cut the source text using the lexemes regexp.
NB. 2. Compute the code;token pair for each token.
NB.    Integers are told from flotas here, "-quotes are stripped,
NB.    and "-" are converted to "_" ...
NB. 3. supress comments
NB.
NB. sample usage (for now just step 1):
NB.    tokenizer <'gml/mini.gml'
NB. +-------------+--+-+----------+----+
NB. |% no comment.|17|4|% comment.|addi|
NB. +-------------+--+-+----------+----+

tokenizer =: verb define
  1 tokenizer y.
:
  tl =. token_analyze@> lexemes rxall freads y.

  NB. codes _1 (comments) and _2 (white space) are OK.
  NB. bail out on anything worse.
  codes =. > {."1 tl
  if. +./ codes < _2 do.
    1!:2&5 'lexical error', 10{a.
    2!:55 ]  1
  end.
  clean_tokenlist tl
)
