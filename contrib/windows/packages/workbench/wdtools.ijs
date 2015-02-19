NB. wdtools
NB. text wdprompt default

PROMPT=: 0 : 0
pc prompt dialog nomax nomenu nomin nosize closeok;
xywh 2 2 129 10;cc answer edit ws_border es_autohscroll;
pas 0 0;pcenter;
rem form end;
)

wdprompt =: 3 : 0
'' wdprompt y.
:
prev =. wd 'qhwndp;'
wd PROMPT
NB. initialize form here
wd 'set answer *',x.
wd 'setselect answer ', ": 0, #x.
wd 'pn *',y.
wd 'setfocus answer; pshow; wait'
q =. wd 'q'
wd 'pclose;'
a=.'answer' wdget q
wd 'psel ', prev
a
)
