NB. lab properties

LATPROP=: 0 : 0
pc latprop;pn "Lab Header";
xywh 6 10 67 9;cc s0 static;cn "Title (required):";
xywh 5 19 105 11;cc title edit ws_border es_autohscroll rightmove;
xywh 6 39 67 9;cc s1 static;cn "Author (optional):";
xywh 5 48 105 40;cc author editm ws_border ws_vscroll es_autovscroll rightscale bottomscale;
xywh 6 94 67 9;cc s2 static topscale bottomscale;cn "Comments (optional):";
xywh 5 103 194 43;cc comments editm ws_border ws_vscroll es_autovscroll topscale rightmove bottommove;
xywh 121 11 78 74;cc g0 groupbox leftmove rightmove;cn "Options";
xywh 126 19 68 10;cc windowed checkbox bs_lefttext leftmove rightmove;cn "Run in &Window:";
xywh 126 29 68 10;cc ifwrap checkbox bs_lefttext leftmove rightmove;cn "&Allow Text Wrap:";
xywh 126 39 68 11;cc chapters checkbox bs_lefttext;cn "Use &Chapters:";
xywh 126 49 68 10;cc errors checkbox bs_lefttext leftmove rightmove;cn "Continue After &Errors:";
xywh 126 59 68 10;cc nooutput checkbox bs_lefttext leftmove rightmove;cn "&No Session Output";
xywh 126 72 44 9;cc s3 static leftmove rightmove;cn "&Text Width:";
xywh 182 71 12 10;cc width edit ws_border es_autohscroll leftmove rightmove;
xywh 91 152 34 11;cc help button leftmove rightmove;cn "Help";
xywh 129 152 34 11;cc cancel button leftmove rightmove;cn "Cancel";
xywh 165 152 34 11;cc ok button bs_defpushbutton leftmove rightmove;cn "OK";
pas 4 2;pcenter;
rem form end;
)

NB. =========================================================
latprop_run=: 3 : 0

if. wdifopen 'latprop' do. wd 'psel latprop;pactive' return. end.

wd LATPROP

wd 'set title *',LABTITLE
wd 'set author *',LABAUTHOR
wd 'set comments *',LABCOMMENTS
wd 'set chapters ',":IFCHAPTERS
wd 'set errors ',":LABERRORS
wd 'set ifwrap ',":LABWRAP
wd 'set nooutput ',":0=LABOUTPUT
wd 'set windowed ',":LABWINDOWED
wd 'set width ',":LABWIDTH

wd 'setfocus title'
wd 'pshow;'
)

NB. =========================================================
latprop_cancel_button=: 3 : 0
wd 'pclose;psel author'
)

latprop_help_button=: 3 : 0
wd 'winhelp "system\extras\help\jlab.hlp" 1325'
)


NB. =========================================================
latprop_ok_button=: 3 : 0
if. 0=#deb title do.
  info 'You must enter a lab title'
  return.
end.
j=. _1 ". width
if. -. (1=#j) *. (j-:<.j) *. (j>:20) *. j<:200 do.
  j=. 'Invalid width ',width,LF,LF
  j=. j,'Should be an integer between 20 and 200'
  tinfo j
  return.
end.
LABWIDTH=: j
LABTITLE=: termdelLF title
LABAUTHOR=: termdelLF author
LABCOMMENTS=: termdelLF comments
LABERRORS=: ". errors
LABOUTPUT=: 0=".nooutput
LABWINDOWED=: ". windowed
IFCHAPTERS=: ".chapters
LABWRAP=: ".ifwrap
wd 'pclose;psel author'
wd 'pn *Lab Author - ',LABTITLE
wd 'set ruler *',truler''
author_setchapters 1
)
