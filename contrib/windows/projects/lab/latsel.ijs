NB. latsel

JLATSEL=: 0 : 0
pc latsel closeok;pn "Select Section";
xywh 8 8 24 9;cc s0 static;cn "Lab:";
xywh 34 8 120 9;cc labid static;
xywh 8 18 24 9;cc s1 static;cn "Chapter:";
xywh 34 18 120 9;cc chapterid static;cn "";
xywh 8 51 24 8;cc label static;cn "Number:";
xywh 34 50 16 10;cc secnum edit ws_border es_autohscroll;
xywh 53 51 40 9;cc sections static;cn "of 34";
xywh 8 63 24 8;cc l2 static;cn "Name:";
xywh 7 71 164 75;cc listbox listbox ws_border ws_vscroll rightmove bottommove;
xywh 135 34 40 12;cc ok button leftmove rightmove;cn "OK";
xywh 135 49 40 12;cc cancel button leftmove rightmove;cn "Cancel";
xywh 8 37 121 9;cc labinfo static;
xywh 5 2 170 26;cc g0 groupbox;cn "";
pas 4 2;pcenter;
rem form end;
)

labfmt=: 4 : 0
EAV,'(',(":x.),') ',y.,EAV
)

latsel_run=: 3 : 0
NDXOLD=: NDX
wd JLATSEL
s=. #SECTIONDATA
wd 'set labid *',LABTITLE
wd 'set chapterid *',CHAPTERNDX pick CHAPTERS
wd 'set labinfo *Select section by number or name.'
wd 'set sections *of ',":s
d=. ;(SECTIONINDEX+1) labfmt each SECTIONS
wd 'set listbox ',;d
wd 'set secnum ',":NDX+1
wd 'setselect secnum 0 ',":#":NDX
n=. (<:#SECTIONINDEX) <. +/NDX>SECTIONINDEX
wd 'setselect listbox ',":n
wd 'setfocus secnum'
wd 'pshow;'
)

latsel_doit=: 3 : 0
try. wd 'pclose' catch. end.
wd 'psel author'
if. NDX ~: NDXOLD do. tshow 0 end.
)

latsel_listbox_button=: 3 : 0
NDX=: (".listbox_select){SECTIONINDEX
latsel_doit''
)

latsel_listbox_select=: 3 : 0
wd 'set secnum ',":>:(".listbox_select){SECTIONINDEX
)

latsel_ok_button=: 3 : 0
if. #secnum do.
  num=. <: {. 1{. _1 ". secnum
  if. -. num e. i.#SECTIONDATA do.
    tinfo 'Invalid section number: ',secnum
    return.
  else.
    NDX=: num
  end.
else.
  NDX=: (".listbox_select){SECTIONINDEX
end.
latsel_doit''
)

latsel_secnum_button=: latsel_enter=: latsel_ok_button
latsel_cancel_button=: wd bind 'pclose'