coclass 'jlab'
require 'dir files kfiles regex text'
cat=: ,&,.&.|:
deb=: #~ (+. 1: |. (> </\))@(' '&~:)
dtb=: #~ [: +./\. ' '&~:
info=: wdinfo @ ('Labs'&;)
getfontsize=: 13 : '{.1{._1 -.~ _1 ". y.'
pathname=: 3 : '(b#y.);(-.b=.+./\.y.=''/'')#y.'
a=. ''''
quote=: (a&,@(,&a))@ (#~ >:@(=&a))
plurals=: ] , (1: ~: [) # 's'"_
round=: ((%&) [.) (<.@+&0.5&.)
termLF=: , (0: < #) # LF"_ -. _1&{.
termdelLF=: }.~ [: - 0: i.~ LF&= @ |.
tdo=: do__
tolist=: }. @ ; @: (LF&, each)
wdifopen=: boxopen e. <;._2 @ (wd bind 'qp')
addjdir=: 3 : 0
if. IFMAC do. y.
elseif. '/' ~: {.y.,'/' do. y.=. JDIR_j_,y.
elseif. 1 do. y.
end.
)
labdfx=: 3 : 0
if. IFWINCE do.
if. '\' ~: {.y.,'\' do.
y.=. (1!:42''),y.
end.
end.
1!:0 y.
)
assert=: ''&$: : (4 : 0)
if. -. 0 e. y. do. return. end.
if. 0=#x. do.
j=. 'There is a problem with the lab.',LF,LF
x.=. j,'Try re-loading J and starting it again.'
end.
info x.
laberror=. 13!:8@1:
laberror''
)
chsub=: 4 : 0
'f t'=. ((#x.)$0 1)<@,&a./.x.
t {~ f i. y.
)
pdef=: 3 : 0
if. 0 e. $y. do. empty'' return. end.
names=. {."1 y.
if. #names do. (names)=: {:"1 y. end.
names
:
names=. {."1 y.
nl=. ;:^:(L. = 0:) x.
pdef (names e. nl)#y.
)
playsound=: '' 1 : 0
select. 9!:12''
case. 2 do.
'winmm.dll sndplaysound i *c i' & (15!:0) @ (;&1)
case. 6 do.
[: empty 'winmm.dll PlaySound i *c i i' & (15!:0) @ (;&(0;4))
end.
)
playwav=: 3 : 0
if. IFSOUND*. 0<#y. do.
s=. boxopen y.
for_i. i.#s do.
snd=. (deb i pick s) -. LF
dat=. kread (LABPATH,SOUNDFILE);snd
if. #dat do.
playsound dat
end.
end.
end.
)
setfontsize=: 4 : 0
b=. ~: /\ y.='"'
nam=. b#y.
txt=. ;:(-.b)#y.
ndx=. 1 i.~ ([: *./ e.&'0123456789.') &> txt
nam, ; ,&' ' &.> (<":x.) ndx } txt
)
wdmove=: 4 : 0
'px py'=. y.
'sx sy'=. 2 {. 0 ". wd 'qm'
'x y w h'=. 0 ". wd 'psel ',x.,';qformx'
if. px < 0 do. px=. sx - w + 1 + px end.
if. py < 0 do. py=. sy - h + 1 + py end.
wd 'pmovex ',": px,py,w,h
)
wraptext=: 3 : 0
if. LABWIDTH > #y. do. y. return. end.
if. LABWRAP do.
(LABWIDTH foldtext _2}. y.) , _2{.y.
else.
y.
end.
)
labgetsubdir=: 3 : 0
t=. 1!:0 y.,'*'
b=. 'd' = 4{ &> 4{"1 t
{."1 b # t
)
labdir=: 3 : 0
if. IFMAC do. labdirmac'' return. end.
0!:0 <LABDIRECTORY,'labdir.ijs'
t=. labdir1 LABDIRECTORY
m=. cutopen ;._2 LABDIR
f=. '_ '&chsub
m=. (f each {."1 m) ,. addjdir each {:"1 m
t=. m, t
LABDIR=: (#~ ~:@:({:"1)) t
)
labdir1=: 3 : 0
t=. 1!:0 y.,'*'
d=. 'd' = 4{ &> 4{"1 t
t=. tolower_j_ each {."1 d#t
n=. ((tolower_j_ inverse)@{. , }.) each t
t=. n ,. (y.&,) each t
b=. 0 < # @ (1!:0) @ (,&'/*.ijt') &> {:"1 t
b=. b +. 0 < # @ (1!:0) @ (,&'/*.rtf') &> {:"1 t
b # t
)
labdirmac=: 3 : 0
0!:0 <LABDIRECTORY,'labdir.ijs'
t=. 1!:0 ':system:extras:labs:'
d=. 'd' = 4{ &> 4{"1 t
t=. tolower_j_ each {."1 d#t
n=. ((tolower_j_ inverse)@{. , }.) each t
t=. n ,. ((':system:extras:labs:')&,) each t
t=. (0 < # @ (1!:0) @ (,&':') &> {:"1 t) # t
m=. cutopen ;._2 LABDIR
f=. '_ '&chsub
m=. (f each {."1 m) ,. {:"1 m
t=. m, t
LABDIR=: (#~ ~:@:({:"1)) t
)
labgetfiles=: 3 : 0
if. #y. do.
path=. y.,'/' -. {:y.
j=. labgetjt path
if. 0=#j do.
info 'No tutorials found in: ',":y.
labreset''
return.
end.
dname=. 1 pick pathname }:path
LABDIR=: 1 2$dname;path
else.
labdir''
j=. ; < @ ({. ,. labgettutor &> @ {:)"1 LABDIR
end.
LABS=: j sort 1{"1 j
)
labgettutor=: labgetjt , labgetrtf
labgetjt=: 3 : 0
if. IFMAC do.
path=. y., ':' -. _1{.y.
j=. 1 dir path
files=. j #~ '.ijt'&-: @ (_4&{.) &> j
else.
path=. y., '/' -. _1{.y.
files=. 1 dir path,'*.ijt'
end.
if. 0=#files do.
t=. i.0 3
else.
sf=. 1 dir path,'*.ijf'
if. #sf do.
j=. _4&}. each sf
k=. _4&}. each files
s=. k e. j
else.
s=. (#files)#0
end.
t=. files;each <0 100
t=. toJ each 1!:11 each t
t=. ". each (t i. each LF){.each t
t=. t,. files (,<)"0 [s
end.
if. #s=. labgetsubdir path do.
t=. t, ; labgetjt each path&, each s
end.
)
labgetrtf=: 3 : 0
i.0 3 return.
if. IFMAC do. i.0 3 return. end.
path=. y., '/' -. _1{.y.
files=. 1 dir path,'*.rtf'
if. 0=#files do.
t=. i.0 3
else.
sf=. 1 dir path,'*.ijf'
if. #sf do.
j=. _4&}. each sf
k=. _4&}. each files
s=. k e. j
else.
s=. (#files)#0
end.
ph=. rxcomp_jregex_ 'LABTITLE[ ]*=:'
t=. ph deb@labrtftitle each files
rxfree_jregex_ ph
t=. (*@# &> t) # t,. files (,<)"0 [s
end.
if. #s=. labgetsubdir path do.
t=. t, ; labgetrtf each path&, each s
end.
)
labrtftitle=: 4 : 0
size=. 1!:4 <y.
dat=. fread y.;0,size <. 5000
'ndx len'=. {. x. rxmatch_jregex_ dat
if. ndx=_1 do.
'ndx len'=. {. x. rxmatch_jregex_ fread y.
if. ndx=_1 do.'' return. end.
end.
dat=. (ndx+len) }. dat
j=. '{}',CRLF
". ((<./ dat i. j) {. dat) -. j
)
'IFMAC IFWIN32 IFWINCE'=: 3 6 7=9!:12''
j=. IFMAC pick 'Ctrl+A';'Cmd+A'
ADVANCE=: 'Run  labgo ''''  to advance.'
ALL=: '(All)'
LABDIRECTORY=: (1!:42''),'system/extras/labs/'
ADDONDIRECTORY=: (1!:42''),'addons/'
CMARKER=: 'Lab Chapter'
RXCMARKER=: '\\par [\\[:alnum:]* ]*',CMARKER
SMARKER=: 'Lab Section'
RXSMARKER=: '\\par [\\[:alnum:]* ]*',SMARKER
RXPAREN=: '\\par [\\[:alnum:]* ]*)'
IFSOUND=: 0
IFCOMMENTS=: 1
IFSENTENCES=: 1
IFWINDOWS=: 1
SOUNDFILE=: ''
LINE=: 1{,":<' '
LABS=: ''
LABCAT=: ''
LABCATS=: ''
LABCATSEL=: 0
LABCTD=: ' (ctd)'
LABFILE=: ''
LABPATH=: 'system/extras/labs/'
FONTSCALE=: 1
labreset=: 3 : 0
LABAUTHOR=: ''
LABCOMMENTS=: ''
LABERRORS=: 0
LABTITLE=: ''
LABWINPOS=: _1
LABWINDOWED=: 0=IFWINCE
LABOUTPUT=: 1
LABWIDTH=: 61
CHAPTERDATA=: ,a:
CHAPTERNDX=: 0
CHAPTERS=: ,a:
CODE=: ''
CODENDX=: 0
SECTIONDATA=: ,a:
NDX=: 0
SECTIONINDEX=: 0
SECTIONS=: ,a:
IFCHAPTERS=: 0
IFNEWSECTION=: 0
IFSOUND=: 0
LABWRAP=: 1
ENDOFLAB=: 0
empty''
NB.WINFONT=: getconfig_j_ 'SMFONT'
NB.WINFONTSIZE=: getfontsize WINFONT
NB.WINFONTSIZENOW=: WINFONTSIZE
)
output=: [: empty 1!:2 & 2
outputwin=: labwin_output
start=: 3 : 0
if. #LABS do. y. labinit 1 pick LABNDX{LABS end.
empty''
)
lab=: 3 : 0
if. 1=L.y. do.
'file ndx'=. y.
ndx labinit file
elseif. 0 e. $y. do.
labselect''
elseif. 0 = 1{.y. do.
labrun }.y.
elseif. y.-:1 do.
labjump''
elseif. y.-:2 do.
if. IFMAC do.
info 'Lab Author not available on the Mac'
return.
end.
0!:0 <'system\extras\util\lauthor.ijs'
author_jlabauthor_ ''
elseif. y.-:3 do.
labopt_run''
elseif. 2=3!:0 y. do.
d=. 1 dir y.
if. 0 e. $y. do.
info 'not found: ',y.
elseif. d -: ,<y. do.
labinit y.
elseif. 1 do.
labselect y.
end.
end.
empty''
)
labchapterline=: 3 : 0
if. (LABWINDOWED *. IFWINDOWS) < IFCHAPTERS do.
j=. ' Chapter ',(":1+CHAPTERNDX),' ',(CHAPTERNDX pick CHAPTERS),' '
output LF,(2$LINE),j,(0>.LABWIDTH-2+#j)$LINE
end.
)
labchaptername=: 3 : 0
if. 1 < #CHAPTERS do.
(":CHAPTERNDX+1),' ',(CHAPTERNDX pick CHAPTERS),' '
else. '' end.
)
labinit=: 3 : 0
0 labinit y.
:
if. 0=labopen y. do. return. end.
if. x.=0 do.
if. LABWINDOWED *. IFWINDOWS do.
0 outputwin labwelcome''
else.
if. 0<#LABAUTHOR do.
j=. >'Lab:';'Author: '
dat=. j cat ];._2 LABTITLE,LF,LABAUTHOR,LF
else.
dat=. ,: 'Lab: ',LABTITLE
end.
dat=. (LABWIDTH#LINE),dat
dat=. dat,ADVANCE
output }. , LF ,. dat
labchapterline''
labrun x.
end.
end.
)
labjump=: 3 : 0
if. 0=#LABFILE do. info 'no lab selected' return. end.
if. NDX=0 do.
if. 0=#LABFILE do.
info 'no lab selected' return.
end.
0 labinit LABPATH,LABFILE
end.
labjump_run''
)
labline=: 3 : 0
if. LABWINDOWED *. IFWINDOWS do.
j=. ":NDX+1
((0>.LABWIDTH-#j)$LINE), j
else.
j=. ' ',labsectionname''
(2$LINE),j,' ',(0>.LABWIDTH-3+#j)$LINE
end.
)
labopen=: 3 : 0
labreset''
try. dat=. 1!:1 boxopen y.
catch.
info 'not found: ',":>y.
0 return.
end.
'LABPATH LABFILE'=: pathname >y.
SOUNDFILE=: (({.~ i.&'.') LABFILE),'.ijf'
SOUNDBITES=: ''
if. fexist LABPATH,SOUNDFILE do.
j=. sort 1 kdir LABPATH,SOUNDFILE
if. L. j do. SOUNDBITES=: j end.
end.
IFRTF=: 'rtf' -: _3 {. LABFILE
if. IFRTF do. 'dat rtfdat'=. rtfclean dat end.
IFCHAPTERS=: 1 e. CMARKER E. dat
if. IFRTF do.
LABWINDOWED=: 1
j=. rtfcut rtfdat

if. IFCHAPTERS do.
ndx=. 1 i.~ (1: e. CMARKER&E.) &> j
RTFHDRORG=: RTFHDR=: '{',;ndx {. j
j=. ;ndx }. j
RTFCHAPTERDATA=: (CMARKER rxE j) <;.1 j
else.
ndx=. 1 i.~ (1: e. SMARKER&E.) &> j
RTFHDR=: '{',;ndx {. j
j=. ;ndx }. j
RTFCHAPTERDATA=: <j
end.

end.
dat=. toJ dat
dat=. dat,LF -. {:dat
dat=. <;.2 dat
dat=. ;dat #~ -. 'NB. =='&-: @ (6&{.) &> dat
if. IFCHAPTERS do.
cut=. }:(LF,CMARKER) E. LF,dat
0!:100 (cut i. 1){.dat
dat=. cut <;.1 dat
ind=. dat i.&> LF
CHAPTERS=: (>:#CMARKER) }.each ind {.each dat
CHAPTERDATA=: ind }. each dat
else.
cut=. }:(LF,SMARKER) E. LF,dat
0!:100 (cut i. 1){.dat
CHAPTERS=: ,a:
CHAPTERDATA=: <(cut i. 1)}.dat
end.
if. IFWINCE do. LABWINDOWED=: 0 end.
if. LABOUTPUT *. IFCOMMENTS do.
output=: [: empty 1!:2 & 2
else.
output=: ]
end.
labopenchapter 0
)
labopenchapter=: 3 : 0
CHAPTERNDX=: y.
if. IFCHAPTERS do.
WINTITLE=: LABTITLE,' - ',y. pick CHAPTERS
else.
WINTITLE=: LABTITLE
end.
dat=. y. pick CHAPTERDATA
if. #dat do.
cut=. }:(LF,SMARKER) E. LF,dat
dat=. cut <;.1 dat
ind=. dat i.&> LF
top=. (>:#SMARKER) }.each ind {.each dat
NDX=: 0
SECTIONDATA=: ind }. each dat
SECTIONINDEX=: bx 0< # &> top
SECTIONS=: SECTIONINDEX { top
else.
SECTIONDATA=: ,a:
SECTIONINDEX=: 0
SECTIONS=: ,a:
end.
NDX=: 0
CODENDX=: 0
CODE=: ''
if. IFRTF do.
RTFSECTIONDATA=: y. pick RTFCHAPTERDATA
RTFTEXT=: ''
end.
1
)
labposition=: 3 : 0
j=. (":NDX+1),' of ',":#SECTIONDATA
if. IFCHAPTERS do.
'(',(":CHAPTERNDX+1),') ',j
end.
)
labrun=: 3 : 0
if. 0=#LABFILE do. info 'no lab selected' return. end.
if. #y. do.
if. y. e. i.#SECTIONDATA do.
NDX=: y.
CODENDX=: 0
CODE=: ''
else.
info 'Invalid jump section'
return.
end.
end.
if. NDX >: #SECTIONDATA do.
if. CHAPTERNDX >: <: #CHAPTERS do.
ENDOFLAB=: 1
(LF,'End of lab') 1!:2 [ 2 return.
else.
labopenchapter CHAPTERNDX+1
labchapterline''
end.
end.
if. CODENDX < #CODE do. labruncode'' return. end.
dat=. NDX pick SECTIONDATA
labrun0 dat
)
labrun0=: 3 : 0
'txt dat'=. labsplit y.
if. IFRTF *. LABWINDOWED do.
if. NDX >: #RTFTEXT do. rtfgetsection'' end.
txt=. rtfscale RTFHDR,(NDX pick RTFTEXT),CRLF
end.
section=. labline''
if. LABWINDOWED *. IFWINDOWS do.
output section
outputwin _2}.txt
if. LABOUTPUT *. IFCOMMENTS do. wd 'smselout;smfocus' end.
else.
txt=. LF, (0<#txt) # wraptext txt
output LF,section,txt
end.
cmd=. (+./\.dat ~: LF)#dat
while. 1 do.
if. 'PREPARE' -: 7{.cmd do.
cmd=. }. <;.2 cmd,LF
ndx=. 1 i.~ 'PREPARE'&-: @ (7&{.) &> cmd
prep=. ;ndx{.cmd
cmd=. ;(ndx+1)}.cmd
3 : 'tdo ''0!:100 y.''' prep
continue.
elseif. 'SCRIPT' -: 6{.cmd do.
cmd=. }. <;.2 cmd,LF
ndx=. 1 i.~ 'SCRIPT'&-: @ (6&{.) &> cmd
SCRIPT=: ;ndx{.cmd
cmd=. ;(ndx+1)}.cmd
continue.
end.
break.
end.
CODE=: labsplitcode cmd
CODENDX=: 0
labruncode''
)
labruncode=: 3 : 0
if. 0=#CODE do. labadvance'' return. end.
if. IFSENTENCES=0 do. labadvance'' return. end.
'cmd snd'=. CODENDX pick CODE
CODENDX=: >:CODENDX
if. CODENDX < #CODE do.
outtxt=. LF,(3#LINE),' more ',(7#LINE),LF
else.
outtxt=. i.0 0
labadvance''
end.
if. (1 e. cmd ~: LF) *. 2 = 3!:0 cmd do.
if. LABERRORS do.
tdo '0!:111 cmd'
else.
tdo '0!:101 cmd'
end.
end.
output outtxt
)
labadvance=: 3 : 0
NDX=: >:NDX
CODE=: ''
CODENDX=: 0
)
labsectionname=: 3 : 0
j=. '(',(labposition''),') ',;labsection''
if. IFSOUND > 0=#CODE do.
if. # ({:"1 >CODE) -. a: do. j,' [sound]' end.
end.
)
labselect=: 3 : 0
labgetfiles y.
j=. {."1 LABDIR
j=. (j e. {."1 LABS) # j
if. 1=#j do.
LABCATS=: LABCAT=: j
else.
LABCATS=: ALL;j
if. (0=#LABCAT) +. -. LABCAT e. LABCATS do.
LABCAT=: <ALL
end.
end.
labsel_run''
)
labwelcome=: 3 : 0
if. IFRTF do.
r=. '\par \pard\plain\fs20\qc Welcome to Lab:'
r=. r,'\par \par \fs28\cf1\b ',LABTITLE
if. #LABAUTHOR do.
r=. r,'\par \par \fs20\plain Author: \plain\fs24\b ',LABAUTHOR
end.
r=. r,'\par\ \par \par \pard\plain\fs20\qc Press {\b Ctrl+A} to advance.'
r=. rtfscale RTFHDR,r,'\par \pard\ql\plain \par }'
else.
r=. LF,'Welcome to lab: ',LABTITLE
if. 0<#LABAUTHOR do.
r=. r,LF,LF,'Author: ',LABAUTHOR
end.
r=. r,LF,LF,ADVANCE
end.
)
labsection=: 3 : 0
r=. ({.SECTIONS),a:
if. 0 < NDX do.
j=. (<:+/NDX >: SECTIONINDEX) pick SECTIONS
k=. (-.NDX e. SECTIONINDEX)#LABCTD
if. #j do. r=. j;k end.
end.
r
)
labsplit=: 3 : 0
ind=. 2+((LF,')') E. y.) i. 1
}. each ind ({.;}.) y.
)
labsplitcode=: 3 : 0
f=. 'SOUND'&-: @ (5&{.) &>
if. IFSOUND do.
dat=. <;.2 (termLF y.) , 'SOUND',LF
b=. f dat
dat=. (5*b) }.each dat
dat=. b <@ (;@}: ; (}: each) @{:) ;.2 dat
dat=. dat -. <2$a:
else.
dat=. <;.2 termLF y.
dat=. ;dat #~ -. f dat
,<dat;''
end.
)
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
LABOPT=: 0 : 0
pc labopt;pn "Lab Options";
xywh 11 11 113 31;cc g0 groupbox;cn "Lab Displays";
xywh 20 20 76 9;cc comments checkbox;cn "Comment text";
xywh 20 30 76 9;cc sentences checkbox group;cn "J sentences";
xywh 136 8 34 12;cc ok button;cn "OK";
xywh 136 23 34 12;cc cancel button;cn "Cancel";
pas 6 6;pcenter;
rem form end;
)
labopt_run=: 3 : 0
wd LABOPT
wd 'set comments ',":IFCOMMENTS
wd 'set sentences ',":IFSENTENCES
wd 'pshow;'
)
labopt_close=: 3 : 0
IFCOMMENTS=: 0 ". comments
IFSENTENCES=: 0 ". sentences
if. LABOUTPUT *. IFCOMMENTS do.
output=: [: empty 1!:2 & 2
else.
output=: ]
end.
wd 'pclose'
)
labopt_cancel=: labopt_cancel_button=: wd bind 'pclose'
labopt_ok_button=: labopt_enter=: labopt_close
rtflparen=: '{'&= > _1: |. '\'&=
rtfrparen=: '}'&= > _1: |. '\'&=
rtf2par=: [: -.&CRLF ({.~ '\par'&E. i. 1:)
rtfdepth=: [: +/\ rtflparen - 0: , rtfrparen @ }:
rtfsegment=: <;.1~ [: (> 0: , }:) 0: = rtfdepth
rtfnextpar=: 5: + ('\par '&E.) i. 1:
rtftrail=: , [: #&'}' [: =/ [: +/ rtflparen ,. rtfrparen
RTFWELCOME=: 0 : 0
{\rtf42\ansi\deff0\deftab720{\fonttbl{\f42\froman Times New Roman;}
\deflang1033\pard\plain\f42\fs20}
{\colortbl\red0\green0\blue0;\red0\green0\blue255;}
)
rtfgetsection=: 3 : 0
if. 0=#RTFSECTIONDATA do. return. end.
ndx=. {.,RXSMARKER rxmatch_jregex_ RTFSECTIONDATA
if. ndx=_1 do. return. end.
RTFSECTIONDATA=: (5+ndx) }. RTFSECTIONDATA
ndx=. rtfnextpar RTFSECTIONDATA
RTFSECTIONDATA=: ndx }. RTFSECTIONDATA
if. 0=#RTFSECTIONDATA do. return. end.
ndx=. {.,RXPAREN rxmatch_jregex_ RTFSECTIONDATA
ndx=. _1 -.~ ndx,{.,RXSMARKER rxmatch_jregex_ RTFSECTIONDATA
if. 0=#ndx do.
RTFTEXT=: RTFTEXT,<rtftrail RTFSECTIONDATA
RTFSECTIONDATA=: ''
else.
ndx=. <./ndx
j=. (ndx+5) {. RTFSECTIONDATA
RTFTEXT=: RTFTEXT,<rtftrail j
RTFSECTIONDATA=: ndx }. RTFSECTIONDATA
end.
)
rtfclean=: 3 : 0
wd :: ] 'psel rtfconvert;pclose'
wd 'pc rtfconvert;cc r richeditm;set r *',y.
r=. 'r' wdget wd 'qd'
s=. wd 'qrtf r'
if. (+/rtflparen s) ~: +/rtfrparen s
do. s=. '{',s
end.
wd 'pclose'
r;s
)
rtfcut=: 3 : 0
dat=. (>: y. i.'{') }. y.
dat=. (- >: (|.dat) i. '}') }. dat
rtfsegment dat
)
boxfind=: [: bx <@[ (1: e. E.)&> ]
rtfscale=: 3 : 0
RTFSECTION=: y.
if. FONTSCALE=1 do. y. return. end.
rtfscaler=: ": @ <. @ (0.5&+) @ (*&FONTSCALE) @ ".
('\\fs([[:digit:]]+)';,1) rtfscaler rxapply y.
)
LABSEL=: 0 : 0
pc labsel closeok;pn "Lab Select";
menupop "Options";
menu comments "Labs display &Comment Text" "" "" "Show  comments when running Labs";
menu sentences "Labs display J &Sentences" "" "" "Show sentences when running Labs";
menusep ;
menu exit "E&xit" "" "" "";
menupopz;
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
if. IFWINCE do.
wd 'setshow print 0'
end.
labshowcats''
wd 'set comments ',":IFCOMMENTS
wd 'set sentences ',":IFSENTENCES
wd 'setfocus listbox'
wdfit''
wd 'pshow;'
)
labsel_listbox_button=: 3 : 0
if. #listbox do.
labselrun 2 pick (".listbox_select) { LABCATSEL#LABS
end.
)
labsel_print_button=: 3 : 0
if. #listbox do.
printfiles_j_ 2 pick (".listbox_select) { LABCATSEL#LABS
end.
)
labsel_enter=: labsel_ok_button=: labsel_listbox_button
labsel_intro_button=: labselrun bind 'system\extras\labs\labintro.txt'
labselrun=: 3 : 0
labinit y.
wd :: ] 'psel labsel;pclose;'
if. IFWINCE=0 do.
wd 'smselout;smfocus'
end.
)
labsel_cancel_button=: wd bind 'pclose'
labsel_exit_button=: labsel_cancel_button
labsel_category_button=: 3 : 0
if. LABCAT -: <category do. return. end.
LABCAT=: <category
labshowcats''
)
labsel_comments_button=: 3 : 0
IFCOMMENTS=: -. IFCOMMENTS
wd 'set comments ',":IFCOMMENTS
)
labsel_sentences_button=: 3 : 0
IFSENTENCES=: -. IFSENTENCES
wd 'set sentences ',":IFSENTENCES
)
labshowcats=: 3 : 0
if. LABCAT -: <ALL do.
LABCATSEL=: 1 #~ #LABS
else.
LABCATSEL=: ({."1 LABS) e. LABCAT
end.
labshowall''
)
labsel_category_select=: labsel_category_button
labshowall=: 3 : 0
if. -. (<'labsel') e. < ;. _2 wd 'qp' do. return. end.
wd 'set category *', tolist LABCATS
wd 'setselect category ',":LABCATS i. LABCAT
d=. LABCATSEL # LABS
s=. (<' [sound]') (bx >3{"1 d)} (#d)#a:
wd 'set listbox *', tolist (1{"1 d) ,each s
wd 'setselect listbox 0'
)
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
labwin_open=: 3 : 0
if. -. wdifopen 'labwin' do. labwin_init'' end.
)
labwin_output=: (1&$:) : (4 : 0)
labwin_open''
wd 'psel labwin;set text *', y.
wd 'pn *',WINTITLE
if. x. do.
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
labwin_close_button=: 3 : 0
LABWINDOWED=: 0
wd :: ] 'psel labwin;pclose'
)
labwin_cancel=: labwin_close=: labwin_close_button
labwin_chapter_button=: labjump
labwin_ptop_button=: 3 : 0
wd 'ptop ',ptop
PTOP=: ".ptop
)
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
labwin_actrl_fkey=: labrun
labwin_next_button=: labrun
labreset ''
