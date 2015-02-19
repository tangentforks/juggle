NB. regular expression demo
NB.
NB. requires richedit control - not for Win31

require 'files regex strings'

REGDEMO=: 0 : 0
pc regdemo closeok;pn "Regular Expression Pattern Matching";
menupop "&File";
menu std "Sta&ndard demo text" "" "" "";
menu open "&Open..." "" "" "";
menusep ;
menu exit "&Exit" "" "" "";
menupopz;
menupop "&Patterns";
menu p0 "Simple text" "" "" "";
menu p1 "Vowels" "" "" "";
menu p2 "Upper case" "" "" "";
menu p3 "Punctuation" "" "" "";
menu p4 "Alternation" "" "" "";
menu p5 "r + vowels" "" "" "";
menu p6 "Double letters" "" "" "";
menu p7 "J assignment" "" "" "";
menu p8 "Character strings" "" "" "";
menu p9 "J numeric items" "" "" "";
menu p10 "J names" "" "" "";
menupopz;
xywh 182 20 32 11;cc close button leftmove rightmove;cn "Close";
xywh 4 9 21 9;cc label static;cn "Pattern:";
xywh 27 7 150 11;cc pat edit ws_border es_autohscroll rightmove;
xywh 0 34 217 93;cc out richeditm ws_hscroll ws_vscroll es_autohscroll es_autovscroll es_readonly es_sunken rightmove bottommove;
xywh 182 6 32 11;cc match button leftmove rightmove;cn "&Match";
xywh 27 20 150 9;cc msg static rightmove;cn "";
pas 0 0;pcenter;
rem form end;
)

0 : 0
menupop "&Help";
menu hdemo "Help on &Demo" "" "" "";
menu hregex "Help on &Regular Expressions" "" "" "";
menupopz;
)

STDTEXT=: 0 : 0
Here is some standard text for experimenting with regular
expression pattern matching.

NB. Some sample J code:

foo=: 'can''t' [ y.=.>:y.  NB. reassign y.

test=. <;.1 ' ',array,12#'.'
)

regdemo_run=: 3 : 0
if. 2=9!:12'' do.
  wdinfo 'Regex Demo';'This demo does not run under Windows 3.1'
  return.
end.
wd REGDEMO
NB. initialize form here
j=. getconfig_j_ :: (''"_) 'SMFONT'
font=. j,(0 e. #j)#'Terminal 9 oem'
wd 'setfont out ',font
newtext STDTEXT
wd 'setfocus pat'
regdemo_p5_button''
wd 'pshow;'
)

NB. Start/Len From Indices
len=. +/@(*./\)@(= {. + i.@#)
z=. >@{.
i=. >@{:
slfi=: ( (z , ({. , len)@i) ; (len }. ])@i )^:(*@#@i)^:_ &. ((0 2$0)&; :. z) f.

setout=: 4 : 0
S=: s=. (+ +:@i.@#)@:({."1) x.
E=: e=. (>:@+ +:@i.@#)@:(+/"1) x.
M=: m=. -. (i. (#y.)+2*#x.) e. s,e

t=. m #^:_1 y.
t=. (0{a.) s} t
t=. (1{a.) e} t

t=. t rplc '\';'\\'
t=. t rplc '{';'\{'
t=. t rplc '}';'\}'
t=. t rplc LF;'\par',LF
t=. t rplc (0{a.);'{\ul\cf1 '
t=. t rplc (1{a.);'}'
ctab=. '{\colortbl\red0\green0\blue0;\red255\green0\blue0;}'
wd 'set out "."'
wd 'set out *{',ctab,t,'}'
)

regdemo_close_button=: 3 : 0
wd 'pclose;'
)

regdemo_match_button=: 3 : 0
if. 0=#pat do. return. end.
m=. {."2 pat rxmatches :: 0: TEXT
if. m-:0 do.  NB. error
  (0 2$0) setout TEXT
  if. 'Success'-:t=.rxerror'' do. t=. 'Interrupt' end.
  wd 'set msg *',t=.'Error: ',t
else.  NB. success
  m setout TEXT
  wd 'set msg *',t=.(":#m),' match',('es'#~1~:#m),'.'
end.
NB. wd 'setselect pat'
wd 'setfocus pat'
t
)

regdemo_pat_button=: regdemo_match_button

regdemo_std_button=: 3 : 0
newtext STDTEXT
)

newtext=: 3 : 0
(0 2$0) setout TEXT=: y.
)

regdemo_open_button=: 3 : 0
f=. wd 'mbopen "Open File" "" "" "Text files|*.txt|Script files|*.ijs|All files|*.*" ofn_filemustexist'
if. *#f do. newtext fread f end.
)

dopattern=: 3 : 0
't p'=. y.{Patterns
wd 'set pat *',p
pat=: p
t=.t,': ',regdemo_match_button''
wd 'set msg *',t
)

Patterns=: <;._1;._2 ]0 : 0
`Simple text "regular"`regular
`Vowels`[aeiouAEIOU]
`Upper case letters`[[:upper:]]
`Punctuation`[[:punct:]]
`"standard" or "regular"`standard|regular
`"r" followed by 1 or more vowels`r[aioue]+
`Double letters`([[:alpha:]])\1
`J assignment`([[:alpha:]][[:alnum:]_]*|x\.|y\.|m\.|n\.|u\.|v\.) *=[.:]
`Character strings`'(''|[^'])*'
`J numeric items`[[:digit:]_][[:alnum:]_.]*
`J names`[[:alpha:]][[:alnum:]_]*|x\.|y\.|m\.|n\.|u\.|v\.
)

([:".'regdemo_p'"_,":,'_button=:dopattern bind '"_,":)"0 i.#Patterns

regdemo_exit_button=: regdemo_close_button

regdemo_hdemo_button=: 3 : 0
wd 'winhelp "system/extras/help/jregexp.hlp" 1500'
)

regdemo_hregex_button=: 3 : 0
wd 'winhelp "system/extras/help/jregexp.hlp" 1100'
)

regdemo_run''