NB. data validation
NB.
NB. verbs return 1 if true, 0 if false
NB.
NB. data type verbs check the data, not the internal representation.
NB. For example, 1j1-0j1 is considered boolean, though stored as complex.
NB.
NB. e.g.
NB.   5 10 inrange i.12
NB.   '()' isbalanced '(123(45))'

NB.* inrange      v  (low, high) inrange data
NB.* isbalanced   v  pair isbalanced string
NB.* isboolean    v  data is all 0 or 1
NB.* isboxed      v  is boxed
NB.* ischaracter  v  data is character
NB.* iscounter    v  data is non-negative integer (counting number)
NB.* iscomplex    v  data is complex
NB.* isdate       v  is date (as yyyy mm dd)
NB.* isinteger    v  data is all integer
NB.* ismatrix     v  data is a matrix
NB.* isnumeric    v  data is numeric
NB.* isreal       v  data is all real
NB.* isscalar     v  data is a scalar
NB.* isvector     v  data is a vector

inrange=: ([: *./ (>: {.) , (<: {:))~
isbalanced=: [: (-: +/\. + 0: >. +/\) [: -/ =/

isboxed=: 0: < L.

isboolean=: [: *./ , e. 0 1"_
ischaracter=: 3!:0 = 2:
iscounter=: -: |@<.
isinteger=: -: <.
isnumeric=: 3!:0 e. 1 4 8 16"_
isreal=: -: +
iscomplex=: -. @ isreal f.

isscalar=: 0: = #@$
isvector=: 1: = #@$
ismatrix=: 2: = #@$

isdate=: 3 : 0
'y m d'=. y.
b=. *./(y.=<.y.),(_1 0 0<y.),12>:m
day=. (13|m){0 31 28 31 30 31 30 31 31 30 31 30 31
day=. day+(m=2)*-/0=4 100 400|/y
b*d<:day
)
