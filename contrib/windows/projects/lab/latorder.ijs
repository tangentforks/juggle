NB. reorder chapters or sections

ORDERTYPE=: 0  NB. default (0=section, 1=chapter)


TORDER=: 0 : 0
pc torder;
xywh 7 8 113 9;cc type static;
xywh 6 18 120 100;cc list listbox ws_hscroll ws_vscroll lbs_multiplesel rightscale bottomscale;
xywh 7 120 47 11;cc up button topmove bottommove;cn "Move &Up";
xywh 78 120 47 11;cc down button topmove bottommove;cn "Move Do&wn";
xywh 136 8 47 11;cc ok button leftmove rightmove;cn "OK";
xywh 136 23 47 11;cc cancel button leftmove rightmove;cn "Cancel";
xywh 136 86 47 11;cc clear button leftmove rightmove;cn "&Clear Selections";
xywh 136 103 47 11;cc restore button leftmove rightmove;cn "&Restore Original";
pas 4 2;pcenter;
rem form end;
)

NB. =========================================================
tordnum=: 3 : 0
if. y.=1 do. <'' else.
  tordnum1=: ' ('&, @ (,&(' of ',(":y.),')')) @ ":
  tordnum1 each >: i.y.
end.
)

NB. =========================================================
torder_run=: 3 : 0
if. 0=tread'' do. return. end.
ORDERTYPE=: y.

if. ORDERTYPE=0 do.
  name=. 'Sections'
  len=. 2 -~/\ SECTIONINDEX,#SECTIONDATA
  TLIST=: len#SECTIONS
  TLISTLEN=: # &> TLIST
  TLIST=: TLIST ,each ; tordnum each len
else.
  name=. 'Chapters'
  TLIST=: CHAPTERS
end.

if. (1 >: #TLIST) +. 0=#;TLIST do.
  tinfo 'There is only one ',ORDERTYPE pick 'section.';'chapter.'
  return.
end.

TLISTNDX=: i.#TLIST
TORGLIST=: TLIST
TSELECT=: _1

wd TORDER
wd 'pn *Rearrange ',name
wd 'set type ',name,':'
torder_show''
wd 'setfocus ok'
wd 'pshow;'
)

NB. =========================================================
torder_cancel_button=: wd bind 'pclose'

NB. =========================================================
torder_show=: 3 : 0
wd 'set list *',; ,&LF each TLIST
wd ;';setselect list '&, @ ": each _1,TSELECT
)

NB. =========================================================
torder_clear_button=: 3 : 0
TSELECT=: -1
torder_show''
)

NB. =========================================================
torder_restore_button=: 3 : 0
TLIST=: TORGLIST
TSELECT=: _1
torder_show''
)

NB. =========================================================
torder_ok_button=: 3 : 0
if. TLIST -: TORGLIST do. return. end.

if. ORDERTYPE=0 do.
  t=. (TLISTNDX { TLISTLEN) {. each TLIST
  SECTIONINDEX=: bx tpartition t
  SECTIONS=: SECTIONINDEX { t
  SECTIONDATA=: TLISTNDX { SECTIONDATA
  NDX=: TLISTNDX i. NDX
else.
  CHAPTERDATA=: TLISTNDX{CHAPTERDATA
  CHAPTERS=: TLIST
  CHAPTERNDX=: TLISTNDX i. CHAPTERNDX
end.

wd :: ] 'pclose'
wd 'psel author'
tshow''
)

NB. =========================================================
torder_up_button=: torderit bind 0
torder_down_button=: torderit bind 1

NB. =========================================================
torderit=: 3 : 0
listndx=. ,". list_select
if. 0=#listndx do. return. end.
if. -. listndx -: ({.listndx) + i.#listndx do.
  tinfo 'Selections must be contiguous'
  return.
end.
if. y. do.
  ndx=. listndx tmovedown #TLIST
else.
  ndx=. listndx tmoveup #TLIST
end.
TLIST=: ndx{TLIST
TLISTNDX=: ndx{TLISTNDX
TSELECT=: ndx i. listndx
torder_show''
)

NB. =========================================================
NB. move x. up from full list #y.
NB. return new list
tmoveup=: 4 : 0

list=. i.y.
move=. x. #~ x. ~: i.#x.

while. #move do.
  ndx=. _1 0 + {.move
  move=. }.move
  list=. (|. ndx{list) ndx} list
end.

list
)

NB. =========================================================
NB. move x. down from full list #y.
NB. return new list
tmovedown=: 4 : 0

list=. i.y.
move=. x. #~ x. ~: y. - >:i.-#x.
while. #move do.
  ndx=. 0 1 + {:move
  move=. }:move
  list=. (|. ndx{list) ndx} list
end.

list
)
