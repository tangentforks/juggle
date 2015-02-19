LABJUMP=: 0 : 0
pc labjump closeok;pn "Lab Selection";
xywh 135 30 40 12;cc ok button leftmove rightmove;cn "OK";
xywh 135 45 40 12;cc cancel button leftmove rightmove;cn "Cancel";
xywh 6 27 120 75;cc listbox listbox ws_border ws_vscroll rightmove bottommove;
xywh 7 8 166 10;cc labid static;
xywh 7 18 116 9;cc labinfo static;cn " ";
pas 4 2;pcenter;
rem form end;
)

labfmt=: 4 : 0
EAV,(":x.),'. ',y.,EAV
)

labjump_run=: 3 : 0
if. 1=#CHAPTERDATA do.
  info 'There is only one chapter in the lab'
  return.
end.
wd LABJUMP
s=. #CHAPTERS
wd 'set labid *',LABTITLE,' (',(":s),(s plurals ' chapter'),')'
wd 'set labinfo *Select a chapter:'
d=. (1+i.#CHAPTERS) labfmt each CHAPTERS
wd 'set listbox ',;d
wd 'setselect listbox ',":CHAPTERNDX
wd 'setfocus listbox'
wd 'pshow;'
)

labjump_listbox_button=: 3 : 0
labopenchapter ".listbox_select
labchapterline''
wd 'pclose'
labrun''
)

labjump_enter=: labjump_ok_button=: labjump_listbox_button
labjump_close=: labjump_cancel=: labjump_cancel_button=: wd bind 'pclose'
