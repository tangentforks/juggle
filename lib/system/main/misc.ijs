NB. miscellaneous utilities
NB.
NB.  addwmfheader  add metafile header to wmf file
NB.  boxcols       box columns of matrix
NB.  chop          chop array into boxed list
NB.  default       set default value
NB.  diff          differences
NB.  index         index
NB.  join          join boxed items
NB.  nubcount      nub + count
NB.  pathname      split DOS name into path;name
NB.  scriptform    script representation of names
NB.  show          show names using linear representation
NB.  subs          substitution
NB.  tolist        convert boxed list to LF delimited list

NB.*diff v differences
diff=: 2&(-~/\)

NB.*join v join boxed items
join=: ,.&.>/

NB.*nubcount v nub + count
nubcount=: ~. ;"_1 #/.~

NB.*pathname v split DOS name into path;name
pathname=: 3 : '(b#y.);(-.b=.+./\.y.=''/'')#y.'

NB.*tolist v convert boxed list to LF delimited list
tolist=: }. @ ; @: (LF&, @ , @ ": each)

NB. =========================================================
NB.*addwmfheader v add metafile header to wmf file
NB. form: [outfile] addwmfheader infile
NB.
NB. metafiles used by Word etc. require 22 byte header
NB.
NB. outfile addwmfheader infile ; width height (%1000 of inches)
addwmfheader=: 3 : 0
({.y.)addwmfheader y.
:
a=. 16bd7 16bcd 16bc6 16b9a 0 0 0 0 0 0, 1 0 3 2{,256 256 #: >1{y.
a=. a,232 3 0 0 0 0
a=. a, ([: ~:/&.#: ,)"1 |: 10 2$a
a=. a{a.
(a,1!:1 {.y.) 1!:2 boxopen x.
)

NB. =========================================================
NB.*boxcols v box columns of matrix
NB. y. is a matrix
NB. x. indicates partitions
NB.   - a single integer is size of each partition
NB.   - a boolean is beginning of each partition
NB. examples: 
NB.    3 boxcols i.3 7
NB. +--------+--------+--+
NB. | 0  1  2| 3  4  5| 6|
NB. | 7  8  9|10 11 12|13|
NB. |14 15 16|17 18 19|20|
NB. +--------+--------+--+
NB.
NB.    1 0 1 0 0 0 1 boxcols i.3 7
NB. +-----+-----------+--+
NB. | 0  1| 2  3  4  5| 6|
NB. | 7  8| 9 10 11 12|13|
NB. |14 15|16 17 18 19|20|
NB. +-----+-----------+--+
boxcols=: 3 : 0
1 boxcols y.
:
if. 1=#x. do.
  , ((0,x.),:x.,~#y.) <;.3 y.
else.
  x. <@|:;.1 |: y.
end.
)

NB. =========================================================
NB.*chop v chop array into boxed list
NB. chop character vector or matrix into boxed list.
NB. x. is optional delimiter, default LF if in text, else blank.
NB. If a matrix, the delimiter must be vertically aligned,
NB. otherwise use chop"1 to chop each row of the matrix.
NB. e.g.  chop ": 10 20 30
NB.       chop ": i. 5 4
chop=: 3 : 0
y. chop~ (' ',LF) {~ LF e. ,y.
:
if. 2>#$y.
do.
  (<'') -.~ (y e.x.) <;._2 y=. y.,{.x.
else.
  |: &.> y -. {: y=. (*./y e.x.) <;._2 |: y=. y.,"1 [ 2${.x.
end.
)

NB. =========================================================
NB.*default v set default value
NB. name default value
NB. set global name to value if not already defined
default=: 3 : 0
:
nc=. 4!:0 <x.
if. _1=nc do. ".x.,'=: y.'
elseif. _2=nc do. 'invalid name: ',":,x.
end.
empty''
)

NB. =========================================================
NB.*index v index where result is _1 if not found, instead of #x.
NB. example:
NB.    'abc' index 'ce'
NB.  2 _1
index=: #@[ (| - =) i.

NB. =========================================================
NB.*scriptform script representation of names
NB. representation using multi-line script form for most explicit
NB. definitions, otherwise linear representation.
NB. useful for writing object definitions to a script file.
scriptform=: 3 : 0
y.=. cutopen y.
r=. ''
rep=. 3 : '(4!:0 y.);(5!:2 y.);5!:5 y.'
dtb=. }.~ -@(i.&0)@(' '&=)@|.
edef=. 3&=@# *. e.&(0 1 2 3;"0<,':')@(2&{.)

while. #y. do.
  y=. {.y.
  y.=. }.y.
  'n b l'=. rep y
  
  tag=. ((>y),'=: ')&,@(,&CRLF)
  
  if. _2=n do. r=. r,tag 'invalid name' continue. end.
  if. _1=n do. r=. r,tag 'undefined' continue. end.
  if. edef b do.
    txt=. ;CRLF&,@dtb&.><"1 >{:b
    r=. r,tag (":n),' : 0',txt,CRLF,')'
    continue. end.
  r=. r,tag l
end.
r
)

NB. =========================================================
NB.*show v show names using linear representation
NB. show names using linear representation to screen width
NB. syntax:
NB.   show namelist  (e.g. show 'deb edit list')
NB.   show numbers   (from 0 1 2 3=nouns, adverbs etc)
NB.   show ''        (equivalent to show 0 1 2 3)
NB. useful for a quick summary of object definitions
show=: 3 : 0
y.=. y.,(0=#y.)#0 1 2 3
if. (3!:0 y.) e. 2 32 do. y.=. cutopen y.
else. y.=. (4!:1 y.) -. <,'y.' end.
wid=. {.wcsize ''
sub=. (1{a.)&((# i.@#)@(e.&(9 10 12 13{a.))@]})
j=. 'if. ((,0) -: 0=$y) *. 2=3!:0 y=. ".y. do. y return. end.'
j=. 'if. 0 = 4!:0 <y. do. ',j,' end. 5!:5 <y.'
rep=. sub @ (3 : j)
disp=. wid&{. @ (,&': ',rep)
disp &> y.
)

NB. =========================================================
NB.*subs c substitution 
NB. form: new (old subs test) data
NB. examples:
NB.    10 (2 subs =) 1 3 2 1 5 2
NB. 1 3 10 1 5 10
NB.    10 (2 subs <:) 1 3 2 1 5 2
NB. 1 10 10 1 10 10
NB. (from David Alis)
subs=: 2 : 0
:
n=. (#i.@#) m. v. y.
x. n } y.
)
