NB. latinsnd

LATINSND=: 0 : 0
pc latinsnd closeok owner;pn "Insert Sound";
xywh 84 20 34 11;cc ok button leftmove rightmove;cn "OK";
xywh 84 36 34 11;cc cancel button leftmove rightmove;cn "Cancel";
xywh 6 9 40 8;cc label static;cn "Select sound:";
xywh 6 20 65 90;cc list listbox ws_vscroll rightmove bottommove;
pas 6 2;pcenter;
rem form end;
)

latinsnd_run=: 3 : 0
if. 0=#SOUNDBITES do.
  tinfo 'No sounds to select from'
  return.
end.
wd LATINSND
wd 'set list ',; ,&LF each SOUNDBITES
wd 'setselect list 0'
wd 'setfocus list'
wd 'pshow;'
)

latinsnd_cancel_button=: wd bind 'pclose;psel author'

latinsnd_close=: 3 : 0
if. 0=#list_select do. wd 'pclose' end.
name=. (".list_select) pick SOUNDBITES
wd 'pclose'
dat=. wd 'qd'
({."1 dat)=. {:"1 dat
cndx=. {:".code_select
beg=. (0 < cndx) # termLF cndx{.code
end=. ((LF ~: 1{.j)#LF), j=. cndx}.code
code=. beg,('IFSOUND',name),end
wd 'set code *',code
)

latinsnd_list_button=: latinsnd_ok_button=: latinsnd_close
