NB. font form

NB. =========================================================
NB. boxfont    box fontspec
boxfont=: 3 : 0
font=. ' ',y.
b=. (font=' ') > ~:/\font='"'
a: -.~ b <;._1 font
)

NB. =========================================================
NB. getfontstyle font
getfontstyle=: 3 : 0
if. 0=#y. do.'' return. end.
y=. boxfont y.
y=. ({.y),tolower each }.y
s=. (#~ e.&y) 'oem';'default'
{.s,<'ansi'
)

NB. =========================================================
NB. mbfont
mbfont=: 3 : 0
if. #y. do.
  y.=. boxfont y.
  y.=. ({.y.), tolower each }.y.
  y.=. y. -. 'ansi';'oem';'default'
  y.=. }: ; ,&' ' &.> y.
end.
r=. wd 'mbfont ',y.
r=. r, (0=#r)#LABFONT
)

NB. =========================================================
NB. setfontstyle font
setfontstyle=: 4 : 0
if. 0=#y. do.'' return. end.
x=. boxopen x.
y=. boxfont y.
y=. ({.y), tolower each }.y
y=. y -. 'ansi';'oem';'default'
y=. y,(x e. 'oem';'default')#x
}: ; ,&' ' &.> y
)

NB. =========================================================
TFONT=: 0 : 0
pc tfont closeok dialog owner;pn "Configure View";
xywh 8 26 110 11;cc edfont edit ws_border es_autohscroll rightmove;
xywh 8 39 34 11;cc vansi radiobutton;cn "Ansi";
xywh 47 39 34 11;cc voem radiobutton group;cn "OEM";
xywh 86 39 34 11;cc vdefault radiobutton group;cn "Default";
xywh 124 25 34 11;cc browse button leftmove rightmove;cn "&Browse";
xywh 124 7 34 11;cc ok button leftmove rightmove;cn "OK";
xywh 8 16 40 8;cc s0 static;cn "Select Font:";
pas 6 6;pcenter;
rem form end;
)

NB. =========================================================
tfont_run=: 3 : 0
wd TFONT
setviewstyle getfontstyle LABFONT
wd 'set edfont *',LABFONT
wd 'pshow;'
)

NB. =========================================================
tfont_browse_button=: 3 : 0
edfont=: mbfont edfont
viewstyle VSTYLE
)

NB. =========================================================
tfont_ok_button=: 3 : 0
LABFONT=: edfont
try. wd 'psel tfont;pclose' catch. end.
wd 'psel author'
author_setfont''
tshow 1
)

NB. =========================================================
tfont_close=: tfont_ok_button
tfont_vansi_button=: viewstyle bind 'ansi'
tfont_vdefault_button=: viewstyle bind 'default'
tfont_voem_button=: viewstyle bind 'oem'

NB. =========================================================
viewstyle=: 3 : 0
setviewstyle y.
wd 'set edfont *',VSTYLE setfontstyle edfont
)

NB. =========================================================
setviewstyle=: 3 : 0
VSTYLE=: boxopen y.
wd 'set vansi ',":VSTYLE = <'ansi'
wd 'set vdefault ',":VSTYLE = <'default'
wd 'set voem ',":VSTYLE = <'oem'
)
