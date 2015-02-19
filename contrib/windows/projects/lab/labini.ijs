NB. labini.ijs    - initialize lab system
NB.
NB. main verbs:
NB.   lab          run lab (=runlab)
NB.   labinit      initialize globals for current lab
NB.   labjump      lab jump
NB.   labopen      open lab file
NB.   labreset     reset lab system
NB.   labrun       run lab section
NB.   labselect    run selection dialog
NB.
NB. other:
NB.   labline      lab line header
NB.   labposition  current position
NB.   labrun0      run bit 0 of code
NB.   labrunnext   run next bit of code
NB.   labsplit     split data into text and code
NB.   labsplitcode split code into sections
NB.   labsection     current section
NB.
NB.   ALL          all category
NB.   CMARKER      marks lab chapters
NB.   SMARKER      marks lab sections

'IFMAC IFWIN32 IFWINCE'=: 3 6 7=9!:12''

j=. IFMAC pick 'Ctrl+A';'Cmd+A'
ADVANCE=: 'Press <',j,'> to advance.'

ALL=: '(All)'
LABDIRECTORY=: (1!:42''),'system\extras\labs\'
CMARKER=: 'Lab Chapter'
RXCMARKER=: '\\par [\\[:alnum:]* ]*',CMARKER
SMARKER=: 'Lab Section'
RXSMARKER=: '\\par [\\[:alnum:]* ]*',SMARKER
RXPAREN=: '\\par [\\[:alnum:]* ]*)'

IFSOUND=: 0
SOUNDFILE=: ''
LINE=: 1{,":<' '

LABS=: ''
LABCAT=: ''
LABCATS=: ''
LABCATSEL=: 0
LABCTD=: ' (ctd)'
LABFILE=: ''
LABPATH=: 'system\extras\labs\'
FONTSCALE=: 1

NB. =========================================================
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

empty''
WINFONT=: getconfig_j_ 'SMFONT'
WINFONTSIZE=: getfontsize WINFONT
WINFONTSIZENOW=: WINFONTSIZE
)

NB. =========================================================
output=: [: empty 1!:2 & 2
outputwin=: labwin_output

NB. =========================================================
start=: 3 : 0
if. #LABS do. y. labinit 1 pick LABNDX{LABS end.
empty''
)

NB. =========================================================
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

NB. =========================================================
NB. labchapterline
labchapterline=: 3 : 0
if. LABWINDOWED < IFCHAPTERS do.
  j=. ' Chapter ',(":1+CHAPTERNDX),' ',(CHAPTERNDX pick CHAPTERS),' '
  output LF,(2$LINE),j,(0>.LABWIDTH-2+#j)$LINE
end.
)

NB. =========================================================
labchaptername=: 3 : 0
if. 1 < #CHAPTERS do.
  (":CHAPTERNDX+1),' ',(CHAPTERNDX pick CHAPTERS),' '
else. '' end.
)

NB. =========================================================
NB. [section] labinit filename
NB.
NB. initialize lab for given file
labinit=: 3 : 0
0 labinit y.
:
if. 0=labopen y. do. return. end.
if. x.=0 do.
  if. LABWINDOWED do.
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

NB. =========================================================
NB. labjump      - jump to chapter in lab
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

NB. =========================================================
labline=: 3 : 0
if. LABWINDOWED do.
  j=. ":NDX+1
  ((0>.LABWIDTH-#j)$LINE), j
else.
  j=. ' ',labsectionname''
  (2$LINE),j,' ',(0>.LABWIDTH-3+#j)$LINE
end.
)

NB. =========================================================
NB. labopen filename
NB.
NB. open lab file, return success
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

NB. ---------------------------------------------------------
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
NB. ---------------------------------------------------------

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

if. LABOUTPUT do.
  output=: [: empty 1!:2 & 2
else.
  output=: ]
end.

labopenchapter 0
)

NB. =========================================================
NB. labopenchapter
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

NB. =========================================================
labposition=: 3 : 0
j=. (":NDX+1),' of ',":#SECTIONDATA
if. IFCHAPTERS do.
NB.  'Ch ',(":CHAPTERNDX+1),'. ',j
  '(',(":CHAPTERNDX+1),') ',j
end.
)

NB. =========================================================
NB. labrun''  - run section in lab, default NDX
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
    output LF,'End of lab' return.
  else.
    labopenchapter CHAPTERNDX+1
    labchapterline''
  end.
end.

if. CODENDX < #CODE do. labruncode'' return. end.
dat=. NDX pick SECTIONDATA
labrun0 dat
)

NB. =========================================================
NB. run first time in section
labrun0=: 3 : 0
'txt dat'=. labsplit y.

if. IFRTF *. LABWINDOWED do.
  if. NDX >: #RTFTEXT do. rtfgetsection'' end.
  txt=. rtfscale RTFHDR,(NDX pick RTFTEXT),CRLF
end.

section=. labline''
if. LABWINDOWED do.
  output section
  outputwin _2}.txt
  if. LABOUTPUT do. wd 'smselout;smfocus' end.
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
    tdo '0!:100 prep'
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

NB. =========================================================
labruncode=: 3 : 0

if. 0=#CODE do. labadvance'' return. end.

'cmd snd'=. CODENDX pick CODE
CODENDX=: >:CODENDX

NB. advance indices before running code:

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

playwav snd
output outtxt
)

NB. =========================================================
labadvance=: 3 : 0
NDX=: >:NDX
CODE=: ''
CODENDX=: 0
)

NB. =========================================================
labsectionname=: 3 : 0
j=. '(',(labposition''),') ',;labsection''
if. IFSOUND > 0=#CODE do.
  if. # ({:"1 >CODE) -. a: do. j,' [sound]' end.
end.
)

NB. =========================================================
NB. labselect directory
labselect=: 3 : 0
labgetfiles y.
j=. {."1 LABDIR
if. 1=#j do.
  LABCATS=: LABCAT=: j
else.
  LABCATS=: ALL;j
  if. (0=#LABCAT) +. -. LABCAT e. LABCATS do.
    LABCAT=: <ALL
  end.
end.
labsel_run''

NB. ??? need this
NB. ensure debug mode is off:
NB. if. 1=13!:17'' do. 13!:0 [ 0 end.

NB.  info 'Please turn off debug mode before running a lab.'
)

NB. =========================================================
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

NB. =========================================================
labsection=: 3 : 0
r=. ({.SECTIONS),a:
if. 0 < NDX do.
  j=. (<:+/NDX >: SECTIONINDEX) pick SECTIONS
  k=. (-.NDX e. SECTIONINDEX)#LABCTD
  if. #j do. r=. j;k end.
end.
r
)

NB. =========================================================
NB. labsplit data
labsplit=: 3 : 0
ind=. 2+((LF,')') E. y.) i. 1
}. each ind ({.;}.) y.
)

NB. =========================================================
NB. labsplitcode data
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
