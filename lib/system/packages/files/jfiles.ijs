NB. Component File definitions
NB. built from project: source\jfiles\jfiles

jappend=: jappend_jfiles_
jcreate=: jcreate_jfiles_
jdup=: jdup_jfiles_
jerase=: jerase_jfiles_
jread=: jread_jfiles_
jreplace=: jreplace_jfiles_
jsize=: jsize_jfiles_


coclass 'jfiles'

jappend=: 4 : 0
'h o'=. j_open y.
if. h=_1 do. return. end.
'v s c l d f q'=. j_dir h
free=. j_read h;f
if. 32 > 3!:0 x. do. x.=. <x.
else. if. 1<#$x. do. _3 return. end.
end.
res=. c+ i.#x.
'l free new'=. x. j_writerep l;free;h
dat=. j_tochar ,new
'b e'=. d
if. e>8*{:res do.
  dat 1!:12 h;b+8*c
  (j_rep free) 1!:12 h;{.f
else.
  dat=. (1!:11 h;b,8*c),dat
  free=. j_compress d,f,free
  'l free new'=. (<dat) j_write l;free;h
  'l f'=. j_writefree l;free;h
  d=. ,new
end.
c=. >:{:res
q=. >:{.q,0
(j_rep v;s;c;l;d;f;q) 1!:12 h;0
if. o do. jclose h end.
j_validate y.
res
)

jclose=: 1!:22

jcreate=: 3 : 0
0 jcreate y.
:
q=. s=. c=. 0
d=. 256,>.&.(2&^.) 512>.8*x.
f=. (+/d),256
l=. +/f
v=. 1718235185
hdr=. ({.f){.j_rep v;s;c;l;d;f;q;s
hdr=. l{.hdr,j_rep i.0 2
y=. <j_name y.
1!:55 :: 0: y
f=. (1: [ 1!:2) :: 0:
hdr f y
)

jdup=: 3 : 0
'' jdup y.
:

'y sel'=. 2{.boxopen y.
y=. j_name y

if. own=. 0=#x. do.
  x.=. ((+./\.y='\')#y),'eraseme.pls'
end.

'h o'=. j_open y
if. h=_1 do. return. end.

if. #sel do.
  (c=. #sel) jcreate x.
  hx=. jopen x.
  whilst. #sel=. }.sel do.
    (jread h;{.sel) jappend hx
  end.

else.
  'v s c l d f q'=. j_dir h
  c jcreate x.
  hx=. jopen x.
  pos=. 0
  blk=. 1000
  max=. 100000
  read=. j_read@(h&;)
  while. c > pos do.
    j=. (({.d)+8*pos),8*blk<.c-pos
    dir=. _2[\ j_tonum 1!:11 h;j
    pos=. pos+blk
    while. #dir do.
      siz=. {:"1 dir
      len=. 1>.(max<+/\siz)i.1
      (read &.> <"1 len{.dir) jappend hx
      dir=. len}.dir
    end.
  end.

end.

jclose hx
if. o do. jclose h end.

if. own do.
  pos=. 0
  siz=. 1!:4 <x.
  '' 1!:2 <y
  while. siz>pos do.
    len=. max<.siz-pos
    (1!:11 x.;pos,len) 1!:3 <y
    pos=. pos+max
  end.
  1!:55 <x.
end.

j_validate x.
c
)

jerase=: 1!:55 @ < @: j_name

jopen=: 3 : 0
y=. >y.
if. 0 e. #y do. _1 return. end.
if. 2=3!:0 y do.
  y=. <y,(-.'.'e.y)#'.ijf'
  f=. 1!:21 [ 1!:11 @ (,&(<0 0))
  f :: _1: y
end.
)

jread=: 3 : 0
'y x'=. y.
'h o'=. j_open y
if. h=_1 do. return. end.
'v s c l d f q'=. j_dir h
cpt=. ,x
if. 1 e. (cpt<0) +. cpt>:c
do. _2 return. end.
dir=. h j_readdir &.> ({.d)+cpt*8
dat=. j_read@(h&;) &.> dir
if. o do. jclose h end.
($x)$dat
)

jreplace=: 4 : 0
'y x'=. y.
'h o'=. j_open y
if. h=_1 do. return. end.
'v s c l d f q'=. j_dir h
free=. j_read h;f
cpt=. ,x
if. 0=#cpt do. return. end.
if. 1 e. (cpt<0) +. cpt>:c
do. _2 return. end.
if. 32 > 3!:0 x. do. x.=. <x.
else. if. 1<#$x. do. _3 return. end.
end.
x.=. (#cpt)$x.
dir=. >h j_readdir &.> ({.d)+cpt*8
free=. j_compress dir,f,free
'l free new'=. x. j_writerep l;free;h
new=. _8 <\ j_tochar ,new
new (1!:12 h&;) &.> ({.d)+cpt*8
'l f'=. j_writefree l;free;h
q=. >:{.q,0
(j_rep v;s;c;l;d;f;q) 1!:12 h;0
if. o do. jclose h end.
j_validate >{.y.
cpt
)

jseqno=: 3 : 0
'h o'=. j_open y.
if. h=_1 do. return. end.
q=. >6{j_dir h
if. o do. jclose h end.
q
)

jsize=: 3 : 0
'h o'=. j_open y.
if. h=_1 do. return. end.
'v s c l d f q'=. j_dir h
free=. j_read h;f
if. o do. jclose h end.
s,c,l,{:+/free
)


j_blk=: >.&.(2&^.)@#
j_dir=: [: 7&{. [: 3!:2 [: 1!:11 ;&0 256
j_nos=: [: ; [: {."1 (1!:20)
j_read=: 3!:2 @ (1!:11)
j_readdir=: ((&;) (j_tonum@(1!:11)@)) (@(,&8))
j_rep=: 3!:1
j_tonum=: _2&(3!:4)
j_tochar=: 2&(3!:4)
j_writerep=: j_rep&.>@[ j_write ]

j_compress=: 3 : 0
bgn=. {."1 f=. /:~ y.
b=. bgn ~: _1|.+/"1 f
if. 0 e. b do.
  f=. (b#bgn) ,. b +/;.1 {:"1 f
end.
f /: {:"1 f
)

j_name=: 3 : 0
y=. >y.
if. 2=3!:0 y do.
  y=. y,(-.'.'e.y)#'.ijf'
end.
)

j_open=: 3 : 0
y=. >y.
if. 0 e. #y do. _1 return. end.
if. 2=3!:0 y do.
  y=. y,(-.'.'e.y)#'.ijf'
  j=. 1!:11 :: _1: y;0 0
  if. _1 -: j do. return. end.
  n=. ;{."1 [ 1!:20''
  h=. 1!:21 <y
  h,-.h e. n
else.
  y,0
end.
)

j_validate=: 3 : 0
'h o'=. j_open y.
if. h=_1 do. return. end.
'v s c l d f q'=. j_dir h
free=. j_read h;f
dir=. _2[\ j_tonum 1!:11 h;({.d),8*c
r=. /:~ f,d,dir,free
y=. 256,+/"1 r
if. o do. jclose h end.
13!:8 [ 12 }.~ y -: ({."1 r),l
)

j_validate=: ]

j_write=: 4 : 0
'l f h'=. y.
x=. ,x.
d=. i.0 2

while. #x do.
  blk=. j_blk dat=. >{.x
  x=. }.x
  if.
    (#f) > ndx=. 1 i.~ blk <: {:"1 f
  do.
    'p s'=. ndx{f
    d=. d,p,blk
    if. blk < s do.
      f=. ((p+blk),s-blk) ndx } f
    else.
      f=. (ndx{.f),(>:ndx)}.f
    end.
    dat 1!:12 h;p
  else.
    d=. d,l,blk
    l=. l+blk
    (blk{.dat) 1!:3 h
  end.
end.

l;f;d
)

j_writefree=: 3 : 0
'l f h'=. y.

blk=. 256 >. j_blk dat=. j_rep f
if.
  (#f) > ndx=. 1 i.~ blk <: {:"1 f
do.
  'p s'=. ndx{f
  d=. p,blk
  if. blk < s do.
    f=. ((p+blk),s-blk) ndx } f
  else.
    f=. (ndx{.f),(>:ndx)}.f
  end.
  (j_rep f) 1!:12 h;p
else.
  d=. l,blk
  l=. l+blk
  (blk{.dat) 1!:3 h
end.

l;d
)
