NB. labrtf
NB.
NB. rtf2par
NB. rtfclean
NB. rtfdepth
NB. rtfsegment
NB. rtfread

rtflparen=: '{'&= > _1: |. '\'&=
rtfrparen=: '}'&= > _1: |. '\'&=

rtf2par=: [: -.&CRLF ({.~ '\par'&E. i. 1:)
rtfdepth=: [: +/\ rtflparen - 0: , rtfrparen @ }:
rtfsegment=: <;.1~ [: (> 0: , }:) 0: = rtfdepth
rtfnextpar=: 5: + ('\par '&E.) i. 1:
rtftrail=: , [: #&'}' [: =/ [: +/ rtflparen ,. rtfrparen

RTFWELCOME=: 0 : 0
{\rtf42\ansi\deff0\deftab720{\fonttbl{\f42\froman Times New Roman;}
\deflang1033\pard\plain\f42\fs20}
{\colortbl\red0\green0\blue0;\red0\green0\blue255;}
)

NB. =========================================================
NB. get next section
NB. updates RTFSECTIONDATA and RTFTEXT
rtfgetsection=: 3 : 0
if. 0=#RTFSECTIONDATA do. return. end.
ndx=. {.,RXSMARKER rxmatch RTFSECTIONDATA
if. ndx=_1 do. return. end.
RTFSECTIONDATA=: (5+ndx) }. RTFSECTIONDATA
ndx=. rtfnextpar RTFSECTIONDATA
RTFSECTIONDATA=: ndx }. RTFSECTIONDATA
if. 0=#RTFSECTIONDATA do. return. end.

ndx=. {.,RXPAREN rxmatch RTFSECTIONDATA
ndx=. _1 -.~ ndx,{.,RXSMARKER rxmatch RTFSECTIONDATA

if. 0=#ndx do.
  RTFTEXT=: RTFTEXT,<rtftrail RTFSECTIONDATA
  RTFSECTIONDATA=: ''
else.
  ndx=. <./ndx
  j=. (ndx+5) {. RTFSECTIONDATA
  RTFTEXT=: RTFTEXT,<rtftrail j
  RTFSECTIONDATA=: ndx }. RTFSECTIONDATA
end.
)

NB. =========================================================
NB. text and rtflite from rtf
rtfclean=: 3 : 0
wd :: ] 'psel rtfconvert;pclose'
wd 'pc rtfconvert;cc r richeditm;set r *',y.
r=. 'r' wdget wd 'qd'
s=. wd 'qrtf r'
if. (+/rtflparen s) ~: +/rtfrparen s
do. s=. '{',s
end.
wd 'pclose'
r;s
)

NB. =========================================================
rtfcut=: 3 : 0
dat=. (>: y. i.'{') }. y.
dat=. (- >: (|.dat) i. '}') }. dat
rtfsegment dat
)

boxfind=: [: bx <@[ (1: e. E.)&> ]

NB. =========================================================
rtfscale=: 3 : 0
RTFSECTION=: y. NB. keep copy for later reference
if. FONTSCALE=1 do. y. return. end.
rtfscaler=: ": @ <. @ (0.5&+) @ (*&FONTSCALE) @ ".
('\\fs([[:digit:]]+)';,1) rtfscaler rxapply y.
)
