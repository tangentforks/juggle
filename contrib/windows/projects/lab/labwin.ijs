NB. run lab from a window

PTOP=: 1

LABWIN=: 0 : 0
pc labwin;
menupop "&Options";
menupop "Font";
menu largest "Larg&est" "" "" "";
menu larger "&Larger" "" "" "";
menu medium "&Medium" "" "" "";
menu smaller "&Smaller" "" "" "";
menu smallest "Sm&allest" "" "" "";
menupopz;
menusep ;
menu close "&Close Window" "" "" "";
menupopz;
xywh 4 3 11 9;cc down button;cn "&<<";
xywh 15 3 11 9;cc up button;cn "&>>";
xywh 29 4 15 9;cc index static;cn "(555)";
xywh 45 4 94 9;cc pos static rightmove;cn "555 of 555";
xywh 143 3 20 9;cc ptop checkbox leftmove rightmove;cn "&Top";
xywh 4 18 158 9;cc section static rightmove;cn "";
xywh 165 2 42 11;cc next button leftmove rightmove;cn "&Advance";
xywh 165 17 42 11;cc runline button leftmove rightmove;cn "&Run Selection";
xywh 0 29 210 100;cc text editm ws_border ws_vscroll rightmove bottommove;
pas 0 0;
rem form end;
)

NB. xywh 0 0 210 15;cc s0 staticbox ss_etchedframe rightmove;

NB. =========================================================
labwin_init=: 3 : 0
labwin=. LABWIN
if. IFCHAPTERS do.
  j=. 'menu chapter'&, @ ": each i.#CHAPTERS
  chaps=. ;j ,each ' "'&, @ (,&'";') each CHAPTERS
  txt=. 'menupop "&Chapters";',chaps
  labwin=. labwin rplc 'xywh 0 0';txt,'xywh 0 0'
end.
if. IFRTF do.
  wd labwin rplc 'editm';'richeditm'
else.
  wd labwin
  wd 'setfont text ',WINFONT
end.
wd 'setenable down 0'
wd 'setenable runline 0'
wd 'setcaption index'
wd 'setcaption pos'
wd 'setfocus next'
wd 'set ptop ',":PTOP
'labwin' wdmove _1, IFMAC { 0 20
wd 'pshow;ptop ',":PTOP
)

NB. =========================================================
labwin_open=: 3 : 0
if. -. wdifopen 'labwin' do. labwin_init'' end.
)

NB. =========================================================
labwin_output=: (1&$:) : (4 : 0)
labwin_open''
wd 'psel labwin;set text *', y.
wd 'pn *',WINTITLE
if. x. do.
NB.  j=. labchaptername''
NB.  j=. j, (*#j)#' - '
  wd 'pn *',WINTITLE
  wd 'setcaption section *',;labsection''
  wd 'setcaption pos *',labposition''
  wd 'setcaption index'
  LABWINPOS=: NDX
  wd 'setenable down ',":0<LABWINPOS
  wd 'setenable up ',":LABWINPOS<<:#SECTIONDATA
  wd 'setenable runline 1'

else.
  wd 'pn *',LABTITLE
end.
)

NB. =========================================================
labwin_close_button=: 3 : 0
LABWINDOWED=: 0
wd :: ] 'psel labwin;pclose'
)

labwin_cancel=: labwin_close=: labwin_close_button

NB. =========================================================
labwin_chapter_button=: labjump

NB. =========================================================
labwin_ptop_button=: 3 : 0
wd 'ptop ',ptop
PTOP=: ".ptop
)

NB. =========================================================
labwin_runline_button=: 3 : 0
sel=. ".text_select
if. =/sel do.
  ndx=. bx LF=text=. LF,text,LF
  ind=. +/ndx <: {.sel
  bgn=. >:(ind-1){ndx
  end=. ind{ndx
else.
  'bgn end'=. sel
end.
cmd=. bgn}.end{.text
cmd=. cmd #~ +./\cmd ~: ' '
tdo '0!:111 cmd'
)

NB. =========================================================
labwin_scalefont=: 3 : 0
FONTSCALE=: 1+0.1*y.
if. IFRTF do.
  wd 'set text *',rtfscale RTFSECTION
else.
  WINFONTSIZENOW=: <.0.5+FONTSCALE*WINFONTSIZE
  wd 'setfont text ',WINFONTSIZENOW setfontsize WINFONT
end.
)

labwin_largest_button=: labwin_scalefont bind 2
labwin_larger_button=: labwin_scalefont bind 1
labwin_medium_button=: labwin_scalefont bind 0
labwin_smaller_button=: labwin_scalefont bind _1
labwin_smallest_button=: labwin_scalefont bind _2

NB. =========================================================
labwin_down_button=: labwin_showpos bind _1
labwin_up_button=: labwin_showpos bind 1
labwin_showpos=: 3 : 0
LABWINPOS=: 0 >. (<:#SECTIONDATA) <. LABWINPOS+y.

if. IFRTF do.
  if. LABWINPOS >: #RTFTEXT do. rtfgetsection'' end.
  dat=. rtfscale RTFHDR,LABWINPOS pick RTFTEXT
else.
  dat=. _2 }. 0 pick labsplit LABWINPOS pick SECTIONDATA
end.

wd 'setenable down ',":0<LABWINPOS
wd 'setenable up ',":LABWINPOS<<:#SECTIONDATA

wd 'psel labwin;set text *',dat
wd 'setcaption index *(',(":LABWINPOS+1),')'
)

labwin_default=: 3 : 0
if. 'chapter' -: 7{.syschild do.
  labopenchapter ".7}.syschild
  labrun''
end.
)

NB. =========================================================
labwin_actrl_fkey=: labrun
labwin_next_button=: labrun
