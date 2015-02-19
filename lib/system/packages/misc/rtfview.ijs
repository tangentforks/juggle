NB. view rtf text in richedit control

NB.*rtfview v view rtf text in richedit control
NB. Form:    rtfview filename
NB.   or:    rtfview rtf_text

RTFVIEW=: 0 :0
pc rtfview closeok;
xywh 210 1 40 10;cc close button leftmove rightmove;
xywh 0 12 250 150;cc r0 richeditm es_autovscroll es_sunken rightmove bottommove;
pas 0 0;pcenter;ptop;
rem form end;
)

NB. windows rtf viewer
NB. y. is text or filename
rtfview_run=: 3 : 0
txt=. > y.
if. -. (LF e. txt) +. 1 e. '{\rtf' E. txt do.
  txt=. 1!:1 <txt
end.
wd RTFVIEW
wd 'set r0 *',txt
wd 'setfocus r0'
wd 'pshow'
)

rtfview_close=: rtfview_close_button=: wd bind 'pclose'
rtfview=: rtfview_run
