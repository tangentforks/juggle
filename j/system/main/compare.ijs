NB. comparison utilities
NB.
NB.   compare        compare character data
NB.   fcompare       compare files

NB. =========================================================
NB.*compare v compare character data
NB. returns list of differences.
NB. arguments may be character strings, with lines delimited
NB. by LF, or character matrices (trailing blanks ignored).
NB.
NB. for Mac, tolerates lines delimited by CR.
NB.
NB. result shows lines not matched, in form:
NB.    n [l] text
NB. where:
NB.    n    =  0=left argument, 1=right argument
NB.   [l]   =  line number
NB.   text  =  text on line

compare=: 4 : 0
if. x. -: y. do. 'no difference' return. end.
if. 0=#x. do. 'empty left argument' return. end.
if. 0=#y. do. 'empty right argument' return. end.

if. (LF e. ,x.) +. LF e. ,y. do.
  sep=. LF
else.
  sep=. CR
end.

dtb=. {.~ [: i.&1 [: *./\. =&' '
if. 2=#$x. do. x=. <@dtb"1 x.
else. x=. <;._2 x.,sep end.
if. 2=#$y. do. y=. <@dtb"1 y.
else. y=. <;._2 y.,sep end.

nx=. i.#x
bx=. x e. y
rx=. (-.bx)#x
sx=. (-.bx)#nx
nx=. bx#nx

ny=. i.#y
by=. y e. x
ry=. (-.by)#y
sy=. (-.by)#ny
ny=. by#ny

b=. (bx#x) =/ (by#y)

while. 1 do.
  
NB. flag lines swapped around exact matches:
  m=. -.(>./rb=. $b){.(<0 1)|:b
  b=. b *. rb{. =/~ (i.#m)-+/\m
  
NB. remove exact matches and lines not in both:
  sx=. sx,(-. b1=. +./"1 b)#nx
  nx=. (b1=. b1*.($b1){.m)#nx
  sy=. sy,(-. b2=. +./b)#ny
  ny=. (b2=. b2*.($b2){.m)#ny
  b=. b2#"1 b1#b
  if. 0 e. $b do. break. end.
  if. -. rb -: $b do. continue. end.
  
NB. if no change in loop, remove most likely line:
  t=. (2$rb=. >./$b){.b
  if. (0.5*+/,t) >: +/,t*</~i.rb do.
    sx=. sx,{.nx
    nx=. }.nx
    b=. }.b
  else.
    sy=. sy,{.ny
    ny=. }.ny
    b=. 0 1}.b
  end.
end.

NB. add remaining lines, sort, and format result:
ix=. '0 ['&,@(,&'] ')@": &.> sx=. sx,nx
iy=. '1 ['&,@(,&'] ')@": &.> sy=. sy,ny
r=. (ix,&.>sx{x),iy,&.>sy{y
r=. r /: (sx,.0),sy,.1
}:; r,&.>sep
)

NB. =========================================================
NB.*fcompare v compare 2 text files
NB. form: opt fcompare files
NB.   opt is optional suffix
NB.   files is 2 file names or prefixes
NB. example:
NB.   fcompare 'system/main/myutil.ijs /jbak/system/main/myutil.ijs'
NB.   '/myutil.ijs' fcompare 'system/main /jbak/system/main'
fcompare=: 3 : 0
'' fcompare y.
:
'x y'=. <"1 > _2 {. ,&x. &.> cutopen y.
f=. 1!:1 :: _1:
tx=. f <x
if. tx -: _1 do. 'unable to read ',x return. end.
ty=. f <y
if. ty -: _1 do. 'unable to read ',y return. end.
f=. _3&{.@('0'&,@(":@]))
mth=. _3[\'   JanFebMarAprMayJunJulAugSepOctNovDec'
'a m d h n s'=. 6{.1 pick dx=. ,1!:0 <x
fx=. (4":d),' ',(m{mth),'  ::' 0 3 6 9};f&.>100|a,h,n,s
'a m d h n s'=. 6{.1 pick dy=. ,1!:0 <y
fy=. (4":d),' ',(m{mth),'  ::' 0 3 6 9};f&.>100|a,h,n,s
r=. 'comparing:',LF
r=. r,x,fx,'  ',(":2 pick dx),LF
r=. r,y,fy,'  ',(":2 pick dy),LF
r,tx compare ty
)
