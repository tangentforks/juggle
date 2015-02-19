NB. latfns  lab author fns
NB.
NB. tbuild
NB. tcleanup
NB. tclosefile
NB. terrormsg
NB. tdo
NB. tjoin
NB. topenfile
NB. tread
NB. truler
NB. tsave
NB. tsaveas
NB. tshow

NB. =========================================================
NB. tbuild - build new lab file:
tbuild=: 3 : 0
COMMENTLINE=: 'NB. ',((LABWIDTH-4)#'='),LF
tbuildchapter''

hdr=. 'LABTITLE=: ',(quote LABTITLE),LF
if. #LABAUTHOR do. hdr=. hdr,'LABAUTHOR=: ',tfmttext LABAUTHOR end.
if. #LABCOMMENTS do. hdr=. hdr,'LABCOMMENTS=: ',tfmttext LABCOMMENTS end.
if. LABERRORS=1 do. hdr=. hdr,'LABERRORS=: 1',LF end.
if. LABOUTPUT=0 do. hdr=. hdr,'LABOUTPUT=: 0',LF end.
if. LABWIDTH~:61 do. hdr=. hdr,'LABWIDTH=: ',(":LABWIDTH),LF end.
if. LABWINDOWED=0 do. hdr=. hdr,'LABWINDOWED=: 0',LF end.
if. LABWRAP=0 do. hdr=. hdr,'LABWRAP=: 0',LF end.

if. (1=#CHAPTERS) *. 0=#0 pick CHAPTERS do.
  dat=. }. ; CHAPTERDATA
else.
  chap=. ((COMMENTLINE,CMARKER,' ')&,) each CHAPTERS
  dat=. ; chap ,each CHAPTERDATA
end.

dat=. hdr,LF,dat
dat=. dat rplc (LF,SMARKER);LF,COMMENTLINE,SMARKER
)

NB. =========================================================
NB. tbuildchapter - build current chapter
tbuildchapter=: 3 : 0
if. 0=tread'' do. return. end.
f=. [: # -. & (' )',LF)
nil=. bx 0 = f&> SECTIONDATA
for_y. |.nil do. tdelsection y end.
j=. (SMARKER,' ')&, each SECTIONS
hdr=. j SECTIONINDEX} (#SECTIONDATA) # <SMARKER
dat=. LF, ;hdr ,each SECTIONDATA
CHAPTERDATA=: (<dat) CHAPTERNDX} CHAPTERDATA
)

NB. =========================================================
NB. return OK to continue
tcanclosefile=: 3 : 0
if. 0=#LABTITLE do. 1 return. end.
tclosefile''
)

NB. =========================================================
tcleanup=: 3 : 0
18!:55 <'jlabauthor'
return.
0 0$do_jlabauthor_ '4!:55 (4!:1) 0 1 2 3'
)

NB. =========================================================
NB. close file return OK to continue
tclosefile=: 3 : 0
if. 0=#LABFILE do.
  if. 0 = #;SECTIONS do. 1 return. end.
  j=. 'Save lab?'
  if. 0 ~: 2 tquery j do. 1 return. end.
  tsave''
else.
  if. 0=tread'' do. 0 return. end.
  datold=. termdelLF freads LABPATH,LABFILE
  datnew=. termdelLF tbuild''
  if. datold -: datnew do. 1 return. end.
  j=. 'File has changed',LF,LF
  j=. j,'Save changes?'
  if. 0 ~: 2 tquery j do. 1 return. end.
  tsavedat datnew
end.
1
)

NB. =========================================================
NB. tcopylab
NB. copy from labauthor to lab
NB. y.=0 = set LABWINDOWED to 0
tcopylab=: 3 : 0
if. y.=0 do.
  LABWINDOWED_jlab_=: 0
end.

j=. 'IFRTF LABAUTHOR LABERRORS LABTITLE LABWIDTH'
j=. j,' LABWRAP NDX SECTIONDATA'
pdef_jlab_ pack j
)

NB. =========================================================
tdeletefile=: 3 : 0
t=. 'mbopen "Select File" "',LABPATH,'" "" '
t=. t,'"Lab (*.ijt)|*.ijt" ofn_pathmustexist ofn_filemustexist'
fl=. wd t
if. 0=#fl do. 0 return. end.
j=. 'OK to delete ',fl,'?'
if. 0=2 tquery j do.
  1!:55 <fl
end.
)

NB. =========================================================
NB. tdelchapter - remove chapter
tdelchapter=: 3 : 0
if. (CHAPTERNDX=0) *. 1=#CHAPTERDATA do. return. end.
msk=. CHAPTERNDX ~: i.#CHAPTERDATA
CHAPTERDATA=: msk # CHAPTERDATA
CHAPTERS=: msk # CHAPTERS
labopenchapter CHAPTERNDX <. <:#CHAPTERDATA
)

NB. =========================================================
NB. tdelsection - remove section
tdelsection=: 3 : 0
if. (NDX=0) *. 1=#SECTIONDATA do. return. end.
SECTIONDATA=: (y.{.SECTIONDATA), (>:y.)}.SECTIONDATA

if. (NDX e. SECTIONINDEX) *. (NDX+1) e. SECTIONINDEX do.
  msk=. SECTIONINDEX ~: NDX
  SECTIONS=: msk # SECTIONS
  SECTIONINDEX=: msk # SECTIONINDEX
end.

SECTIONINDEX=: SECTIONINDEX - SECTIONINDEX > NDX
NDX=: NDX <. <:#SECTIONDATA

msk=. SECTIONINDEX < #SECTIONDATA
SECTIONINDEX=: msk # SECTIONINDEX
SECTIONS=: msk # SECTIONS

)

NB. =========================================================
terrormsg=: 3 : 0
a=. }: <@}.;._2 ] 13!:12''
tinfo y.,LF,LF,'Run error:',LF,LF, ; ,&LF each a
)

NB. =========================================================
tdo=: do__ :: terrormsg

NB. =========================================================
NB. tfmttext
tfmttext=: 3 : 0
if. LF e. y. do.
  '0 : 0',LF,(termLF y.),')',LF
else.
  (quote y.),LF
end.
)

NB. =========================================================
NB. tjoin - inverse of labsplit
tjoin=: 4 : 0
text=. LF,(termLF ,x.),')'
code=. LF,(termLF ,y.),LF
text,code
)

NB. =========================================================
NB. tnew
tnew=: 3 : 0
labreset_jlab_''
tshow 0
)

NB. =========================================================
topenfile=: 3 : 0
fl=. y.
if. 0=#fl do.
  if. IFMAC do.
    t=. 'mbopen "Select File" "',LABPATH,'" "" '
    t=. t,'"All Files|*.*"'
  else.
    t=. 'mbopen "Select File" "',LABPATH,'" "*.ijt" '
    t=. t,'"Labs|*.ijt|All Files|*.*"'
  end.
  t=. t,' ofn_filemustexist ofn_pathmustexist;'
  fl=. wd t
  if. 0=#fl do. return. end.
end.
if. 0=labopen fl do. return. end.
wd 'pn *Lab Author',(0<#LABTITLE)#' - ',LABTITLE
wd 'set enablesound ',":0<#SOUNDBITES
author_setchapters 1
taddrecent''
tshow 0
)

NB. =========================================================
NB. tread
NB. returns success
tread=: 3 : 0

wd 'psel author'
text=. tclean toJ text
code=. tclean toJ code

exit=. {.1{.y.

if. 0=#LABTITLE do.
  tinfo 'Enter the Lab Header information'
  latprop_run''
  0 return.
end.

if. (0=#deb chapter) *. IFCHAPTERS do.
  tinfo 'Enter the Chapter name'
  wd 'setfocus chapter'
  0 return.
end.

if. (0=#deb section) *. NDX=0 do.
  tinfo 'Enter the Section name'
  wd 'setfocus section'
  0 return.
end.

CHAPTERS=: (<chapter) CHAPTERNDX} CHAPTERS

j=. <text tjoin code
if. NDX=#SECTIONDATA do.
  SECTIONDATA=: SECTIONDATA,j
else.
  SECTIONDATA=: j NDX} SECTIONDATA
end.

curtop=. 0 pick labsection''

if. -. section -: curtop do.
  SECTIONINDEX=: NDX,SECTIONINDEX
  SECTIONS=: (<section),SECTIONS
end.

NB. remove dups:
msk=. ~: SECTIONINDEX            NB. remove dup numbers
SECTIONS=: msk # SECTIONS
SECTIONINDEX=: msk # SECTIONINDEX

msk=. 1, }. (~: _1&|.) SECTIONS  NB. remove dup sections
SECTIONS=: msk # SECTIONS
SECTIONINDEX=: msk # SECTIONINDEX

ind=. /: SECTIONINDEX            NB. sort
SECTIONS=: ind { SECTIONS
SECTIONINDEX=: ind { SECTIONINDEX

NB. ensure first SECTIONINDEX is 0:
SECTIONINDEX=: (#SECTIONINDEX) $ 0, }.SECTIONINDEX

1
)

NB. =========================================================
truler=: 3 : 0
j=. (1,(LABWIDTH-2),1) # (<0;3 10 5) { 9!:6''
k=. ' width ',(":LABWIDTH),' chars '
k (4+i.#k)} j
)

NB. =========================================================
tsave=: 3 : 0
if. 0=tread'' do. return. end.
if. 0=#LABFILE do. tsaveas'' return. end.
tsavedat tbuild''
)

NB. =========================================================
tsavedat=: 3 : 0
s=. y. fwrites fl=. LABPATH,LABFILE
tinfo 'Saved: ',fl
)

NB. =========================================================
tsaveas=: 3 : 0
t=. 'mbsave "Save File" "',LABPATH,'" "',LABFILE,'" '
t=. t,'"Lab (*.ijt)|*.ijt" ofn_pathmustexist'
fl=. wd t
if. 0=#fl do. 0 return. end.
if. '.' e. fl do.
  if. -. '.ijt' -: _4 {. fl do.
    tinfo 'Filename must have *.ijt extension' return.
  else.
    fl=. _4 }. fl
  end.
end.
if. fexist fl,'.ijt' do.
  j=. 'File ',fl,'.ijt exists.',LF,LF
  j=. j,'OK to replace it?'
  if. 1=2 tquery j do. return. end.
end.
'LABPATH LABFILE'=: pathname fl
LABFILE=: LABFILE,(-. '.'e.LABFILE)#'.ijt'
tsave''
)

NB. =========================================================
NB. tshow  (0=original 1=reshow),(0=leave focus,1=focus in text)
tshow=: 3 : 0
'type focus'=. 2{.y.
if. 0=type do. ORGSECTIONDATA=: NDX{SECTIONDATA end.
'txt cod'=. labsplit NDX pick SECTIONDATA
'top ctd'=. labsection''
wd 'psel author'
wd 'set chapter *',CHAPTERNDX pick CHAPTERS
wd 'set section *',top
wd 'set tctd *',ctd
wd 'set tposition *',labposition''
wd 'set text *',}:txt
wd 'set code *',cod
wd 'setenable back ',":0<NDX
j=. ":0<#SOUNDBITES
wd 'setenable enablesound ',j
wd 'set enablesound ',":IFSOUND
wd 'setenable insertsound ',j
wd 'setenable unwrap ',":UNWRAPIT
if. focus do. wd 'setfocus text' end.
UNWRAP=: UNWRAPIT#UNWRAP
UNWRAPIT=: 0
)
