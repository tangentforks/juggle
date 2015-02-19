NB. file read/write in various formats
NB.
NB. read files in various formats
NB. write files in J internal formats
NB.
NB.  [opt] nread fl      read file
NB.   dat  nappend fl    append file
NB.   dat  nwrite fl     write file
NB.
NB.   opt = 11    1-bit boolean
NB.         82    8-bit character
NB.         163  16-bit integer     (read only)
NB.         323  32-bit integer
NB.         645  64-bit floating point
NB.
NB. 1-bit booleans are assumed of length a multiple of 8,
NB. i.e. an integral number of bytes

NB. nread file
nread=: 3 : 0
82 nread y.
:
dat=. 1!:1 boxopen y.
if. x.=11 do. ,(8#2)#:a.i.dat
elseif. x.=82  do. dat
elseif. x.=163 do. _1 (3!:4) dat
elseif. x.=323 do. _2 (3!:4) dat
elseif. x.=645 do. _2 (3!:5) dat
elseif. 1 do. 'invalid left argument'
end.
)

NB. nappend file
NB. left argument is data
nappend=: 4 : 0
dat=. ,x.
type=. 3!:0 dat
if. type=1 do.
  rws=. >.(#dat)%8
  dat=. 2#.(rws,8)$(rws*8){.dat
  dat=. dat { a.
elseif. type ~: 2 do.
  dat=. 20}.3!:1 dat
end.
dat 1!:3 boxopen y.
)

NB. nwrite file
NB. left argument is data
nwrite=: 4 : 0
'' 1!:2 boxopen y.
x. nappend y.
)
