NB. recent

RECENT=: 0 : 0
pc lrecent nomin owner;pn "Recent Labs";
xywh 4 9 51 9;cc s0 static;cn "Labs:";
xywh 3 20 135 69;cc l0 listbox ws_vscroll rightmove bottommove;
xywh 72 5 32 11;cc cancel button leftmove rightmove;cn "Cancel";
xywh 106 5 32 11;cc ok button bs_defpushbutton leftmove rightmove;cn "OK";
pas 2 1;pcenter;
rem form end;
)

NB. =========================================================
lrecent_run=: 3 : 0
if. 0 e. #XLATRECENT do.
  info 'No recent labs.' return.
end.

rp=. labpart each XLATRECENT

pos=. wd 'qformx'
wd RECENT
wdcenter pos

wd 'set l0 *', tolist rp
wd 'setselect l0 0'
wd 'setfocus l0;pas 0 0;'
wd 'pshow'
)

NB. =========================================================
lrecent_close=: 3 : 0
wd 'pclose'
wd 'psel author;pactive'
)

NB. =========================================================
lrecent_doit=: 3 : 0
wd 'pclose'
if. #l0 do.
  wd 'psel author'
  topenfile (".l0_select) pick XLATRECENT
end.
wd 'psel author;pactive'
)

NB. =========================================================
lrecent_enter=: lrecent_ok_button=: lrecent_l0_button=: lrecent_doit
lrecent_cancel=: lrecent_cancel_button=: lrecent_close

NB. =========================================================
NB. last only
llast_run=: 3 : 0
j=. XLATRECENT -. < LABPATH,LABFILE
if. 0 e. #j do.
  info 'No last lab.' return.
end.
topenfile >{.j
)
