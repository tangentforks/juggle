NB. name that color (displays color table)
NB. showcolor   - show colors

require 'colortab'
require 'gl2'
load 'system/packages/color/rgb.ijs'

NB. ============================================================
NB. base form
NTC=: 0 : 0
pc ntc closeok;pn "ntcolor";
xywh 6 10 148 146;cc clr listbox ws_vscroll rightscale bottommove;
xywh 165 9 49 53;cc g0 groupbox leftscale rightscale;cn "Sort By";
xywh 171 18 40 9;cc name radiobutton leftscale rightscale;
xywh 171 28 40 9;cc red radiobutton group leftscale rightscale;
xywh 171 38 40 9;cc green radiobutton group leftscale rightscale;
xywh 171 48 40 9;cc blue radiobutton group leftscale rightscale;
xywh 225 9 34 11;cc cancel button leftmove rightmove;cn "Close";
xywh 163 72 50 9;cc scale static leftscale rightmove;cn "Nearest integer";
xywh 225 69 34 11;cc sixes button leftmove rightmove;cn "Scale";
xywh 163 85 97 64;cc gcolors isigraph leftscale rightmove bottommove;
pas 4 0;pcenter;
rem form end;
)

ntc_run=: 3 : 0
if. 0 e. $y. do.
  dat=. COLORTABLE
else.
  dat=. y.
  if. 2 ~: 3!:0 dat do.
    f=. }.@":@(1000&+)
    dat=. (>'color'&, @ (,&'=:  ') @ f each i.#dat),.":dat
  end.
end.
SIXES=: 0
ndx=. dat i. "1 '='
COLORNMS=: (20 >. 2+>./ndx) {."1 ndx {."0 1 dat
COLORVAL=: ".@(}.~ [: >: i.&':')"1 dat
COLORVORG=: COLORVAL
COLORNDX=: i.#dat
j=. getconfig_j_ :: (''"_) 'SMFONT'
font=. j,(0 e. #j)#'Terminal 9 oem'
wd NTC
wd 'setfont clr ',font
wd 'set clr *',,(COLORNMS,.":COLORVAL),.LF
wd 'setfocus clr'
wd 'setselect clr 0'
glmark''
ntc_color 0
wd 'pshow;'
)

ntc_cancel_button=: wd bind 'pclose'

ntc_color=: 3 : 0
clr=. (y. { COLORNDX) { COLORVAL
glmarkc''
glrgb clr
glbrush''
glrect 0 0 1000 1000
glshow''
)

ntc_clr_button=: 3 : 0
ntc_color ".clr_select
)

ntc_clr_select=: ntc_enter=: ntc_clr_button

ntc_show=: 3 : 0
0 ntc_show y.
:
wd 'set clr *',,(COLORNDX{COLORNMS,.":COLORVAL),.LF
wd 'setselect clr ',":x.
ntc_color x.
)

ntc_name_button=: 3 : 0
ntc_show COLORNDX=: /: COLORNMS
)

ntc_red_button=: 3 : 0
ntc_show COLORNDX=: \: COLORVAL
)

ntc_green_button=: 3 : 0
ntc_show COLORNDX=: \: 1 0 2{"1 COLORVAL
)

ntc_blue_button=: 3 : 0
ntc_show COLORNDX=: \: 2 0 1{"1 COLORVAL
)

ntc_sixes_button=: 3 : 0
SIXES=: 4 | >: SIXES
if. SIXES e. 1 2 3 do.
  n=. 8 * 2 ^ SIXES
  COLORVAL=: 255 <. n * <. 0.5 + COLORVORG % n
else.
  COLORVAL=: COLORVORG
end.
wd 'set scale *Nearest ',SIXES pick 'integer';'16';'32';'64'
(".clr_select) ntc_show ''
)

ntcolor=: ntc_run

NB. ============================================================
NB. showcolor    - show colors
NB.
NB. showcolor colormatrix
NB.
NB. colormatrix is a single RBG triplet, or 3 column matrix of RGB triplets
NB.
NB. e.g.  showcolor ?100 3$255
NB.       showcolor 36{. ". 20}."1 COLORTABLE
showcolor=: 3 : 0
y.=. (_2{.1,$y.)$,y.
num=. #y.
rws=. <. %: num
cls=. >. num % rws
irws=. 1000 % rws
icls=. 1000 % cls
xy=. > , |: { (irws * i.rws);icls * |. i.cls
rect=. <. 0.5 + num {. xy,"1 irws,icls
wd 'pc showcolor closeok owner'
wd 'xywh 0 0 200 150;cc g0 isigraph rightmove bottommove;'
wd 'pas 0 0;pcenter;ptop;'
cmd=: glrect@[ glbrush@glrgb
rect cmd"1 y.
glshow''
wd 'pshow'
)
