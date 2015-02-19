NB. labfiles
NB.
NB.   labdir       makes LABDIR directory
NB.   labgetfiles
NB.   labgetjt

NB. =========================================================
NB. run when labs first loaded
NB. builds global LABDIR
labdir=: 3 : 0
if. IFMAC do. labdirmac'' return. end.
0!:0 <LABDIRECTORY,'labdir.ijs'
t=. 1!:0 LABDIRECTORY,'*.*'
d=. 'd' = 4{ &> 4{"1 t
t=. tolower_j_ each {."1 d#t
n=. ((tolower_j_ inverse)@{. , }.) each t
t=. n ,. (LABDIRECTORY&,) each t
b=. 0 < # @ (1!:0) @ (,&'\*.ijt') &> {:"1 t
b=. b +. 0 < # @ (1!:0) @ (,&'\*.rtf') &> {:"1 t
t=. b # t
m=. cutopen ;._2 LABDIR
f=. '_ '&chsub
m=. (f each {."1 m) ,. addjdir each {:"1 m
t=. m, t
LABDIR=: (#~ ~:@:({:"1)) t
)

NB. =========================================================
NB. Mac version:
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

NB. =========================================================
NB. labgetfiles
NB. get files from directory, or LABDIR if empty
labgetfiles=: 3 : 0
if. #y. do.
  path=. y.,'\' -. {:y.
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

NB. labgettutor
labgettutor=: labgetjt , labgetrtf

NB. =========================================================
NB. labgetjt   - get jt files in single directory
NB. returning: titles;filenames;ifsound
labgetjt=: 3 : 0
if. IFMAC do.
  path=. y., ':' -. _1{.y.
  j=. 1 dir path
  files=. j #~ '.ijt'&-: @ (_4&{.) &> j
else.
  path=. y., '\' -. _1{.y.
  files=. 1 dir path,'*.ijt'
end.
if. 0=#files do. i.0 3 return. end.
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
t,. files (,<)"0 [s
)

NB. =========================================================
NB. labgetrtf   - get rtf files in single directory
NB. returning: titles;filenames;ifsound
labgetrtf=: 3 : 0
if. IFMAC do. i.0 3 return. end.
path=. y., '\' -. _1{.y.
files=. 1 dir path,'*.rtf'
if. 0=#files do. i.0 3 return. end.
sf=. 1 dir path,'*.ijf'
if. #sf do.
  j=. _4&}. each sf
  k=. _4&}. each files
  s=. k e. j
else.
  s=. (#files)#0
end.
ph=. rxcomp 'LABTITLE[ ]*=:'
t=. ph deb@labrtftitle each files
rxfree ph
(*@# &> t) # t,. files (,<)"0 [s
)

NB. =========================================================
NB. labrtftitle   - rtf title
labrtftitle=: 4 : 0
size=. 1!:4 <y.
dat=. fread y.;0,size <. 5000
'ndx len'=. {. x. rxmatch dat
if. ndx=_1 do.
  'ndx len'=. {. x. rxmatch fread y.
  if. ndx=_1 do.'' return. end.
end.
dat=. (ndx+len) }. dat
j=. '{}',CRLF
". ((<./ dat i. j) {. dat) -. j
)
