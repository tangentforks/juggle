NB. labsel.ijs      - main selection dialog

LABSEL=: 0 : 0
pc labsel closeok;pn "Lab Select";
xywh 11 12 93 11;cc s0 static;cn "Select a lab";
xywh 110 10 63 12;cc intro button leftmove rightmove;cn "&Intro to Labs";
xywh 7 3 171 23;cc g0 groupbox rightmove;cn "";
xywh 11 39 31 9;cc s1 static;cn "Category:";
xywh 45 38 80 109;cc category combodrop ws_vscroll rightmove;
xywh 11 51 115 99;cc listbox listbox ws_border ws_vscroll rightmove bottommove;
xywh 133 52 40 12;cc ok button leftmove rightmove;cn "&Run";
xywh 133 67 40 12;cc print button leftmove rightmove;cn "&Print";
xywh 133 136 40 12;cc cancel button leftmove topmove rightmove bottommove;cn "&Close";
xywh 7 29 171 124;cc g1 groupbox rightmove bottommove;cn "";
pas 6 4;pcenter;
rem form end;
)

labsel_run=: 3 : 0
if. wdisparent 'labsel' do.
  wd 'psel labsel;pshow;pactive' return.
end.
wd LABSEL

NB. enable sounds in Windows only...
if. IFWIN32 do.
  wd 'menupop "Options";'
  wd 'menu sound "Enable &Sound" "" "" "";'
  wd 'menusep ;'
  wd 'menu exit "E&xit" "" "" "";'
  wd 'menupopz;'
end.

if. IFWINCE do.
  wd 'setshow print 0'
end.

IFSOUND=: 0             NB. should read from config
labshowcats''
if. IFWIN32 do. wd 'set sound ',":IFSOUND end.
wd 'setfocus listbox'
wdfit''
wd 'pshow;'
)

NB. =========================================================
labsel_sound_button=: 3 : 0
IFSOUND=: -. IFSOUND
wd 'set sound ',":IFSOUND
)

NB. =========================================================
labsel_listbox_button=: 3 : 0
if. #listbox do.
  labselrun 2 pick (".listbox_select) { LABCATSEL#LABS
end.
)

NB. =========================================================
labsel_print_button=: 3 : 0
if. #listbox do.
  printfiles_j_ 2 pick (".listbox_select) { LABCATSEL#LABS
end.
)

NB. =========================================================
labsel_enter=: labsel_ok_button=: labsel_listbox_button
labsel_intro_button=: labselrun bind 'system\extras\labs\labintro.txt'

NB. =========================================================
labselrun=: 3 : 0
labinit y.
wd :: ] 'psel labsel;pclose;'
if. IFWINCE=0 do.
  wd 'smselout;smfocus' NB. give jx focus
end.
)

NB. =========================================================
labsel_cancel_button=: wd bind 'pclose'
labsel_exit_button=: labsel_cancel_button

NB. =========================================================
labsel_category_button=: 3 : 0
if. LABCAT -: <category do. return. end.
LABCAT=: <category
labshowcats''
)

NB. =========================================================
labshowcats=: 3 : 0
if. LABCAT -: <ALL do.
  LABCATSEL=: 1 #~ #LABS
else.
  LABCATSEL=: ({."1 LABS) e. LABCAT
end.
labshowall''
)

NB. =========================================================
labsel_category_select=: labsel_category_button

NB. =========================================================
labshowall=: 3 : 0
if. -. (<'labsel') e. < ;. _2 wd 'qp' do. return. end.
wd 'set category *', tolist LABCATS
wd 'setselect category ',":LABCATS i. LABCAT
d=. LABCATSEL # LABS
s=. (<' [sound]') (bx >3{"1 d)} (#d)#a:
wd 'set listbox *', tolist (1{"1 d) ,each s
wd 'setselect listbox 0'
)
