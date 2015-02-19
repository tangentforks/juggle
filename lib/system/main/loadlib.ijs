NB. script load library (in j locale)
NB.
NB. FRET           J fret
NB. JDIR           J directory
NB. LOADED         loaded files;locales 
NB. PUBLIC         public scripts
NB. SOURCE         source scripts (typically set in projects)
NB.
NB. load           load script file
NB. loads          load scripts
NB. require        load script file if not already loaded
NB.
NB. utilities:
NB. boxopen        box if open
NB. dosname        convert to full pathname in DOS
NB. macname        convert to full pathname in MAC
NB. exist          if file exists (unsecure mode)
NB. filex          default file extension
NB. fullname       convert to full pathname 
NB. pathsep        convert path separator
NB. tolower        convert to lowercase
NB. unixname       convert to full pathname in UNIX
NB. 
NB. plus "z" verbs: load, loadd, require

LOADED=:   i.0 2

boxopen=: <^:(L. = 0:)
fexist=: 1:@(1!:4)@boxopen :: 0:
filex=: ] , ([: -. '.'"_ e. ]) # [

NB. ======================================================
NB. utilities for converting file names into full pathnames:
dosname=: 3 : 0
if. ':' e. y. do. y.
elseif. '\' ~: {.y. do. JDIR,y.
elseif. 1 do. (2{.JDIR),y.
end.
)

macname=: 3 : 0
((':' = {.1{. y.) # }:JDIR),y.
)

unixname=: 3 : 0
(('/'~:{.y.)#JDIR),y.
)

NB. ======================================================
NB. conditional and platform dependent definitions:
3 : 0''
if. 0 ~: 4!:0 <'PUBLIC' do.
  PUBLIC=: i.0 3
  SOURCE=: i.0 3
end.
type=. 9!:12''
IFMAC=: type=3
select. type
case. 4;5;7 do.
  FRET=: LF
  PATHSEP=: '/'
  pathsep=: '/'&((# i.@#)@(=&'\')@]})
  fullname=: unixname
case. 0;1;2;6 do.
  FRET=: CRLF
  PATHSEP=: '\'
  pathsep=: ]
  fullname=: dosname
case. 3 do.
  FRET=: CR
  PATHSEP=: ':'
  pathsep=: ]
  fullname=: dosname
case. do.
  FRET=: CRLF
  PATHSEP=: ''
  pathsep=: ]
  fullname=: ]
end.
select. type
case. 2;6 do.
  info=: wdinfo
case. do.
  info=: 1!:2&2
end.
''
)

NB. ======================================================
NB. this now also set in the standard profile:
j=. 1!:41''
JDIR=:  j,(0=#j)#1!:42''
JDIR=: JDIR,PATHSEP #~ PATHSEP ~: {:JDIR

NB. ======================================================
NB. load    - load scripts
NB. e.g      load 'files'   - load files script
NB.    'loc' load 'files'   - load into locale: loc
NB. If the locale is not given, then if the script names are found
NB. in SOURCE or PUBLIC, the locales given there are used,
NB. otherwise the scripts are loaded into the base locale.
NB. loadd    - load scripts with display
load=: 0&$: : (4 : 'x. loads getscripts y.')
loadd=: 0&$: : (4 : '(x.;1) loads getscripts y.')

NB. ======================================================
NB. require    - load scripts if not already loaded
NB. x. is optional locale
require=: 3 : 0
0 require y.
:
s=. getscripts y.
if. -. x.-:0 do.
  s=. ({."1 s) ,. boxopen x.
end.
0 loads s #~ -. s e. LOADED
)

NB. ------------------------------------------------------
NB. exist
3 : 0''
if. 0=9!:24'' do.
  exist=:  1: @ (1!:4) @ boxopen :: 0:
else.
  exist=: 1:
end.
1
)

NB. ------------------------------------------------------
NB. getnames        - getnames namelist
NB. converts any short names to full names
NB. converts path separator
NB. defaults file extension to .ijs
NB. returns 2 column matrix: names;locales
NB. defined in j locale
getnames=: 4 : 0
if. 0=#y=. y. do. i.0 2 return. end.
if. 0=L.y do.
  if. fexist y do. y=. <y
  else. y=. cutopen y end.
end.
if. 0=#y do. i.0 2 return. end.
y=. pathsep&.>y
ndx=. <.0.5*(,}:"1 x.) i. y
hit=. ndx<#x.
ind=. hit#i.#hit
n=. (i.#y) -. ind
y=. ('.ijs'&filex @ fullname each n{y) n} y
ndx=. hit#ndx
x=. ndx{x.
y=. (1{"1 x) ind } y
y=. y,.(2{"1 x) ind } (#y)#<''
)

NB. ------------------------------------------------------
getscripts=: 3 : 0
(SOURCE,PUBLIC) getnames y.
)

NB. ------------------------------------------------------
NB. loads   - load scripts
loads=: 4 : 0
'x d'=. 2{.(boxopen x.),<0
n=. 'script',d#'d'
for_i. y. do.
  'f l'=. i
  if. 0=exist <f do. info 'file not found: ',f break. end.
  l=. >(0-:x){x;l
  LOADED=: LOADED,f;l
  3 : (n,'_',l,'_ <''',f,'''') 0
end.
LOADED=: ~.LOADED
empty''
)

NB. ------------------------------------------------------
NB. tolower
al=. '''abcdefghijklmnopqrstuvwxyz'',a.'
au=. '''ABCDEFGHIJKLMNOPQRSTUVWXYZ'',a.'
j=. '(y.i.~',au,'){',al
k=. '(y.i.~',al,'){',au
tolower=: (13 : j) :. (13 : k)

NB. ===========================================================
NB. define z verbs:

NB.*load v load script
NB.*loadd v load script with display
NB.*require v require script
load_z_=:      load_j_    
loadd_z_=:     loadd_j_   
require_z_=:   require_j_
