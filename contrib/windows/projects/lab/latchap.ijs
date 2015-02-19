NB. latchap

LATCHAP=: 0 : 0
pc latchap closeok;pn "Select Chapter";
xywh 5 2 170 17;cc g0 groupbox;cn "";
xywh 8 8 16 9;cc s0 static;cn "Lab:";
xywh 23 8 146 9;cc labid static;
xywh 8 35 121 9;cc labinfo static;
xywh 8 47 24 8;cc l2 static;cn "Name:";
xywh 7 55 164 75;cc listbox listbox ws_border ws_vscroll rightmove bottommove;
xywh 135 23 40 12;cc ok button leftmove rightmove;cn "OK";
xywh 135 38 40 12;cc cancel button leftmove rightmove;cn "Cancel";
pas 4 2;pcenter;
rem form end;
)

labfmt=: 4 : 0
EAV,'(',(":x.),') ',y.,EAV
)

latchap_run=: 3 : 0
tbuildchapter''
NDXOLD=: CHAPTERNDX
wd LATCHAP
s=. #CHAPTERDATA
wd 'set labid *',LABTITLE
wd 'set labinfo *Select a chapter.'
d=. ;(1+i.#CHAPTERS) labfmt each CHAPTERS
wd 'set listbox ',;d
wd 'setselect listbox ',":CHAPTERNDX
wd 'setfocus listbox'
wd 'pshow;'
)

latchap_doit=: 3 : 0
try. wd 'pclose' catch. end.
wd 'psel author'
if. CHAPTERNDX ~: NDXOLD do.
  labopenchapter CHAPTERNDX
  tshow 0
end.
)

latchap_listbox_button=: 3 : 0
CHAPTERNDX=: ".listbox_select
latchap_doit''
)

latchap_ok_button=: latchap_listbox_button
latchap_enter=: latchap_listbox_button
latchap_cancel_button=: wd bind 'pclose'
