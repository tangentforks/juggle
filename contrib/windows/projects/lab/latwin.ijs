NB. latwin  lab author win

TLAB=: 0 : 0
pc author;pn "Lab Author";
menupop "&File";
menu new "&New" "" "" "";
menu open "&Open..." "" "" "";
menusep ;
menu llast "&Last" "" "" "";
menu lrecent "&Recent..." "" "" "";
menusep ;
menu save "&Save" "" "" "";
menu saveas "Save &As..." "" "" "";
menusep ;
menu deletefile "&Delete..." "" "" "";
menusep ;
menu print "&Print" "" "" "";
menusep ;
menu runlab "&Run Lab" "" "" "";
menusep ;
menu exit "E&xit" "" "" "";
menusep ;
menu quit "&Quit" "" "" "";
menupopz;
menupop "&Edit";
menu unwrap "&UnWrap" "" "" "";
menusep ;
menu header "&Lab Header..." "" "" "";
menusep ;
menu font "&Font..." "" "" "";
menupopz;
menupop "Cha&pter";
menu previouschapter "&Previous" "" "" "";
menu nextchapter "&Next" "" "" "";
menu selectchapter "&Select..." "" "" "";
menusep ;
menu insertchapter "&Insert Chapter" "" "" "";
menu deletechapter "&Delete Chapter" "" "" "";
menusep ;
menu chapterorder "&Rearrange Chapters..." "" "" "";
menusep ;
menu enablechapter "&Enable Chapters" "" "" "";
menupopz;
menupop "&Section";
menu firstsection "&First" "" "" "";
menu lastsection "&Last" "" "" "";
menu selectsection "&Select..." "" "" "";
menusep ;
menu insertsection "&Insert Section" "" "" "";
menu deletesection "&Delete Section" "" "" "";
menusep ;
menu sectionorder "&Rearrange Sections..." "" "" "";
menusep ;
menu restoresection "Rest&ore Section" "" "" "";
menupopz;
menupop "S&ounds";
menu insertsound "&Insert" "" "" "";
menusep ;
menu enablesound "&Enable Sounds" "" "" "";
menusep ;
menu organizesound "&Organizer..." "" "" "";
menupopz;
menupop "&Help";
menu overview "&Overview" "" "" "";
menusep ;
menu helpauthor "&Author" "" "" "";
menupopz;
xywh 0 0 252 15;cc s0 staticbox ss_etchedframe rightmove;
xywh 3 4 125 9;cc singlechapter static;cn "";
xywh 2 4 23 9;cc schapter static;cn "Chapter:";
xywh 26 3 118 10;cc chapter edit ws_border es_autohscroll rightmove;
xywh 3 20 23 9;cc ssection static;cn "Section:";
xywh 26 19 118 10;cc section edit ws_border es_autohscroll rightmove;
xywh 144 20 15 8;cc tctd static leftmove rightmove;cn "(ctd)";
xywh 159 20 33 8;cc tposition static ss_center leftmove rightmove;cn "";
xywh 2 34 248 9;cc ruler static rightmove;
xywh 0 43 252 60;cc text editm ws_border ws_vscroll rightmove bottomscale;
xywh 0 103 252 55;cc code editm ws_border ws_vscroll es_autohscroll topscale rightmove bottommove;
xywh 191 2 29 11;cc wrap button leftmove rightmove;cn "&Wrap";
xywh 220 2 29 11;cc close button leftmove rightmove;cn "&Close";
xywh 193 19 18 10;cc back button leftmove rightmove;cn "&<<";
xywh 211 19 18 10;cc run button leftmove rightmove;cn "&Run";
xywh 229 19 18 10;cc next button leftmove rightmove;cn "&>>";
pas 0 0;pcenter;
rem form end;
)

NB. =========================================================
author_run=: 3 : 0
if. wdisparent 'author' do.
  wd 'psel author;pshow;pactive' return.
end.
wd TLAB
author_setfont''
wd 'set ruler *',truler''
wd 'setshow schapter 0'
wd 'setshow chapter 0'
wd 'setenable insertsound ',":IFSOUND
if. #y. do.
  topenfile y.
else.
  tnew''
end.
author_setchapters 0
wd 'setfocus text'
wd 'pshow;'
)

NB. =========================================================
author_setchapters=: 3 : 0
wd 'psel author'
wd 'set singlechapter *',(y.=1)#'Lab has a single Chapter'
if=. ":IFCHAPTERS
wd 'setshow singlechapter ',":0=IFCHAPTERS
wd 'setshow schapter ',if
wd 'setshow chapter ',if
wd 'setenable previouschapter ',if
wd 'setenable nextchapter ',if
wd 'setenable selectchapter ',if
wd 'setenable insertchapter ',if
wd 'setenable deletechapter ',if
wd 'setenable chapterorder ',if
wd 'set enablechapter ',if
)

NB. =========================================================
author_setfont=: 3 : 0
wd 'psel author'
wd 'setfont ruler ',LABFONT
wd 'setfont text ',LABFONT
wd 'setfont code ',LABFONT
)

NB. =========================================================
author_actrl_fkey=: 3 : 0
if. NDX >: #SECTIONDATA do.
  output 'End of Chapter'
else.
  author_run_button''
  if. CODENDX >: #CODE do.
    author_next_button ''
    d=. wd 'qd'
    ({."1 d)=: {:"1 d
  end.
end.
)

NB. =========================================================
author_back_button=: 3 : 0
if. 0<NDX do.
  if. tread'' do.
    NDX=: 0 >. <: NDX
    tshow 0 1
  end.
end.
)

NB. =========================================================
NB. set chapter
author_chapter=: 3 : 0
if. y.=CHAPTERNDX do. return. end.
if. 0=tread'' do. return. end.
labopenchapter y.
tshow''
)

NB. =========================================================
author_close=: 3 : 0
if. 0=tcanclosefile '' do. return. end.
wd 'pclose'
tcleanup ''
)

NB. =========================================================
author_deletechapter_button=: 3 : 0
if. (CHAPTERNDX=0) *. 1=#CHAPTERDATA do.
  tinfo 'Cannot delete Chapter 1 if there is no Chapter 2.'
  return.
end.
j=. 'OK to delete this chapter?'
if. 0=2 tquery j do.
  tdelchapter NDX
  tshow 0
end.
)

NB. =========================================================
author_deletesection_button=: 3 : 0
if. (NDX=0) *. 1=#SECTIONDATA do.
  tinfo 'Cannot delete Section 1 if there is no Section 2.'
  return.
end.
j=. 'OK to delete this section?'
if. 0=2 tquery j do.
  tdelsection NDX
  tshow 0
end.
)

NB. =========================================================
author_enablechapter_button=: 3 : 0
if. IFCHAPTERS do.
  if. (1<#CHAPTERS) +. # 0 pick CHAPTERS do.
    msg=. 'Do you want to revert to a single chapter?'
    if. 1=2 tquery msg do. return. end.
    j=. 'Close Lab Author and edit out the Chapters manually'
    tinfo 'This option not supported yet.',LF,LF,j
    return.
  end.
end.
IFCHAPTERS=: -.IFCHAPTERS
author_setchapters 1
)

NB. =========================================================
author_enablesound_button=: 3 : 0
IFSOUND=: -. IFSOUND
wd 'set enablesound ',":IFSOUND
)

NB. =========================================================
author_firstsection_button=: 3 : 0
if. 0<NDX do.
  if. tread'' do. tshow 0 [ NDX=: 0 end.
end.
)

NB. =========================================================
author_helpauthor_button=: 3 : 0
wd 'winhelp "system\extras\help\jlab.hlp" 1400'
)

NB. =========================================================
author_helpsound_button=: 3 : 0
wd 'winhelp "system\extras\help\jlab.hlp" 1500'
)

NB. =========================================================
author_insertchapter_button=: 3 : 0
tbuildchapter''
ndx=. CHAPTERNDX+1
CHAPTERDATA=: (ndx{.CHAPTERDATA),a:,ndx}.CHAPTERDATA
CHAPTERS=: (ndx{.CHAPTERS),a:,ndx}.CHAPTERS
labopenchapter ndx
tshow 0
)

NB. =========================================================
author_insertsection_button=: 3 : 0
if. 0=tread'' do. return. end.
NDX=: NDX+1
SECTIONDATA=: (NDX{.SECTIONDATA),a:,NDX}.SECTIONDATA
SECTIONINDEX=: SECTIONINDEX + SECTIONINDEX >: NDX
tshow 0
)

NB. =========================================================
author_lastsection_button=: 3 : 0
if. NDX < <:#SECTIONDATA do.
  if. tread'' do. tshow 0 [ NDX=: <:#SECTIONDATA end.
end.
)

NB. =========================================================
author_llast_button=: 3 : 0
if. tcanclosefile'' do. llast_run'' end.
)

NB. =========================================================
author_lrecent_button=: 3 : 0
if. tcanclosefile'' do. lrecent_run'' end.
)

NB. =========================================================
author_next_button=: 3 : 0
if. 0=tread'' do. return. end.
ndx=. >:NDX
if. ndx = #SECTIONDATA do.
  if. IFNEWSECTION=0 do.
    j=. 'End of Chapter',LF,LF,'Add new section?'
    if. 1=2 tquery j do. return. end.
  end.
  IFNEWSECTION=: 1
  SECTIONDATA=: SECTIONDATA,a:
end.
NDX=: ndx
tshow 0 1
)

NB. =========================================================
author_newchapter=: 3 : 0
tbuildchapter''
CHAPTERS=: CHAPTERS,a:
CHAPTERDATA=: CHAPTERDATA,a:
author_chapter <:#CHAPTERS
)

NB. =========================================================
author_nextchapter_button=: 3 : 0
if. 0=tread'' do. return. end.
if. 0=#CHAPTERNDX pick CHAPTERS do.
  tinfo 'First complete the current Chapter' return.
end.
if. CHAPTERNDX=<:#CHAPTERS do.
  msg=. 'At the last Chapter.',LF,LF,'Add a new Chapter?'
  if. 0=2 tquery msg do. author_newchapter'' end.
  return.
end.
tbuildchapter''
author_chapter CHAPTERNDX+1
)

NB. =========================================================
author_overview_button=: 3 : 0
wd 'winhelp "system\extras\help\jlab.hlp" 1300'
)

NB. =========================================================
author_new_button=: 3 : 0
if. tcanclosefile'' do. latprop_run tnew '' end.
)

NB. =========================================================
author_open_button=: 3 : 0
if. tcanclosefile '' do. topenfile '' end.
)

NB. =========================================================
author_previouschapter_button=: 3 : 0
if. CHAPTERNDX=0 do.
  tinfo 'At the first Chapter'
  return.
end.
tbuildchapter''
author_chapter CHAPTERNDX-1
)

NB. =========================================================
author_print_button=: 3 : 0
prints_j_ tbuild''
)

NB. =========================================================
NB. this does not indicate if any changes were made
NB. but this should be OK.
author_restoresection_button=: 3 : 0
if. 0=2 tquery 'OK to restore section?' do.
  SECTIONDATA=: ORGSECTIONDATA NDX} SECTIONDATA
  tshow 1
end.
)

NB. =========================================================
author_run_button=: 3 : 0
ndx=. NDX
if. CODENDX < #CODE do.
  tcopylab 0
  labruncode_jlab_''
else.
  if. tread'' do.
    tcopylab 0
    tshow 1 1
    labrun0_jlab_ NDX pick SECTIONDATA
  end.
end.
NDX=: ndx
)

NB. =========================================================
author_selectchapter_button=: 3 : 0
if. 0=tread'' do. return. end.
if. 1=#CHAPTERS do.
  tinfo 'Only one Chapter to select from'
else.
  latchap_run''
end.
)

NB. =========================================================
author_selectsection_button=: 3 : 0
if. 0=tread'' do. return. end.
if. 0=#;SECTIONS do.
  tinfo 'Nothing to select from.'
else.
  latsel_run''
end.
)

NB. =========================================================
author_runlab_button=: 3 : 0
if. 0=#LABTITLE do.
  info 'Lab not created yet'
else.
  if. tclosefile'' do.
    if. #LABFILE do. lab_j_ LABPATH,LABFILE end.
  end.
end.
)

NB. =========================================================
author_enter=: 3 : 0
if. tread'' do. tshow 1 end.
)

NB. =========================================================
author_wrap_button=: 3 : 0
if. 0=#text do. return. end.
if. 0=tread'' do. return. end.
'text code'=. labsplit NDX pick SECTIONDATA
old=. termdelLF }: text
text=. LABWIDTH foldtext old
if. old -: text do. return. end.
dat=. text tjoin code
UNWRAP=: old
UNWRAPIT=: 1
SECTIONDATA=: (<dat) NDX} SECTIONDATA
tshow 1
)

NB. =========================================================
author_unwrap_button=: 3 : 0
dat=. UNWRAP tjoin code
SECTIONDATA=: (<dat) NDX} SECTIONDATA
tshow 1
)

NB. =========================================================
author_cancel=: author_close
author_chapter_button=: author_enter
author_chapterorder_button=: torder_run bind 1
author_close_button=: author_close
author_deletefile_button=: tdeletefile
author_exit_button=: author_close
author_insertsound_button=: latinsnd_run
author_organizesound_button=: authorsnd_run
author_header_button=: latprop_run
author_font_button=: tfont_run
author_quit_button=: tcleanup @ wd bind 'pclose'
author_save_button=: tsave
author_saveas_button=: tsaveas
author_section_button=: author_enter
author_sectionorder_button=: torder_run bind 0

author_sctrl_fkey=: author_save_button

NB. =========================================================
author=: 3 : 0
labreset''
tcfgread''
author_run''
)
