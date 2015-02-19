NB. Keyed-file definitions
NB. See also jfiles
NB. built from project: source\kfiles\kfiles
require 'jfiles'
NB. keyed-file database functions
NB.
NB. this script supports keyed file systems.
NB.
NB. A keyed file is a J component file in which the components
NB. are accessed using keywords.
NB.
NB. A keyword may be any character string.
NB.
NB. main functions:
NB.   kcreate     kcreate 'dat'              create file
NB.   kdir        kdir 'dat'                 keyword directory
NB.   kerase      kerase 'dat'               erase file
NB.   kread       kread 'dat';'key'          read data for keyword
NB.   kwrite      data kwrite 'dat';'key'    write date for keyword
NB.
NB. read:   if keyword not found, return '' else return value
NB. write:  if data='' then keyword is deleted

NB.*kcreate v    create file
NB.*kdir v        keyword directory
NB.*kerase v     erase file
NB.*kread v      read data for keyword
NB.*kwrite v     write date for keyword

kcreate=: kcreate_jfiles_
kdir=: kdir_jfiles_
kerase=: kerase_jfiles_
kread=: kread_jfiles_
kwrite=: kwrite_jfiles_


NB. kfilefns.ijs     keyed-file database (in files locale)
NB.
NB. file layout:
NB.   cpt    description
NB.    0     'keyed file'
NB.   1-8    unused
NB.    9     directory
NB.   10+    data components
NB.
NB. error results:
NB.    0   file create failed
NB.   _1   file not found
NB.   _2   invalid component
NB.   _3   invalid data
NB.   _4   invalid key

coclass 'jfiles'

NB. kcreate file
kcreate=: 3 : 0
r=. jcreate y.
if. r <: 0 do. return. end.
((1 8#'keyed file';'unused'),<'';i.0) jappend y.
1
)

NB. kdir file
NB. [opt] kdir file
NB.   opt = 0  sort and format directory
NB.       = 1  unsorted, as boxed list
kdir=: 3 : 0
0 kdir y.
:
y=. >{.>jread y.;9
if. x.=0 do. list (/: >)y end.
)

NB. kerase
kerase=: jerase

NB. kread file;key
kread=: 3 : 0
'f k'=. y.
'h o'=. j_open f
if. h=_1 do. return. end.
'd c'=. >jread h;9
fnd=. (#d) > ndx=. d i. <k
if. fnd do.
  r=. >jread h;ndx{c
else.
  r=. ''
end.
if. o do. jclose h end.
r
)

NB. data kwrite file;key
kwrite=: 4 : 0
x=. <x.
'f k'=. 2{.boxopen y.
if. (2=3!:0 k) *: *#k do. _4 return. end.
'h o'=. j_open f
if. h=_1 do. return. end.
'd c'=. >jread h;9
fnd=. (#d) > ndx=. d i. <k
if. fnd do.
  if. x. -: '' do.
    '' jreplace h;ndx{c
    b=. ndx ~: i.#c
    d=. b#d
    c=. b#c
    (<d;<c) jreplace h;9
  else.
    x jreplace h;ndx{c
  end.
else.
  if. -. x. -: '' do.
    free=. (10}.i.1{jsize h)-.c
    if. #free do.
      x jreplace h;{.free
      c=. c,{.free
    else.
      c=. c,x jappend h
    end.
    d=. d,<k
    (<d;<c) jreplace h;9
  end.
end.
if. o do. jclose h end.
empty''
)
