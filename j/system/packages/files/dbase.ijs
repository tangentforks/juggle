NB. dBASE file access utilities
NB.
NB. dbappend      append to file
NB. dbcreate      create file
NB. dbfld         read single field
NB. dbfmt         read and format records
NB. dbfmtcol      read and format records in columns
NB. dbfread       read fields
NB. dbinit        initialize file
NB. dbread        read records from file
NB. dbstate       state of workspace
NB. dbview        view file
NB.
NB. dbreadfld     read field utility

t=. 'dbappend dbcreate dbfld dbfmt dbfmtcol dbfread'
t=. t,' dbinit dbread dbstate dbview dbreadfld'
SCRIPTNAMES=. t

NB. dbappend
NB. Append records to dBASE file.
NB. Return number of records appended
NB. Updates global DBSTATE
NB. y. may be a single record as a character vector, or a matrix of records.
dbappend=: 3 : 0
('file';'len';'rcds';'rlen')=. 0 3 6 7{DBSTATE
rws=. #dat=. (_2{.1 1,$y.)$,y.

if. (-. ({:$dat) e. _1 0+rlen) do.
  'invalid record length' return. end.

dat=. ,(rws,-rlen){. dat
dat 1!:3 <file
rcds=. rcds+rws
(|.a.{~,(4$256)#: rcds) 1!:12 file;4
DBSTATE=: (<rcds) 6 } DBSTATE
rws
)

NB. dbcreate
NB. Syntax: hdr dbcreate filename
NB. Create a dBASE file, with a header but no records.
NB. If file already exists, it is erased and re-created.
NB.
NB. hdr is a 4 item boxed list:
NB.   0  field names (as boxed list)
NB.   1  field lengths
NB.   2  field decimals
NB.   3  field types (character)
NB. these set items 2-5 of DBSTATE
NB.
NB. if x. not given, values are read from DBSTATE
NB.
NB. Defines global DBSTATE for new file.
dbcreate=: 3 : 0
(2 3 4 5{DBSTATE) dbcreate y.
:
('fnms';'flen';'fdec';'ftyp')=. x.
file=. (y.-.' '),(-. '.' e.y.)#'.dbf'

fnms=. cutopen fnms
rws=. #fnms
nams=. (rws,11){.>fnms
hlen=. 33+32*rws
rcds=. 0
rlen=. >:+/flen
ver=. 131
ts=. 3{.6!:0 ''

hdr=. 32{.ver,(100|ts),(4#0),,|."1 [ 256 256#:hlen,rlen
(hdr{a.) 1!:2 <file

a0=. {.a.
fdr=. ($nams)$ a0 ((# i.@#) ,nams=' ') } ,nams
fdr=. fdr,.ftyp
fdr=. fdr,"1 [ 4#a0
fdr=. fdr,"1 (flen,.fdec){a.
fdr=. fdr,"1 [ 14#a0
((,fdr),CR) 1!:3 <file

empty DBSTATE=: file;hlen;fnms;flen;fdec;ftyp;rcds;rlen
)

NB. dbfld
dbfld=: 3 : 0
NB. read single field from dBASE file
NB. 1-column fields are returned as vectors
:
]`, @. (1&=@{:@$) > {. x. dbfread y.
)

NB. dbfmt
dbfmt=: 3 : 0
NB. read and format fields from dBASE file
NB.
NB. y. = record indices, default all
NB. x. = field names, default all
NB.      ~field names = exclude fields
'' dbfmt y.
:
cmp=. #"1~ [: (+./\  *. +./\.) ' '& (+./ . ~: )
fnms=. >2{DBSTATE
not=. '~' e. flds=. x.
flds=. ', ' cutopen flds
if. not do. flds=. fnms -. flds end.
flds=. flds,(0=#flds)#fnms
flds ,: cmp &.> flds dbreadfld y.
)

NB. dbfmtcol
dbfmtcol=: 3 : 0
NB. read and format fields from dBASE file, in columns
NB.
NB. y. = record indices, default all
NB. x. = field names, default all
NB.      ~field names = exclude fields
'' dbfmtcol y.
:
cmp=. #"1~ [: (+./\ *. +./\.) ' '& (+./ . ~: )
fnms=. >2{DBSTATE
not=. '~' e. flds=. x.
flds=. ', ' cutopen flds
if. not do. flds=. fnms -. flds end.
flds=. flds,(0=#flds)#fnms
cmp &.> <@:>"1 |: flds ,. <"1&> flds dbreadfld y.
)

NB. dbfread
dbfread=: 3 : 0
NB. read fields from dBASE file, returning column vectors
NB.
NB. y. = record indices, default all
NB. x. = field names, default all
NB.
NB. character and numeric fields are returned as is.
NB. date fields are returned as numeric in form yyyymmdd.
NB. logical fields are returned as 1 character.
NB. memo fields are returned as 10 digit block numbers.
NB. blank numeric fields are returned as 0.
NB.
NB. e.g. 'name,sex,dob' dbfread i.10
NB.
'' dbfread y.
:
typ=. lnd=. ''
('fnms';'ftyp')=. 2 5{DBSTATE
if. #x. do.
  flds=. ', ' cutopen x.
  ind=. fnms i. flds
else.
  ind=. i.#fnms
end.
r=. ind dbreadfld y.
typ=. ind{ftyp
ind=. (#i.@#) typ e. 'dmn'
if. #ind do.
  fi=. 0 & ".
  s=. (,.@:fi)&.> ind{r
  r=. s ind }r
end.
r
)

NB. dbinit
dbinit=: 3 : 0
NB. initialize dBASE file
NB. global DBSTATE is:
NB.   0{ file name
NB.   1{ header length
NB.   2{ field names
NB.   3{ field lengths
NB.   4{ field decimals
NB.   5{ field types (character)
NB.   6{ number of records
NB.   7{ record length
UC=. 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',a.
LC=. 'abcdefghijklmnopqrstuvwxyz',a.
lower=. {&LC @ (UC&i.)
y=. >y.
y=. y,(-.'.' e. y )#'.dbf'
hdr=. 1!:11 :: _1: y;0 32
if. hdr -: _1 do. wdinfo 'file read error: ',y return. end.
hdr=. a.i. hdr
rcds=. 256#.7 6 5 4{hdr
hlen=. 256#.9 8{hdr
rlen=. 256#.11 10{hdr
hdr=. a.i. 1!:11 y;32,hlen-32
bgn=. 32*i.<.(hlen-33)%32
fnms=. ;: ,' ',.lower (32>.(bgn+/i.11){hdr){a.
ftyp=. lower ((bgn+11){hdr){a.
flen=. (bgn+16){hdr
fdec=. (bgn+17){hdr
empty DBSTATE=: y;hlen;fnms;flen;fdec;ftyp;rcds;rlen
)

NB. dbread
dbread=: 3 : 0
NB. read records from dBASE file as a character matrix
NB. y. is a list of records indices, default all
NB. e.g. dbread 0 1 3 = read records 0 1 and 3
(<;._2 'file hlen rcds rlen ')=. 0 1 6 7{DBSTATE
max=. <.100000%rlen
r=. i.0,rlen
if. 0=#ndx=. ,y. do.
  b=. rcds#1
  s=. nub=. ndx=. i.rcds
else.
  nub=. ~. ndx=. (ndx<rcds)#ndx
  nub=. (s=. /:nub) { nub
  b=. 1 nub } rcds#0
end.

b=. (bgn=. b i. 1)}.(-(|.b)i. 1)}.b
if. -. 1 e. b do. r return. end.

while. #b do.
  b1=. (max <. $b) {. b
  b1=. (-(|.b1)i.1)}.b1
  r=. r,b1#(n,rlen)$ 1!:11 file;(hlen+rlen*bgn),rlen*n=.#b1
  b=. (n=. b i.1)}.b=. max}.b
  bgn=. bgn+max+n
end.

}."1 (nub i. ndx) {r
)

NB. dbreadfld
dbreadfld=: 3 : 0
NB. read fields from dBASE file, returning column vectors
NB. utility referenced by other dBASE functions
NB.
NB. y. = record indices, default all
NB. x. = field names or indices, default all
NB.
NB. e.g. 'name,sex,dob' dbreadfld i.10
NB.
'' dbreadfld y.
:
(<;._2 'file hlen fnms flen rcds rlen ')=. 0 1 2 3 6 7{DBSTATE
bx=. #i.@#
max=. <.100000 % rlen

ind=. flds=. >(0=#x.){x.;i.#fnms
if. (2&= +. 16&<) 3!:0 flds do.
  flds=. ' ,' cutopen flds
  ind=. fnms i. flds
end.

s=. ndx=. nub=. i. #b=. rcds#1
if. #y. do.
  nub=. ~. ndx=. (y.<rcds)#y.
  nub=. (s=. /:nub) { nub
  b=. 1 nub } rcds#0
end.

if. -. 1 e. b do. (#ind)#<i.0 0 return. end.

len=. ind{flen
fi=. (ind{>:0,+/\flen)+&.>i.&.>len
fi=. (rlen*i.max<.n=. +/b)+/;fi
scn=. +/\len
b=. (bgn=. b i. 1)}.b
r=. i.0 0

while. #b do.
  b1=. (max<.#b){.b
  b1=. (-(|.b1)i.1)}.b1
  blk=. (hlen+rlen*bgn),rlen*n=. #b1
  j=. b1#(n,rlen)$ 1!:11 file;blk
  r=. r,((#j){.fi){,j
  b=. (n=. b i. 1)}.b=. max}.b
  bgn=. bgn+max+n
end.

r=. |: (nub i. ndx){r
b=. 1 (0,}:scn) } (#r)#0
|:&.>(+/\b) </. r
)

NB. dbstate
dbstate=: 3 : 0
NB. state of dBASE file
'f c l'=. 0 6 7 {DBSTATE
h=. a.i. 1!:11 f;0 4
p=. 18&{.@(,&':')@[ , ":@]
r=. ,:'file' p f
r=. r,'version' p ((16 16#:{.h){'0123456789ABCDEF'),'H'
r=. r,'last update' p 1900 0 0 + 1 2 3{h
r=. r,'number records' p c
r=. r,'record length' p l
'n l d t'=. 2 3 4 5{DBSTATE
s=. ' ',. 12{.&>n
SS=: s
s=. s,. t,"0 1 ' '
s=. s,.' ',.' ',. ":,.l+d%10
(>r),'fieldname  type length',s
)

NB. dbview
dbview=: 3 : 0
'' dbview y.
NB. view dBASE file
NB.
NB. y. = record indices, default all
NB. x. = field names, default all
NB.      ~field names = exclude fields
:
wdview ,(": x. dbfmt y.),.CR
)
