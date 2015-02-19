NB. latinit  lab author init

LABFONT=: getconfig_j_ 'SMFONT'

LATPATH=: JDIR_j_,'system\extras\labs\'
LATNAME=: 'Lab Author'

LATCFG=: 'system\extras\config\laconfig.ijs'
MAXRECENT=: 10
XLATRECENT=: LATRECENT=: ''

SOUNDBITES=: ''

NB. unwrap text:
UNWRAPIT=: 0
UNWRAP=: ''

NB. if new section prompt given:
IFNEWSECTION=: 0

NB. author does not support RTF:
IFRTF=: 0

NB. =========================================================
tinfo=: wdinfo @ (LATNAME&;)
tquery=: [ wdquery (LATNAME&;@])
tclean=: #~ [: -. [: *./\. e.&(' ',LF)
tpartition=: 1: , 2: ~:/\ ]

NB. =========================================================
flread=: (1!:1 :: _1:) @ boxopen
flwrite=: (1!:2 :: _1:) boxopen

NB. =========================================================
flreads=: 3 : 0
y.=. boxopen y.
dat=. (1!:1) :: _1: y.
if. (dat -: _1) +. 0=#dat do. return. end.
dat,LF -. {:dat=. toJ dat
)

NB. =========================================================
NB. writes text to file (if changed)
flwrites=: 4 : 0
if. -. 0 e. $x. do.
  if. 1>:#$x. do.
    x.=. toHOST x.
    x.=. x.,(LF ~: {:x.)#CRLF
  else. x.=. x.,"1 CRLF
  end.
end.
x. flwritenew y.
)

NB. =========================================================
NB. writes data to file (if changed)
flwritenew=: 4 : 0
x.=. ,x.
if. -. x. -: flread y. do. x. flwrite y. end.
)

NB. =========================================================
pack=: [: /:~ [: (, ,&< ".)&> ;:^:(L. = 0:)

NB. =========================================================
rplc=: 4 : 0
NB. replace characters in text string
NB. syntax: text rplc old;new
'o n'=. ,&.>y.
l=. #o
c=. o E. x=. ,x.
if. (0<l) *: 1 e. c do. x return. end.
bx=. #i.@#
c=. bx c
while. 0 e. d=. 1,<:/\(#o)<:(}.-}:)c
do. c=. d#c end.
p=. (i.#x) e. 0,c
x=. p <;.1 x
b=. o&-:@(l&$) &> x
f=. n&,@(l&}.) &.>
;(f b#x) (bx b) }x
)
