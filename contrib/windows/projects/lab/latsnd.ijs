NB. authorsnd

LATITSND=: 0 : 0
pc authorsnd closeok;
xywh 6 8 117 8;cc file static rightscale;cn "Lab File:";
xywh 6 24 96 8;cc label static;cn "Directory for wav files:";
xywh 6 34 117 10;cc wavdir edit ws_border es_autohscroll rightscale;
xywh 6 54 47 8;cc s0 static;cn "Keys in file:";
xywh 6 62 117 90;cc bites listbox ws_vscroll lbs_multiplesel rightscale bottommove;
xywh 131 6 32 12;cc close button leftmove rightmove;cn "&Close";
xywh 131 32 32 12;cc import button leftmove rightmove;cn "&Import";
xywh 131 63 32 12;cc delete button leftmove topmove rightmove bottommove;cn "&Delete";
pas 6 2;pcenter;
rem form end;
)

NB. =========================================================
authorsnd_run=: 3 : 0
IFSOUNDBITES=: 0<#SOUNDBITES
if. 0=#LABFILE do.
  j=. 'There is no lab file.',LF,LF
  j=. j,'Open an existing lab',LF
  tinfo j,'or save the current one.'
  return.
end.
wd LATITSND
authorsnd_show''
wd 'setfocus wavdir'
wd 'pshow'
)

NB. =========================================================
authorsnd_close=: 3 : 0
wd 'pclose;psel author'
IFSOUND=: IFSOUND +. IFSOUNDBITES < #SOUNDBITES
tshow 1
)

NB. =========================================================
authorsnd_close_button=: authorsnd_close

NB. =========================================================
authorsnd_import_button=: 3 : 0
if. 0=#wavdir do.
  tinfo 'Enter the directory for the wav files'
  return.
end.
wavdir=. wavdir, '\' -. {: wavdir
j=. 1!:0 wavdir,'*.wav'
if. 0=#j do.
  tinfo 'No wav files in directory: ',wavdir
  return.
end.
key=. deb @ tolower @ (_4&}.) each {."1 j
fl=. wavdir&, each {."1 j
if. 0=#SOUNDFILE do.
  SOUNDFILE=: (}:LABFILE),'f'
end.
sndfl=. LABPATH,SOUNDFILE
if. 0=fexist sndfl do. kcreate sndfl end.
for_i. i.#key do.
  (fread i{fl) kwrite sndfl;i{key
end.
authorsnd_read''
authorsnd_show''
)

NB. =========================================================
authorsnd_delete_button=: 3 : 0
if. 0=#bites_select do.
  tinfo 'No keys selected'
  return.
end.
ndx=. ".bites_select
if. ndx -: i.#SOUNDBITES do.
  j=. 'OK to delete all keys?'
else.
  j=. 'OK to delete: ',LF,LF
  j=. j,}: ;: inverse ndx{SOUNDBITES
end.
if. 0=2 tquery j do.
  for_i. i.#ndx do.
    '' kwrite (LABPATH,SOUNDFILE);(i{ndx){SOUNDBITES
  end.
  authorsnd_read''
  authorsnd_show''
end.
)

NB. =========================================================
authorsnd_wavdir_button=: authorsnd_import_button
authorsnd_bites_button=: authorsnd_delete_button

NB. =========================================================
authorsnd_read=: 3 : 0
j=. sort 1 kdir LABPATH,SOUNDFILE
SOUNDBITES=: (0 < L. j)#j
)

NB. =========================================================
authorsnd_show=: 3 : 0
wd 'set file *Lab Sound File: ',SOUNDFILE
if. #SOUNDBITES do.
  wd 'set bites ',;,&LF each SOUNDBITES
end.
)
