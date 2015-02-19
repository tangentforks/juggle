NB. color fmt functions
NB.
NB. colors 0-7 = black,blue,green,cyan,red,purple,brown,white

coclass 'cfmt'

FONTSIZE=: 24
FONTBOLD=: 1

addLF=: , @: (,"1)&LF

flatten=: 3 : 0
dat=. ": y.
if. 2 > #$dat do. return. end.
dat=. 1 1}. _1 _1}. ": <dat
}: (,|."1 [ 1,.-. *./\"1 |."1 dat=' ')#,dat,.LF
)

rplc=: 4 : 0
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

NB. =========================================================
RTFHDR=: 0 : 0
{\fonttbl{\f0\fcourier Courier New;}}
{\colortbl
\red0\green0\blue0;
\red0\green0\blue255;
\red0\green127\blue0;
\red0\green127\blue127;
\red255\green0\blue0;
\red127\green0\blue127;
\red127\green127\blue;
\red255\green255\blue255;}
\f0
)

rtfwrap=: '{'&, @ (,&'}')
rtfpara=: rplc & (LF;'\par ')

NB. =========================================================
CFMT=: 0 : 0
pc cfmt closeok;
xywh 206 0 34 12;cc cancel button leftmove rightmove;cn "Close";
xywh 34 0 34 12;cc fontup button;cn "&>>";
xywh 0 0 34 12;cc fontdown button;cn "&<<";
xywh 0 12 240 180;cc fmt richeditm ws_hscroll ws_vscroll es_autohscroll es_autovscroll es_sunken rightmove bottommove;
pas 0 0;pcenter;
rem form end;
)

cfmt_run=: 3 : 0
wd CFMT
wd 'set fmt *',y.
wd 'pshow;'
)

cfmt_cancel_button=: 3 : 0
wd 'pclose;'
)

cfmt_fontup_button=: 3 : 0
cfmtit FONTSIZE=: FONTSIZE+2
)

cfmt_fontdown_button=: 3 : 0
cfmtit FONTSIZE=: 6 >. FONTSIZE-2
)

NB. =========================================================
cfmt=: 3 : 0
0 cfmt y.
:
if. -. 1 e. (<'cfmt') e. wd 'qp' do.
  wd CFMT
end.
RTFDAT=: y.
RTFCLR=: x.
cfmtit''
wd 'pshow'
)

NB. =========================================================
cfmtit=: 3 : 0
t=. addLF '\fs',":FONTSIZE
t=. t,FONTBOLD#'\b',LF
if. 1=#RTFCLR do.
  t=. t,addLF '\cf',": RTFCLR
  t=. t,rtfpara addLF ": RTFDAT
else.
  dat=. (flatten RTFDAT),LF
  dat=. ((> (}. , 0:)) -. dat e. LF,' ') < ;.2 dat
  clr=. ,($RTFDAT)$,RTFCLR
  clr=. '\cf'&,@(,&' ')@": each clr
  dat=. rtfwrap each clr ,each dat
  t=. t,rtfpara ;dat
end.
wd 'set fmt *',rtfwrap RTFHDR,t
)
