NB. standard J library (in z locale)
NB.
NB. these definitions are assumed available to other programs
NB.
NB. see winlib.ijs  for standard windows library
NB.     jadelib.ijs for standard j library
NB.
NB. TAB            tab
NB. LF             linefeed
NB. FF             formfeed
NB. CR             carriage return
NB. CRLF           CR LF pair
NB. EAV            ascii 255
NB. noun           0
NB. adverb         1
NB. conjunction    2
NB. verb           3
NB. monad          3
NB. dyad           4
NB.
NB. assert         assert value is true
NB. bind           binds argument to a monadic verb
NB. boxopen        box argument if open
NB. boxxopen       box argument if open and 0<#
NB. bx             indices of 1's in boolean
NB. clear          clear all names in locale
NB. clearall       clear all locales
NB. cutopen        cut argument if open
NB. datatype       noun datatype
NB. def            : (explicit definition)
NB. define         : 0 (explicit definition script form)
NB. do             do (".)
NB. each           each (&.>)
NB. empty          return empty result
NB. erase          erase
NB. expand         boolean expand data
NB. inverse        inverse (^:_1)
NB. fetch          fetch ({::)
NB. leaf           leaf (L:0)
NB. list           list data formatted in columns
NB. names          formatted namelist
NB. nameclass      name class
NB. namelist       name list
NB. nc             name class
NB. nl             selective namelist
NB. on             on @:
NB. pick           pick (>@{)
NB. script         load script
NB. scriptd        load script with display
NB. smoutput       output to session
NB. sort           sort up
NB. split          split head from tail
NB. table          function table
NB. toJ            converts character strings to J delimiter (linefeed)
NB. toHOST         converts character strings to Host delimiter
NB. tolower        convert text to lower case
NB. toupper        convert text to upper case
NB. type           object type
NB. wcsize         size of execution window

NB. =========================================================
NB.*TAB n tab character
NB.*LF n linefeed character
NB.*FF n formfeed character
NB.*CR n carriage return character
NB.*CRLF n CR LF pair
NB.*EAV n ascii 255 character
NB.*noun n integer 0
NB.*adverb n integer 1
NB.*conjunction n integer 2
NB.*verb n integer 3
NB.*monad n integer 3
NB.*dyad n integer 4

NB. =========================================================
'TAB LF FF CR EAV'=: 9 10 12 13 255{a.
CRLF=:  CR,LF

'noun adverb conjunction verb monad dyad'=: 0 1 2 3 3 4

NB. =========================================================
NB.*def c : (explicit definition)
def=: :

NB.*define a : 0 (explicit definition script form)
define=: : 0

NB.*do v name for ".
do=: ".

NB.*each a each (&.>)
each=: &.>

NB.*inverse a inverse (^:_1)
inverse=: ^:_1

NB.*fetch v name for {::
fetch=: {::

NB.*leaf a leaf (L:0)
leaf=: L:0

NB.*nameclass v name for 4!:0
NB.*nc v name for 4!:0
nameclass=: nc=: 4!:0

NB.*namelist v name for 4!:1
namelist=: 4!:1

NB.*on c name for @:
on=: @:

NB.*pick v pick (>@{)
pick=: >@{

NB.*script v load script, name for 0!:0
script=: 0!:0

NB.*scriptd v load script with display, name for 0!:1
scriptd=: 0!:1

NB.*sort v sort up
sort=: /:~ : /:

NB. ========================================================
NB.*assert v assert value is true
NB. assertion failure if  0 e. y.
NB. e.g. 'invalid age' assert 0 <: age
assert=: 0 0"_ $ 13!:8^:((0: e. ])`(12"_))

NB. ========================================================
NB.*bind c binds argument to a monadic verb
NB. binds monadic verb to an argument creating a new verb
NB. that ignores its argument.
NB. e.g.  fini=: wdinfo bind 'finished...'
bind=: [. @ ("_)

NB. ========================================================
NB.*boxopen v box argument if open
NB. boxxopen    - box argument if open and # is not zero
NB. e.g. if script=: 0!:0 @ boxopen, then either
NB.   script 'work.ijs'  or  script <'work.ijs'
NB. use cutopen to allow multiple arguments.
boxopen=: <^:(L.=0:)

NB.*boxxopen v box argument if open and 0<#
boxxopen=: <^:(L.<*@#)

NB. ========================================================
NB.*bx v indices of 1's in boolean
bx=: # i.@#

NB. ========================================================
NB.*clear v clear all names in locale
NB.         returns any names not erased
NB.         also clears LOADED_j_
NB. example: clear 'myloc'
clear=: 3 : 0
try. LOADED_j_=: 0#LOADED_j_ catch. end.
". 'do_',(' '-.~y.),'_ '' (#~ -.@(4!:55)) (4!:1) 0 1 2 3'''
)

NB. ========================================================
NB.*cutopen v cut argument if open
NB. this allows an open argument to be given where a boxed list is required.
NB. most common situations are handled. it is similar to boxopen, except
NB. allowing multiple arguments in the character string.
NB.
NB. x. is optional delimiters, default LF if in y., else blank
NB. y. is boxed or an open character array.
NB.
NB. if y. is boxed it is returned unchanged, otherwise:
NB. if y. has rank 2 or more, the boxed major cells are returned
NB. if y. has rank 0 or 1, it is cut on delimiters in given in x., or
NB.   if x. not given, LF if in y. else blank. Empty items are deleted.
NB.
NB.  e.g. if script=: 0!:0 @ cutopen, then
NB.   script 'work.ijs util.ijs'
NB.
cutopen=: 3 : 0
y. cutopen~ (' ',LF) {~ LF e. ,y.
:
if. L. y. do. y. return. end.
if. 1 < #$y. do. <"_1 y. return. end.
(<'') -.~ (y e.x.) <;._2 y=. y.,{.x.
)


NB. ========================================================
NB.*datatype v noun datatype
t=. ;:'boolean literal integer floating complex boxed extended rational'
datatype=: {&t@(2&^.@(3!:0))

NB. ========================================================
NB.*empty v return empty result (i.0 0)
empty=: (i.0 0)"_

NB. ========================================================
NB.*erase v erase namelist
erase=: [: 4!:55 ;:^:(L. = 0:)

NB. ========================================================
NB.*expand v boolean expand
NB. form: boolean expand data
expand=: (&#) ^:_1

NB. ========================================================
NB.*list v list data formatted in columns
NB. syntax:   {width} list data
NB. accepts data as one of:
NB.   boxed list
NB.   character vector, delimited by CR, LF or CRLF; or by ' '
NB.   character matrix
NB. formats in given width, default screenwidth
list=: 3 : 0
w=. {.wcsize''
w list y.
:
if. 0=#y. do. i.0 0 return. end.
if. 2>#$y=. >y. do.
  d=. (' ',LF) {~ LF e. y=. toJ ": y.
  y=. [;._2 y, d #~ d ~: {: y
end.
y=. y-. ' '{.~ c=. {:$ y=. (": y),.' '
(- 1>. <. x. % c) ;\ <"1 y
)

NB. ========================================================
NB.*nl v selective namelist
NB. Form:  [mp] nl sel
NB.
NB.   sel:  one or more integer name classes, or a name list.
NB.         if empty use: 0 1 2 3.
NB.   mp:   optional matching pattern. If mp contains '*', list names
NB.         containing mp, otherwise list names starting mp. If mp
NB.         contains '~', list names that do not match.
NB.
NB.  e.g. 'f' nl 3      - list verbs that begin with 'f'
NB.       '*com nl ''   - list names containing 'com'
nl=: 3 : 0
'' nl y.
:
if. 0 e. #y. do. y.=. 0 1 2 3 end.

if. 1 4 8 e.~ 3!:0 y. do.
  nms=. (4!:1 y.) -. 'x.';'y.'
else.
  nms=. cutopen_z_ y.
end.

if. #x=. x. -. ' ' do.
  'n s'=. '~*' e. x
  x=. x -. '~*'
  b=. x&E. &> nms
  if. s do. b=. +./"1 b
  else. b=. {."1 b end.
  nms=. nms #~ n ~: b
end.
)

NB. ========================================================
NB.*names v formatted namelist
names=: list_z_ @ nl

NB. ========================================================
NB.*smoutput v output to session
smoutput=: 0 0&$ @ (1!:2&2)

NB. ========================================================
NB.*split v split head from tail
NB. examples:  
NB.    split 'abcde'
NB.    2 split 'abcde'
split=: {. ,&< }.

NB. ========================================================
NB.*table a function table
NB. table   - function table  (adverb)
NB. e.g.   1 2 3 * table 10 11 12 13
NB.        +. table i.13
table=: 1 : 0
u.table~ y.
:
(' ';,.x.),.({.;}.)":y.,x.u./y.
)

NB. ========================================================
NB.*tolower v convert text to lower case
j=. '(y.i.~''ABCDEFGHIJKLMNOPQRSTUVWXYZ'',a.)'
j=.    j,'{''abcdefghijklmnopqrstuvwxyz'',a.'
tolower=: 3 : j

NB. ============================================
NB.*toupper v convert text to upper case
j=. '(y.i.~''abcdefghijklmnopqrstuvwxyz'',a.)'
j=.    j,'{''ABCDEFGHIJKLMNOPQRSTUVWXYZ'',a.'
toupper=: 3 : j

NB. ========================================================
NB.*type v object type
t=. <;._1 '/invalid name/not defined/noun/adverb/conjunction/verb/unknown'
type=: {&t@(2&+)@(4!:0)&boxopen

NB. ========================================================
NB.*toHOST v converts character strings to Host delimiter
NB.*toJ v converts character strings to J delimiter (linefeed)
NB.*wcsize v size of execution window

NB. platform-dependent definitions:
3 : 0''
h=. 9!:12''
subs=. [. & ((((e.&) ((# i.@#)@)) (@])) })

NB. character string conversions, default:
toJ=: [
toHOST=: [

if. h e. 0 1 2 3 4 6 do.
  toJ=: (LF subs CR f.) @ (#~ -.@(CRLF&E.))
end.
if. h e. 0 1 2 4 6 do.
  toHOST=: 2&}.@;@(((CR&,)&.>)@<;.1@(LF&,)@toJ)
elseif. h=3 do.        NB. Mac
  toHOST=: CR subs LF f.
end.

NB. flag if wd available:
ifwd=. 0 <: #@(11!:0) :: _1: 'qer'

NB. size of output window (cols, rows)
if. ifwd *. h e. 2 6  do.
  wcsize=:  <:@".@(11!:0 bind 'qsmcsize')
else.
  wcsize=: 79 24"_
end.
1
)