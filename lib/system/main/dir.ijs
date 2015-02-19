NB. directory utilities
NB.
NB. main verbs:
NB.   dir          directory
NB.   dircompare   compare directories
NB.   dirpath      directory paths
NB.   dirfind      find name in directory
NB.   dirs         directory browse
NB.   dirss        directory string search
NB.   dirssrplc    search and replace in directory
NB.   dirtree      files in directory tree

require 'compare files'

NB. ==================================================
NB.*dir v directory listings
NB.
NB. y. = dos file specification:
NB.      if empty, defaults to *
NB.
NB. x. is optional:
NB.    - if not given, defaults to 'n'
NB.    - if character, returns a formatted directory,
NB.        where x. is the sort option:
NB.          d=by date
NB.          n=by name
NB.          s=by size
NB.    - if numeric, there are 1 or 2 elements:
NB.          0{  0= list short names
NB.              1= boxed list of full pathnames
NB.              2= full directory list
NB.          1{  0= filenames only (default)
NB.              1= include subdirectories
NB.
NB. subdirectories are shown first
NB.
NB. e.g.  dir ''
NB.       1 dir 'system/main/d*.ijs'
dir=: 3 : 0
'n' dir y.
:
y=. y.,(0=#y.)#'*'
y=. y,(':/' e.~ {:y)#'*'
if. 0=#dr=. 1!:0 y do. empty'' return. end.
fls=. 'd' ~: 4{"1>4{"1 dr
if. (1=#dr) *. 0={.fls do.
  r=. x. dir y,'/*'
  if. #r do. r return. end.
end.
if. fmt=. 2=3!:0 x. do. opt=. 2 1
else. opt=. 2{.x. end.
if. 0={:opt do. fls=. 1#~#dr=. fls#dr end.
if. 0=#dr do. empty'' return. end.
nms=. {."1 dr
nms=. nms ,&.>fls{'/';''
ndx=. /: (":,.fls),.>nms
if. 0=opt do.
  list >ndx{nms
elseif. 1=opt do.
  path=. (+./\.y='/')#y
  path&,&.>ndx{nms
elseif. fmt<2=opt do.
  ndx{nms,.}."1 dr
elseif. fmt do.
  'nms ts size'=. |:3{."1 dr
  ds=. ' <dir>   ' ((-.fls)#i.#fls) } 9":,.size
  mth=. _3[\'   JanFebMarAprMayJunJulAugSepOctNovDec'
  f=. > @ ([: _2&{. [: '0'&, ": )&.>
  'y m d h n s'=. f&> ,<"1 |: 100|ts
  m=. (1{"1 ts){mth
  time=. d,.'-',.m,.'-',.y,.' ',.h,.':',.n,.':',.s
  dat=. (>nms),.ds,.' ',.time
  dat /: fls,. /:/: >(3|'dns'i.x.){ts;nms;size
elseif. 1 do.
  'invalid left argument'
end.
)

NB. ==================================================
NB.*dircompare v compare files in directories
NB.
NB. form: [opt] dircompare dirs
NB.
NB.   dirs = directory names
NB.   opt is optional, with up to three elements:
NB.     0{  =0 short file comparison (default)
NB.         =1 long file comparison
NB.     1{  =0 given directory only (default)
NB.         =1 recurse through subdirectories
NB.     2{  =0 file contents only (default)
NB.         =1 also compare timestamps
NB.
NB. e.g.  dircompare 'main \jbak\main'
dircompare=: 3 : 0
0 dircompare y.
:
if. 0=#y. do.
  '''long dirtree timestamps'' dircompare dir1;dir2'
  return.
end.
x.=. 3{.x.
'x y'=. cutopen y.
x=. x, '/' #~ (*#x) *. '/'~:_1{.x
y=. y, '/' #~ (*#y) *. '/'~:_1{.y

r=. 'comparing  ',x,'  and  ',y,LF
same=. 1

if. 1{x. do.
 dx=. dirtree x [ dy=. dirtree y
else.
 dx=. 2 0 dir x [ dy=. 2 0 dir y
end.

if. dx -: dy do. 'no difference' return. end.
if. 0 e. #dx do. 'first directory is empty' return. end.
if. 0 e. #dy do. 'second directory is empty' return. end.

f=.  #~ [: +./\. =&'/'
sx=. f x
sy=. f y
fx=. {."1 dx
fy=. {."1 dy

if. 1{x. do.
  fx=. (#sx)}.&.>fx
  fy=. (#sy)}.&.>fy
  dx=. fx 0 }"0 1 dx
  dy=. fy 0 }"0 1 dy
end.

if. #j=. fx -. fy do.
  same=. 0
  r=. r,LF,'not in  ',y,':',LF,,(list j),.LF
end.

if. #j=. fy -. fx do.
  same=. 0
  r=. r,LF,'not in  ',x,':',LF,,(list j),.LF
end.

dx=. (fx e. fy)#dx
dy=. (fy e. fx)#dy

if. #j=. dx -. dy do.
  j=. {."1 j
  cmp=. <@fcompare"1 (sx&,&.>j),.sy&,&.>j

  if. 0=2{x. do.
    f=. 'no difference'&-: @ (_13&{.)
    msk=. -. f &> cmp
    j=. msk#j
    cmp=. msk#cmp
  end.

  if. #j do.
    same=. 0
    r=. r,LF,'not same in both:',LF,,(list j),.LF
    if. 1{.x. do.
      r=. r,LF,;(,&(LF,LF)) &.> cmp
    end.
  end.

end.

if. same do. r=. r,'no difference',LF end.

}:r
)

NB. ==================================================
NB.*dirfind v find name in directory
NB. find name in directory
NB.
NB. form: string dirfind directory
NB.
NB. returns filenames in directory tree containing string
NB.
NB. e.g. 'jfile' dirfind 'packages'
dirfind=: 3 : 0
:
f=. [: 1&e. x.&E.
g=. #~ [: -. [: +./\. =&'/'
(#~ f@g"1) > {."1 dirtree y.
)

NB. ==================================================
NB.*dirpath v directory paths
NB. return directory paths starting from y.
NB. optional x.=0  all paths (default)
NB.             1  non-empty paths (i.e. having files)
NB. e.g. dirpath 'examples'
dirpath=: 0&$: : (4 : 0)
r=. ''
if. #y. do. y.=. y., '/' -. {:y. end.
dirs=. <y.
ifdir=. 'd'&= @ (4&{"1) @ > @ (4&{"1)
subdir=. ifdir # ]
while. #dirs do.
  fpath=. (>{.dirs) &,
  dirs=. }.dirs
  dat=. 1!:0 fpath '*'
  if. #dat do.
    dat=. subdir dat
    if. #dat do.
      r=. r, fpath each /:~ {."1 dat
      dirs=. (fpath @ (,&'/') each {."1 dat),dirs
    end.
  end.
end.
if. x. do.
 f=. 1!:0 @ (,&'/*')
 g=. 0:`(0: e. ifdir)
 h=. g  @. (*@#) @ f
 r=. r #~ h &> r
end.
if. #y. do. r=. r,<}:y. end.
/:~ r

)

NB. ==================================================
NB.*dirs v browse files in directory
NB. e.g.  dirs 'system/main/*.ijs'
dirs=: 3 : 0
if. -. y. -: _1 do.

  y.=. y.,(':'=_1{.y.)#'/'

  if. 0=#dr=. 1 dir y. do.
    wdinfo 'dirs';'no files in directory: ',y.
    return.
  end.

  path=. (#~ +./\.@('/'&=))>{.dr
  snms=. ;,&LF@((#path)&}.)&.>dr

  wd 'pc dirs;phandler "dirs _1"'
  wd 'xywh 8 8 126 10;cc s0 static;cn *',,path
  wd 'xywh 8 18 72 92'
  wd 'cc dirsfile listbox ws_vscroll ws_border bottommove rightmove'
  wd 'cc dirspath edit;setshow dirspath 0;set dirspath *',path
  wd 'cc dirssnms edit;setshow dirssnms 0;set dirssnms *',snms
  wd 'xywh 92 17 40 12;cc open button leftmove rightmove;cn *&Open'
  wd 'xywh 92 31 40 12;cc view button leftmove rightmove;cn *&View'
  wd 'xywh 92 45 40 12;cc run button leftmove rightmove;cn *&Run'
  wd 'xywh 92 67 40 12;cc delete button leftmove rightmove;cn *&Delete'
  wd 'xywh 92 91 40 12;cc cancel button leftmove rightmove;cn *&Cancel'
  wd 'pas 5 2;pcenter;'
  wd 'setfocus dirsfile;set dirsfile *',snms
  wd 'setselect dirsfile 0;pshow'

else.

  wdq=. wd 'q'
  ({."1 wdq)=. {:"1 wdq

  if. systype -: 'select' do. empty'' return. end.

  if. ((<syschild) e. 'view';'dirsfile') +. systype-:'enter' do.
    dirsfile wdview 1!:1 <dirspath,dirsfile

  elseif. syschild-:'open' do.
    wd 'smsel *',dirspath,dirsfile
    wd 'smopen;smfocus'
    wd 'psel dirs;setfocus dirsfile'

  elseif. syschild-:'run' do.
    load dirspath,dirsfile

  elseif. syschild-:'delete' do.
    j=. dirsfile #~  +./\. dirsfile~:' '
    j=. '"OK to delete file:',LF,LF,dirspath,j,'"'
    j=. 'mb dirs ',j,' mb_iconquestion mb_yesno mb_defbutton2'
    if. 'YES' -: 3{. wd j do.
      1!:55 <dirspath,dirsfile
      snms=. <;._2 toJ dirssnms
      len=. #snms
      if. 1<len do.
        snms=. ;,&LF &.> snms -. <dirsfile
        wd 'set dirssnms *',snms
        wd 'set dirsfile *',snms
        wd 'setselect dirsfile ',":0 >. (len-2) <. ".dirsfile_select
      else. wd 'pclose'
      end.
    end.

  elseif. 1 do. wd 'pclose'

  end.

end.
empty''
)

NB. ==================================================
NB.*dirss v directory string search
NB.
NB. form: string dirss directory
NB.
NB. searches for files in directory tree containing string,
NB. returning formatted display where found.
NB.
NB. e.g. 'create' dirss 'main'
dirss=: 4 : 0
bx=. # i.@#
sub=. ' '&(bx@(e.&(TAB,CRLF))@]})
fls=. {."1 dirtree y.
if. 0 e. #fls do.
  'no files in directory: ',y. return.
end.
fnd=. ''
while. #fls do.
  dat=. 1!:1 <fl=.>{.fls
  fls=. }.fls
  ndx=. bx x. E. dat
  if. rws=. #ndx do.
    dat=. (20$' '),dat,30$' '
    dat=. (rws,50)$sub(,ndx+/i.50){dat
    fnd=. fnd,LF,LF,fl,' (',(":#ndx),')'
    fnd=. fnd,,LF,.dat
  end.
end.
if. #fnd do. 2}.fnd
else. 'not found: ',x.
end.
)

NB. ==================================================
NB.*dirssrplc v directory string search and replace
NB. form: (old;new) dirssrplc files
NB. example:
NB.    ('old';'new') dirssrplc 'system/main/*.ijs'
dirssrplc=: 4 : 0
fls=. {."1 dirtree y.
if. 0 e. #fls do.
  wdinfo 'no files found' return.
end.
r=. (x.&fssrplc) each fls
b=. r ~: <'no match found'
j=. >b # fls , each ': '&, each r
}: , j ,. LF
)

NB. ==================================================
NB.*dirtree v get filenames in directory tree
NB. return filenames in directory tree as boxed matrix
NB. optional x. is a timestamp to exclude earlier files
NB. each row contains:  filename;timestamp;size
NB. e.g.  dirtree ''
NB.       dirtree 'main'
NB.       dirtree 'system/packages/*.ijs'
NB. 1997 5 23 dirtree ''   - files dated on or after date.
NB. directory search is recursive through subdirectories
dirtree=: verb define
0 dirtree y.
:
r=. i.0 3
y=. y. #~ (+./\ *. +./\.) y.~:' '
y=. y,(0=#y)#'*'
if. '/'={:y do. y=. y,'*' end.
NB. if no extension, check if file or directory:
NB. if. (-. '.' e. y) *. '/' ~: {:y do.
  NB. if. 0 e. #j=. 1!:0 y do. i.0 3 return. end.
  NB. if. 'd'=4{>4{,j do. x. dirtree y,'/*' return. end.
NB. end.
ts=. 100"_ #. 6: {. 0: >. <. - # {. 1980"_
NB. ts=.0:
'path ext'=. (b#y);(-.b=. +./\.y='/')#y
NB. read files in current directory:
if. #dl=. 1!:0 y do.
  fl=. ('d' ~: 4{"1>4{"1 dl)#dl
  if. #fl do.
    r=. r,(path&,&.>{."1 fl),.1 2{"1 fl
  end.
end.
NB. read any subdirectories:
if. #dl=. 1!:0 path,'*' do.
  dr=. ('d' = 4{"1>4{"1 dl)#dl	
  if. #dr do.
    r=. r,;x.&dirtree@(path&,@,&('/',ext)) &.>{."1 dr
  end.
end.
r #~ (ts x.) <: ts &> 1{"1 r
)
