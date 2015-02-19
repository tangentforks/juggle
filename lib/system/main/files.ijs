NB. file access utilities
NB.
NB. read verbs take a right argument of a filename, optionally
NB. linked with one or two numbers (as for 1!:11):
NB.   0 = start of read (may be negative)
NB.   1 = length of read (default rest of file)
NB.
NB. write verbs return number of characters written.
NB.
NB. filenames may be open or boxed character strings.
NB.
NB. string verbs write out text delimited by CRLF, and read in
NB. text delimited by LF.
NB.
NB. Use charsub (defined in strings.ijs) to substitute unwanted characters,
NB. e.g. '-_' charsub fread 'mydata.dat' replaces - with _
NB.
NB.    dat fappend fl    append
NB.    dat fappends fl   append string
NB.        fdir          file directory
NB.        ferase fl     erase file
NB.        fexist fl     return 1 if file exists
NB.    opt fread fl      read file
NB.        freadr fl     read records (flat file)
NB.        freads fl     read string
NB.    dat freplace fl   replace in file
NB.    opt fselect txt   select file
NB.        fsize fl      size of file
NB.    str fss fl        string search file
NB. oldnew fssrplc fl    search and replace in file
NB.        fstamp fl     file timestamp
NB.        fview fl      view file
NB.    dat fwrite fl     write file
NB.    dat fwrites fl    write string
NB.
NB. on error, the result is _1,
NB. i.e. for file not found/file read error/file write error

NB. ========================================================
NB.*fappend v append character text to file
NB.	The text is first ravelled. The file is created if necessary. 
NB. Returns number of characters written, or an error message.
NB. form: text fappend filename
NB. example:
NB.   'chatham' fappend 'newfile.txt'
NB. 7
fappend=: 4 : 0
y.=. boxopen y.
x.=. ,x.
f=. #@[ [ 1!:3
x. f :: _1: y.
)

NB. ========================================================
NB.*fappends v append character text to file.
NB. The text is first ravelled into a vector with each row 
NB. terminated by the CRLF pair. Any single LF or CR characters 
NB. in the text are converted into the CRLF pair. 
NB. The file is created if necessary. Returns number of characters 
NB. written, or an error message.
fappends=: 4 : 0
y.=. boxopen y.
if. -. 0 e. $x. do.
  if. 1>:#$x. do.
    x.=. toHOST x.
    x.=. x.,(LF ~: {:x.)#CRLF
  else. x.=. x.,"1 CRLF
  end.
end.
x.=. ,x.
f=. #@[ [ 1!:3
x. f :: _1: y.
)

NB. ========================================================
NB.*fdir v file directory
NB. example:
NB.   fdir 'system/main/s*.ijs'
fdir=: 1!:0

NB. ========================================================
NB.*ferase v erases a file
NB. Returns 1 if successful, otherwise _1
ferase=: (1!:55 :: _1:) @ boxopen

NB. ========================================================
NB.*fexist v tests if the file exists
NB. Returns 1 if the file exists, otherwise 0.
fexist=: 1:@(1!:4)@boxopen :: 0:

NB. ========================================================
NB.*fread v read file
NB. y. is filename {;start size}
NB. x. is optional:
NB.    = b    read as boxed vector
NB.    = m    read as matrix
NB.    = s    read as string (same as freads)
fread=: ''&$: : (4 : 0)
y.=. boxopen y.
f=. 1!:(1 11 {~ 2=#y.)
dat=. f :: _1: y.
if. dat -: _1 do. return. end.
if. (0=#x.) +. 0=#dat do. dat return. end.
dat=. toJ dat
if. 0=#dat do. '' $~ 0 $~ >:'m'e.x. return. end.
dat=. dat,LF -. {:dat
if. 'b'e.x. do. dat=. <;._2 dat
elseif. 'm'e.x. do. dat=. ];._2 dat
end.
)

NB. ========================================================
NB.*freadr v read records from flat file
NB. y. is filename {;record start, # of records}
NB. records are assumed of fixed length delimited by
NB. one (only) of CR, LF, or CRLF.
NB. the result is a matrix of records.
freadr=: 3 : 0
'f s'=. 2{.boxopen y.
max=. 1!:4 :: _1: <f
if. max -: _1 do. return. end.
pos=. 0
step=. 10000
whilst. blk = cls
do.
  blk=. step<.max-pos
  if. 0=blk do. 'file not organized in records' return. end.
  dat=. 1!:11 f;pos,blk
  cls=. <./dat i.CRLF
  pos=. pos+step
end.
len=. cls+pos-step
dat=. 1!:11 f;len,2<.max-len
dlm=. +/CRLF e. dat
wid=. len+dlm
s=. wid*s,0 #~ 0=#s
dat=. 1!:11 f;s
dat=. (-wid)[\dat
(-dlm)}."1 dat
)

NB. ========================================================
NB.*freads v read file as string
NB. y. is filename {;start size}
NB. x. is optional (b and m same as fread):
NB.    = b    read as boxed vector
NB.    = m    read as matrix
NB. freads
freads=: ''&$: : (4 : 0)
y.=. boxopen y.
f=. 1!:(1 11 {~ 2=#y.)
dat=. f :: _1: y.
if. (dat -: _1) +. 0=#dat do. return. end.
dat=. dat,LF -. {:dat=. toJ dat
if. 'b'e.x. do. dat=. <;._2 dat
elseif. 'm'e.x. do. dat=. ];._2 dat
end.
)

NB. ========================================================
NB.*freplace v replace text in file
NB. form: dat freplace file;pos
freplace=: 4 : 0
x.=. ,x.
f=. #@[ [ 1!:12
x. f :: _1: y.
)

NB. ========================================================
NB.*fselect v file selection dialog
NB. y. = DOS filespec or ''
NB. x. = optional file type list
NB. returns user selection
fselect=: 'All Files (*.*)|*.*'&$: : (4 : 0)
y.=. y.,(0 e. #y.)#'*.*'
path=. }: y. #~ b=. +./\.y.='\'
def=. y. #~ -. b
t=. 'mbopen "Select File" "',path,'" "',def,'" '
t=. t,'"',x.,'"'
t=. t,' ofn_filemustexist ofn_pathmustexist;'
wd t
)

NB. ========================================================
NB.*fsize v return file size
NB. returns file size or _1 if error
fsize=: 1!:4 :: _1: @ boxopen

NB. ========================================================
NB.*fss v file string search
NB. form: str fss file
NB. search file for string, returning indices
fss=: 4 : 0
y=. boxopen y.
size=. 1!:4 :: _1: y
if. size -: _1 do. return. end.
bx=. # i.@#
blk=. (#x.) >. 100000 <. size
r=. i.pos=. 0
while. pos < size do.
  dat=. 1!:11 y,<pos,blk <. size-pos
  r=. r,pos+bx x. E. dat
  pos=. pos+blk+1-#x.
end.
r
)

NB. ========================================================
NB.*fssrplc v file string search and replace
NB. form: (old;new) fssrplc file
fssrplc=: 4 : 0
nf=. 'no match found'
y=. boxopen y.
try. size=. 1!:4 y catch. nf return. end.
if. size=0 do. nf return. end.
'o n'=. x.
len=. #o=. ,o
if. 0 e. len,size do. nf return. end.
max=. 100000
if. max>size do.
  b=. -. 1 e. o E.  1!:1 y
  if. b do. nf return. end.
end.
path=. (#~ [: +./\. =&'\')>y.
scr=. <path,'eraseme.pls'
'' 1!:2 scr
cnt=. pos=. 0
bx=. # i.@#
fn=. n&,@(len&}.) &.>
while. pos<size do.
  blk=. 0 >. max <. size-pos
  dat=. 1!:11 y,<pos,blk
  if. len>#dat do. break. end.
  tail=. 1-len
  if. #c=. bx o E. dat do.
    while. 0 e. d=. 1,<:/\(#o)<:(}.-}:)c
    do. c=. d#c end.
    tail=. tail>.(len+{:c)-#dat
    p=. 1 (0,c) } (#dat)#0
    dat=. p <;.1 dat
    b=. o&-:@(len&$) &> dat
    dat=. ;(fn b#dat) (bx b) } dat
    cnt=. cnt++/b
  end.
  (tail}.dat) 1!:3 scr
  pos=. pos+blk+tail
  dat=. ''
end.
dat 1!:3 scr
if. 0=cnt do.
  1!:55 scr
  nf
else.
  1!:55 y
  pos=. 0
  siz=. 1!:4 scr
  '' 1!:2 y
  while. siz>pos do.
    len=. blk<.siz-pos
    (1!:11 scr,<pos,len) 1!:3 y
    pos=. pos+blk
  end.
  1!:55 scr
  (":cnt),' replacement',((1~:cnt)#'s'),' made'
end.
)

NB. ========================================================
NB.*fstamp v returns file timestamp
fstamp=: (1: >@{ , @ (1!:0)) :: _1:

NB. ========================================================
NB.*fview v view file
NB. uses standard Windows edit control,
NB. which is limited to around 20K size.
fview=: 3 : 0
y.=. boxopen y.
f=. 1!:(1 11 {~ 2=#y.)
dat=. f :: _1: y.
if. dat -: _1 do. return. end.
empty (>{.y.) wdview dat
)

NB. ========================================================
NB.*fwrite v write text to file
fwrite=: 4 : 0
y.=. boxopen y.
x.=. ,x.
f=. #@[ [ 1!:2
x. f :: _1: y.
)

NB. ========================================================
NB.*fwrites v write string to file
fwrites=: 4 : 0
y.=. boxopen y.
x.=. ":x.
if. -. 0 e. $x. do.
  if. 1>:#$x. do.
    x.=. toHOST x.
    x.=. x.,(LF ~: {:x.)#CRLF
  else. x.=. x.,"1 CRLF
  end.
end.
x.=. ,x.
f=. #@[ [ 1!:2
x. f :: _1: y.
)