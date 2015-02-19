NB. Standard jade library (in j locale)
NB.
NB. requires file: loadlib.ijs for the load utilities
NB. requires file: scripts.ijs for script definitions
NB.
NB. CFGPATH        config path
NB. FRET           text fret
NB. INPUTLOG       session input log
NB. PATHSEP        path separator \ or /
NB. WINPOS         window positions
NB. buildpublic    build public names
NB. buildsource    build source names
NB. edit           edit name
NB. editinputlog   input log
NB. editinputlogs  input log select
NB. help           help support
NB. loadactive     load active script window
NB. open           open script file
NB. require        load script file if not already loaded
NB. save           save current definitions to a script file
NB. scriptmake     make single script file from several files
NB. scripts        access script definitions
NB. selactive      selections for active script window
NB. winpos         window position
NB.
NB. utilities:
NB. build3         called by builder
NB. builder        build names utility
NB. getconfig      get values from CONFIG
NB. getscripts     get script names
NB. globaldefs     global definitions in text
NB. info           display info message
NB. notloaded      if class not loaded
NB. openfiles      open files utility
NB. origin         find script of origin
NB. putconfig      put new values into CONFIG
NB.
NB. plus: extras verbs
NB. plus: "z" verbs: edit, loadp, open, scripts

INPUTLOG=: '';0
WINPOS=:   i.0 2

NB. ======================================================
CFGPATH=: JDIR,'system',PATHSEP,'extras',PATHSEP,'config',PATHSEP

NB. ======================================================
buildpublic=:  3 : 0
empty PUBLIC=: cleantable PUBLIC,~builder y.
)

buildsource=: 3 : 0
'' buildsource y.
:
if. #p=. x. do.
  p=. (-. (2#PATHSEP) E. p) # p
  p=. p,PATHSEP #~ PATHSEP ~: {:p
end.
empty SOURCE=: cleantable SOURCE,~p builder y.
)

NB. ======================================================
NB. edit
edit=: 3 : 0
'n s'=. y.
file=. {.,getscripts_j_ s
dat=. 1!:1 :: _1: file
if. dat -: _1 do.
  'file read error: ',,>file return.
end.
dat=. (2&({.!.(<'''')))@;:;._2 dat,LF
ndx=. dat i. n;'=:'
if. ndx=#dat do.
  ndx=. dat i. (}:(2<:+/\.n='_')#n);'=:'
end.
if. ndx=#dat do.
  info 'not found: ',":n return.
end.
empty wd 'smsel ',EAV,(>file),EAV,';smopen;smscroll ',(":ndx),';smfocus;'
)

NB. ========================================================
editinputlog_j_=: 3 : 0
dltb=. #~ +./\@(-.@e.&(' ',179{a.)) *. +./\.@(~:&' ')
log=. <@dltb ;._2 wd'sminputlog'
log=. log #~ (1: e. e.&(33}.127{.a.)) &> log
log=. |. ~. |. log
if. 0=#log do. wdinfo 'Input Log';'Nothing in the input log' return. end.
'old sel'=. INPUTLOG
if. log-:old do. x=. sel else. x=. <:#log end.
x=. x editinputlogs log
if. #x do.
  INPUTLOG=: log;x
  wd 'smselout;smprompt *', > x{log
  wd 'smfocus'
end.
i.0 0
)

NB. ======================================================
editinputlogs=: 4 : 0
wd 'pc log nomin;pn *Input Log'
wd 'xywh 0 0 130 130;cc l0 listbox ws_vscroll rightmove bottommove'
wd 'setfont l0 ',getconfig 'SMFONT'
wd 'set l0 *',;,&LF each y.
wd 'setselect l0 ',":x.
wd 'setfocus l0;pas 0 0;pcenter'
wpset 'jinputlog'
wd 'pshow;ptop'
r=. ''
while. 1 do.
  wdq=. wd 'wait;q'
  ({."1 wdq)=. {:"1 wdq
  select. systype
  case. 'cancel' do. break.
  case. 'close' do. break.
  case. 'button' do. r=.".l0_select break.
  end.
end.
wpsave 'jinputlog'
wd 'pclose'
r
)

NB. ======================================================
formeditrun=: 3 : 0
'form file'=.y.
load file
if. +./'coclass' E. 1!:1<file do.
 t1=. 'object=:''''conew''',form,''''
 t2=.'object_base_ =:''''conew_base_''',form,''''
else.
 t1=.form,'_run'''''
 t2=.form,'_run_base_'''''
end.
smoutput '   ',t1
".t2
empty''
)

NB. ===========================================================
NB. load project:
loadp=: ''&$: : (4 : 0)
'jproject' jrequires 'system/extras/util/project.ijs'
x. loadproject_jproject_ y.
)

NB. ======================================================
NB. open   - open scripts
NB. e.g.  open 'graph'     - open graph script
open=: 3 : 0
f=. ,}:"1 getscripts y.
b=. exist"0 f
if. 0 e. b do.
  j=. (b=0)#f
  if. 1=#j do. j=. ,>j
  else. j=. LF,; LF&, each j
  end.
  info 'not found: ',j
end.
if. #f=. b#f do.openfiles f end.
)

NB. ======================================================
NB. save
NB.
NB. saves current definitions in a script file
NB.
NB. form: to save loc
NB.
NB.   to = destination file (any previous contents are overwritten)
NB.   loc = locale names
NB.      if empty, save all locales
NB.      otherwise it is a boxed list of one or more locale names
NB.
NB. e.g.
NB.   'my.ijs' save '';'z'    NB. save base and z locales in my.ijs
NB.   'my.ijs' save ''        NB. save all locales in my.ijs

save=: 4 : 0
x.=. boxopen x.
'' 1!:2 x.

if. 0=#y. do. y.=. 4!:1[6 end.

y.=. ,&.>cutopen y.
y.=. (y.e.4!:1[6)#y.

if. 0=#y. do. empty'' return. end.

n99=. -. & ('x.';'y.';'n99';'s99')
s99=. [: ; (, ([: '=:'&, [: ,&(10{a.) 5!:5@<)) &.>

while. #y. do.
  (toHOST s99 (n99 ".'namelist_',(>{.y.),'_ 0 1 2 3'),&.><'_',(>{.y.),'_') 1!:3 x.
  y.=. }.y.
end.

empty ''
)

NB. ======================================================
NB. scriptmake
NB. newfile scriptmake sourcefiles
NB. returns number of characters written, or error message
scriptmake=: 4 : 0
y=. getscripts y.
txt=. ''
while. #y do.
  f=. {.{.y
  dat=. 1!:1 :: _1: f
  if. dat -: _1 do.
    'file read error: ',>f return.
  end.
  txt=. txt,LF,dat
  y=. }.y
end.
txt=. toJ txt,LF
txt=. <;._2 txt
NB. remove comments:
f=. #~ -.@(('NB.'&-:)@(3&{.)&>)
txt=. f txt
f=. 'NB.'&E. <: ~:/\@(''''&=)
g=. (,&CRLF)@(#~ *./\@f)
txt=. ;g each txt
txt 1!:2 }.0;x.
#txt
)

NB. ======================================================
NB. scripts
scripts=: 3 : 0
NB.   scripts ''       short directory
NB.   scripts 'v'      verbose directory
NB.   scripts 'e'      edit directory
NB.   scripts 'reset'  reset directory
if. 0=#y. do.
  a=. list 0{"1 SOURCE
  b=. list 0{"1 PUBLIC
  ((*#a)#a,' '),b
elseif. 'reset'-:y. do.
  0!:0 <CFGPATH,'scripts.ijs'
  SOURCE=: 0#SOURCE
elseif. 'v'e.y. do.
  dir=. SOURCE,PUBLIC
  a=. >0{"1 dir
  b=. >1{"1 dir
  c=. >2{"1 dir
  a /:~ a,.' ',.b,.' ',.c
elseif. 'e'e.y. do.
  open CFGPATH,'scripts.ijs'
elseif. 1 do.
  'invalid argument to scripts: ',,":y.
end.
)

NB. ======================================================
NB. selactive
NB. selection box for active script window
selactive=: 3 : 0
fl=. wd 'qsmact'
if. '.ijs' -: _3{.fl do.
  'n x'=. globaldefs wd 'smselact;smread'
  's t'=. wdselect 'select';n
  if. s do. wd 'smscroll ',(":t{x),';' end.
end.
empty''
)

NB. ========================================================
NB. wpsave/wpset/wpreset window position save/set/clear
wpsave=: 3 : 0
ndx=. ({."1 WINPOS) i. <y.
pos=. 0 ". wd 'qformx'
if. ndx = #WINPOS do.
  WINPOS=: WINPOS,y.;pos-1
end.
if. -. pos -: >{:ndx{WINPOS do.
  WINPOS=: (y.;pos) ndx}WINPOS
  dat=. 'WINPOS=:',5!:5 <'WINPOS'
  dat 1!:2 <CFGPATH,'winpos.ijs'
end.
)

NB. return 1 if done, else 0
wpset=: 3 : 0
ndx=. ({."1 WINPOS) i. <y.
if. r=. ndx < #WINPOS do.
  'x y w h'=. >{:ndx{WINPOS
  'sx sy'=. 2 3{ 0 ". wd 'qscreen'
  x=. x <. sx - w=. w <. sx
  y=. y <. sy - h=. h <. sy
  wd 'pmovex ',":x,y,w,h
end.
r
)

wpreset=: 3 : 0
if. #y=. a: -.~ boxopen y. do.
  b=. -. ({."1 WINPOS) e. y
else. b=. 0 end.
WINPOS=: b#WINPOS
)

NB. ======================================================
NB.  utilities:

NB. ------------------------------------------------------
NB. build3 - used by builder:
dnb=. {.~ i.&1@('NB.'&E.)
cut=. [: ((= ' '"_) <;._2 ]) ,&' '
dle=. -.&(<'')
d01=. ((1 }~) ({~ *@#@>@(1&{)))  NB. use 0 if 1 is empty
chop=. <"1 @: |:
build3=: chop@:(d01@(3&{.)@dle@cut@dnb &>) f.

NB. ------------------------------------------------------
NB. builder
NB. utility used to build names globals
NB. x. = optional default path
NB. y. = file names
builder=: 3 : 0
'' builder y.
:
if. (0 e. $y.) +. 16 < 3!:0 y. do. y. return. end.
y=. (<'') -.~ <;._2 y.,(LF e. y.)}.LF
's d l'=. build3 y
path=.  ,~ #&x.@(-.@(PATHSEP&e.))
drive=. ,~ #&JDIR@({. ~: '/'"_)
NB. name=.  , #&'.ijs'@(-.@('.'&e.))@(-.&'''')
name=. '.ijs'&filex @ (-.&'''')
w=. pathsep@drive@path@name &.> d
s,.w,.l
)

NB. ------------------------------------------------------
NB. cleantable
NB. apply nub and sort to script tables
cleantable=: [: sort ([: ~: {."1) # ]

NB. ------------------------------------------------------
NB. getconfig
getconfig=: 3 : 0
n=. ({."1 CONFIG) i. boxopen y.
n pick a: ,~ {:"1 CONFIG
)

NB. ------------------------------------------------------
NB. globaldefs
NB. find global definitions in text
NB. i.e. lines starting:  name=: ...
NB. returns (boxed names);line numbers
globaldefs=: 3 : 0
dat=. <;._2 y.,LF
f=. [: (#~ (<'=:')&-:@{:) [: 2&{. ;:
def=. f &.> dat
b=. *#&>def
nms=. {.&>b#def
ndx=. b#i.#b
ind=. /:>nms
(ind{nms);<ind{ndx
)

NB. ------------------------------------------------------
NB. locale jrequires script
jrequires=: 4 : 0
if. 0~:4!:0 <'COCLASSPATH_',x.,'_'
do. load y. end.
)

NB. ------------------------------------------------------
NB. openfiles  - open files utility
openfiles=: 3 : 0
try. wd ; ('smsel ',EAV)&,@(,&(EAV,';smopen;smfocus;')) &.> y.
catch. end. empty''
)

NB. ------------------------------------------------------
NB. origin     - find script of origin
origin=: 3 : 0
((<''),4!:3 '') {~ >: 4!:4 cutopen y.
)

NB. ------------------------------------------------------
NB. putconfig  - put new values into CONFIG
NB. y. is 2 column matrix of config values
putconfig=: 3 : 'CONFIG=: (#~ [: ~: {."1) y.,CONFIG'

NB. ======================== extras ==========================
classwizard=: 3 : 0
'jwizard' jrequires 'system/extras/util/wizard.ijs'
classwizard_jwizard_ y.
)

demos=: 3 : 0
script <'system/extras/util/demos.ijs'
)

config=: 3 : 0
script <'system/extras/util/cfgfns.ijs'
)

editfind=: 3 : 0
'jfiw' jrequires 'system/extras/util/fiw.ijs'
fiw_jfiw_ y.
)

fif=: 3 : 0
if. IFMAC do.
  wdinfo 'Find in Files';'Find in Files not available on the Mac' return.
end.
'jfif' jrequires 'system/extras/util/fif.ijs'
fif_jfif_ y.
)

filenewform=: 3 : 0
'jwizard' jrequires 'system/extras/util/wizard.ijs'
classwizard_jwizard_''
)

fileprint_j_=: 3 : 0
dat=. wd 'smselact;smread'
if. ~:/r=. ".wd'smgetsel' do.
  prints (--/r) {. ({.r) }. dat
else.
  prints dat
end.
)

fileprintsetup=: empty @ wd bind 'mbprinter pd_printsetup'

gridwizard=: 3 : 0
'jautocode' jrequires 'system/extras/util/autocode.ijs'
autocode_jautocode_ y.
)

help=: 3 : 0
'jhelp' jrequires 'system/extras/util/help.ijs'
help_jhelp_ y.
)

lab=: 3 : 0
'jlab' jrequires 'system/extras/util/lab.ijs'
lab_jlab_ y.
)

prints=: ''&$: : (4 : 0)
require 'print'
f=. getconfig 'SMPRINT'
try. x. f~ y.
catch. wdinfo 'Print';'Print failed.',LF,LF,'Check the printer is installed'
end.
)

printfiles=: ''&$: : (4 : 0)
require 'print'
f=. getconfig'SMPRINT'
f=. (5{.f),'file',5}.f
try. x. f~ y.
catch. wdinfo 'Print';'Print failed.',LF,LF,'Check the printer is installed'
end.
)

NB. ===========================================================
NB. project manager:
projectmanager=: 3 : 0
if. IFMAC do.
  wdinfo 'Project Manager';'Project Manager not available on the Mac' return.
end.
'jproject' jrequires 'system/extras/util/project.ijs'
projectmanager_jproject_ y.
)

NB. ===========================================================
NB. define PUBLIC:
0!:0 :: ] <CFGPATH,'scripts.ijs'

NB. define WINPOS:
0!:0 :: ] <CFGPATH,'winpos.ijs'

NB. ===========================================================
NB. define z verbs:

NB.*loadp v load project
NB.*open v open script
NB.*scripts v view script names
NB.*edit v edit name

loadp_z_=:     loadp_j_
open_z_=:      open_j_
scripts_z_=:   scripts_j_

NB. edit
NB. e.g. edit 'name'         - edit name where found in script
NB.      edit 'name script'  - edit name in given script
NB. name search looks for global definitions of form:  name=: ...
NB. include the locale name where appropriate, e.g. edit 'save_j_'
edit_z_=: 3 : 0
y=. cutopen y.
if. 0=#y do. empty'' return. end.
if. 1=#y do.
  if. _1 = s=. 4!:4 y do.
    open y return. end.
  y=. y,<s{4!:3 ''
end.
edit_j_ y
)
