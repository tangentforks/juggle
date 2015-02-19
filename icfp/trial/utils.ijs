require 'isigraph'
coclass 'z'
NB. Times & Dates

NB. Get time-of-day, hh mm ss only (no date).  y. is immaterial
tod =: 13 : '6!:0 y.'
todhms =: 13 : '3 }. tod y.'
todymd =: 13 : '3 {. tod y.'
NB. Convert time-of-day y. (hh mm ss) to scalar milliseconds.  In case y. has extra
NB. components, could take just the last 3.  If y. is a scalar, this'll work too, converting
NB. the seconds to milliseconds
hmstomsec =: (13 : '1000 * 24 60 60 #. y.' "1) :. msectohms
msectohms =: (13 : '24 60 60 #: y. % 1000' "0) :. hmstomsec
NB. Convert timestamp y. (y m d hh mm ss) to minutes.  We aren't careful about times > 1 day
ymdhmstomin =: (13 : '60 %~ 0 12 31 24 60 60 #. y.' "1) :. mintoymdhms
mintoymdhms =: (13 : '0 12 31 24 60 60 #: y. * 60' "0) :. ymdhmstomin
NB. convert minutes to seconds
mintosec =: 60&*
NB. Convert minutes y. to msec
mintomsec =: *&60000

NB. Convert time-of-day hh mm [ss] to HH:MM[:SS] character string
disphms =: 13 : '}. ; <@:('':''&,)@:(2&displdzero)"0 <. y.'

NB. y. is [yy] mm dd, result is string [yy/]mm/dd
NB. x. is number of digits to use for each element of y.; default 2
dispymd =: (2&$:) : (13 : '}. ; x. <@:(''/''&,)@:displdzero"0 y.') "1 1 1

NB. Display y. with a timestamp prepended
dispwithts =: 3 : 'display (disphms todhms 0) , '' '' , y.'

NB. x. is 0 to force dates to be integer, 1 to allow fraction (default 0)
NB. y. is y m d
NB. Result is 1 if the y m d is valid (works only in 1997 - 2099) scaffolding
ymdvalid =: (0&$:) : ((13 : '(1 13 brackets 1{y.) *. ((1 , (1{y.) { (29 + 0 = 4 | 0 { y.) 2} 0 32 29 32 31 32 31 32 32 31 32 31 32) brackets 2{y.) *. x. +. (-: <.) y.') :: 0:)

NB. Year 2000 correction, takes yy to yyyy, post-1990
yytoyyyy =: ((1990&+)@(100&|)@(10&+))

NB. Number of days in each month of year y.
daysinmonth =: 13 : '(28 + 0 = 4|y.) 1} 31 0 31 30 31 30 31 31 30 31 30 31'

NB. Adverb.  Apply u. to the timestamps x. and y.
onts =: &(0 12 31 24 60 60&#."_)
underts =: &.(0 12 31 24 60 60&#."_)

NB. x. and y. are timestamps (ymdhms)
NB. Result is 1 if x. is earlier than y.
earliertsthan =: < onts

NB. Adverb.  m. is the component to modify
addtots =: + applytoselectiond ]: "0 1
NB. x. is a number of minutes, y. is a timestamp (ymdhms or hms)
NB. Result is a timestamp (possibly invalid) that is x. minutes before y.
minutesafterts =: _2 addtots
minutesbeforets =: - ux_vy minutesafterts
secondsafterts =: _1 addtots
secondsbeforets =: - ux_vy secondsafterts

NB. Auditing utilities

NB. y. is a string; result is 1 if all characters are numbers
NB. except first character which may be a sign
isallnumeric =: 13 : '*./ ((}.~ (e.&'' +-_'')@{.@(1&{.))y.) e. ''0123456789''' "1

NB. Character Utilities

delblank =: 13 : '(-. *./\ '' ''=y.) # y.'
delnblank =: 13 : '(-. *./\ '' ''~:y.) # y.'
NB. slowest crtolf =: (]`(LF"_)) @. (CR&=) "0
NB. slow crtolf =: ((=&CR)`(,:&LF))} "1
crtolf =: LF&(([`((booltondx~ CR&=)@])`])}) "1
crlftolf =: 13 : '(-. (CR,LF) E. y.) # y.'
lflftolf =: 13 : '(-. (LF,LF) E. y.) # y.'
lftocrlf =: ; @ (<@,&(CR,LF) onpiecesbetweenm LF)

NB. Adverb
NB. m. is the domain of y.
NB. Result is verb such that:
NB. 0{x. is a list of items; 1{x. is another list of the same length  (so 2 = #$x.) 
NB. items of y. matching 0{x. are replaced by the corresponding element of 1{x.
xlateindomain =: (,"_1 _ & ]:) ux_vy ((0&{ ux_vy i.) { 1&{@[)
NB. 0{x. is a list of chars; 1{x. is another list of the same length  (so 2 = #$x.) 
NB. chars of y. in 0{x. are replaced by the corresponding element of 1{x.
xlatechars =: a. xlateindomain

NB. x. is string, y. is string; result is 1 if x. is in y.
isinstring =: +./ @: E."1

NB. u. is a verb, v. is a string, y. is a string
NB. Result is u. applied to pieces of y. that start with v.
onstringsstartingwith =: ]. ( (&E.) (;.1) ] ) [.
NB. u. is a verb, v. is a string, y. is a string
NB. Result is u. applied to pieces of y. that start with v.
onstringsendingbefore =: ]. ( (&E.) (;._2) ] ) [.

NB. x. is source;target  y. is string  result has source replaced by target
NB. NOTE the source must not have any self-overlaps, in any context!
stringreplace =: 1&{::@[   ;@({.@] , (,L:0"_ 0 }.))  0&{:: ux_vy (#@[  ({.@] , (}.L:0 }.)) E. (<@(i.&1@[ {. ]) , <;.1) ])

NB. *** Regular-expression utilities
NB. Adverb.  x. is regexp, y. is string, result is 1 if x. is in y.
stringhasregexp =: (0&<:)@:((<0 0)&{)@rxmatch

NB. Formatting Utilities

NB. y. is value
NB. x. is strings to use for 0, +, - (default ' +-')
NB. Result is string, according to sign of y.
selsign =: (' +-'&$:) : (* uy_vx {::)

NB. x., y. are as to ":
NB. Result uses - instead of _ for sign
formatminus =: (('';'';'-')&selsign@] , (": bivalent |))"0 butifnull ''
NB. Same, but uses plus for positive numbers
formatplus =: (' +-'&selsign@] , (": bivalent |))"0 butifnull ''

NB. x. is field format as for ":   y. is fractional value
NB. Result is string form of 100 * number
disppct =: ": (100&*)
NB. Signed version of the above.  Sign is placed right next to the number.
sdisppct =: 13 : '(- {. +. x.) {.^:(0&~:@[) (selsign y.) , (j. {: +. x.) ": 100 * | y.' "0 0 0

NB. x. is field format as for ":   y. is a numeric (must be nonnegative)
NB. Result is string form with leading zeros included
displdzero =: 13 : '(- {. +. x.) {.!.''0'' (j. {: +. x.) ": y.' "0 0 0

NB. y. is string, x. is 2 (possibly boxed) strings to put y. between
NB. If x. is just 1 element, it is used for both ends
enclosing =: 13 : '(>{.x.) , y. , (>{:x.)'

NB. y. is a list of names; the names and their values are displayed.
NB. x., if given, is the precision
putdata =: (0j8&$:) : (13 : 'display ;:^:_1 , x. (,&''=''L:0@] , (":^:(2: ~: 3!:0@:]) ".) L:0)"0 ;: y.')

NB. Enclose in quotes
enquote =: '"'&enclosing

NB. Enclose in parens
enparen =: '()'&enclosing

NB. y. is a string, result is string with multiple blanks replaced by one blank
removemultiplespaces =: (#~ -.@('  '&E.))

NB. y. is string, xx [yy/zz]    Result is numeric, with the fraction divided
fracval =: 13 : '> (#.~ % ])&>/ (<@".) onpiecesbetweenm ''/'' y.'
NB. y. is string mm/dd/yy   Result is int, yymmdd (yy*10000 + mm*100 + dd)
dateval =: 13 : '100 #. _1 |. ". onpiecesbetweenm ''/'' y.'
NB. y. is string.  If there are 16ths (i. e. '[yy]), convert 'yy to yy/16
fracto16 =: ;@:((,&' ')&.>)@:(,&(<'/16'))@:((({.&.".)@:(,&' 0'))&.>)@:(< onpiecesbetweenm '''') ^: (''''&e.)
NB. y. is string, either in 16ths xx 'yy   or in fracval form
NB. x. is value to use in case of error (default 0)
frac16val =: (0&$:) : ( (fracval @: fracto16 @ ]) :: [)

NB. y. is default value, x. is (optionally null) value
NB. Result is a scalar
defaultscalar =: {. @: ,

NB. x. is default value, y. is string (supposedly representing a number)
NB. Result is a scalar
execscalar =: 13  : 'x. defaultscalar~ x. ". y.'

NB. Return 1 if y. is in the half-open interval [ x. )
brackets =: >/ @: <: "1 0

NB. Return vector with 1 in position of each change in y.
NB. Always a 1 in the first position
changepos =: 13 : '(-.@:(-:"_1) _1&(|.!._)) y.'

NB. Zero all but the first x.  values in y.
keepmsds =: (0:`(<@<@<@i.@(<.#))`])}

NB. x. (default 1, max 9) is a scalar, y. is a scalar
NB. Result is y. rounded to x. significant digits (base 10)
truncytox =: (1&$:) : (13 : 'x. keepmsds&.(10&#.^:_1) y.') "0 0 0

NB. y. is a number
NB. result is y. with one significant digit, which is
NB. rounded up to the nearest of 1 2 5
sig125 =: ( (({&0 2 5 10)@:(+/)@:(0.1 1.1 4.1&<)"0)@:(1&keepmsds) ) &. (10&#.^:_1) &. (*&1000)

NB. y. is anything
NB. Result is 1 if all the elements of y. are the same
allsame =: -:!.0 (1&|.)

NB. y. is a number
NB. Result is y. rounded to 1/16th
roundto16th =: (<.@:(>:&.+:))&.(16&*)

NB. Adverb.  x. is a verb, result is gerund form
NB. J3.04 fails asgerund =: 11 : '(13 : x.) ` '''' '
asgerund =: ` ''

NB. y. is a string, result is gerund form of string
gerundof =: 3 : '13 : y. ` '''''

NB. Graphics stuff

NB. x. is linesize [, style]   y. is 3 $ rgb
NB. set color, pick up pen
glpencolor =: (1&glpencolor) : (13 : '(glpen x. default 0,PS_SOLID) ] (glrgb y.)')

NB. x. is 2 $ interval   y. is value(s) (any rank)
NB. Result is fractional position(s) within interval
invlerp =: ( ({.@[ - ]) % -/@[ )"1 _ :. lerp

NB. x. is 2 $ interval y. is fractional position(s) within interval (any rank)
NB. Result is value(s)
lerp =: (+/@:* (,~ -.))"1 0"1 _ :. invlerp

NB. x. is a list of points, in ascending order, y. is value
NB. result is interval . fractional position  for the interval bracketing y.
NB. If y. is out of bounds, use the endpoint
NB. After the test for too low/too high, we keep the vector of items of x. less than y., and
NB. the first item of x. ge y..  The count of these, -2, is the integer part, and we invlerp
NB. within the last 2 to find the fraction
piecewiseinvlerp =: (( ( (] (-&2@#@]  +  (invlerp~ _2&{.)) >:@(i.&0)@:< {. [) ` (<:@#@[)) @. ((>: {:)~)) ` 0:) @. ((< {.)~) "1 0

NB. x. is a list of vectors, representing data values, each vector at one point
NB. y. is interval . fractional position within interval
NB. Result is value
piecewiselerp =: 13 : '((,~ -.) 1 | y.) +/@:(*"_1)  ((#x.) | (, >:) <. y.) { x.'"_ 0

NB. y. is 2 2 $ target interval , source interval
NB. Result is polynomial which maps from source to target
lerppoly =: 13 : '-~/\ (lerp invlerp&0 1)/ y.'

NB. x. is polynomial (item 0 is the constant)   y. is argument
NB. Result is evaluated polynomial
poly =: {.@[ + (* {:)~

NB. y. is a fractional position in the display, range 0 to 1
NB. Result is in isigraph units
fractoisigraph =: (*&1000) :. isigraphtofrac
isigraphtofrac =: (%&1000) :. fractoisigraph

NB. Adverb.  u. is boolean function number
NB. The boolean function is applied to the integer arguments x. and y.
bitfunc =: (b. /) &. #: @ , "0
bitor =: 7 bitfunc
bitand =: 1 bitfunc
bitxor =: 6 bitfunc
bitclr =: 4 bitfunc  NB. 1s in x. are turned off in y.

NB. x. is two numbers  y. is a number  result is 1 if y is in the [ )  interval
inhalfopeninterval =: ~:/ @: > "1 0

NB. x. is list, y. is default values, result is x. extended to length of y.
default =: [ , (}.~ #)~

NB. y. is a boolean list
NB. Result is the indices of the 1s
booltondx =: #  i.@#

NB. Adverb.  Select indexes of y. corresponding to the 1s in (u. y.)
ndxforu =: ]: # i.@#

NB. x. is (starting position,length), y. is list
NB. result is the selected portion
substr =: (+ i.)/ ux_vy { "1 _

NB. y. is a list, result is 1 if list is in sorted order
listissorted =: /: -: i.@#

NB. 0{::x. is list of target keys
NB. 1{::x. is list of source keys
NB. y. is list of data
NB. Result is data, permuted so that items with matching keys match if possible.
NB.  Unmatched items are assigned in order from the beginning of the arrays.
NB.  If (0{::x.) <&# (1{::x.), y. is truncated BEFORE matching elements are assigned.
NB.  If (0{::x.) >&# (1{::x.), the last element of y. is repeated to fill the surplus.
NB. Ex: (0 1 2 ; 5 0) permuteytomatchkeys 'a' ; 'b'
NB. 'b' ; 'a' ; 'b'   (the second b is a default repeat)
pymkmatch =. #@[ {. i.!.0 , ((0&>.)@-&# $ #@[)  NB. vector, shaped like x., but giving for
												NB. each ele of y. the position in x. it goes to,
												NB. or #x. if no match
pymkfill =. ( ((-.~ i.@#)@]) ` (((= #) ndxforu)@]) ` ] )}  NB. fill out the entries of pymkmatch
												NB. that were #x., assigning unique values
												NB. to them
pymkinvperm =. (/:@[ <. (<:@#@]) ) { ]  NB. Invert the permutation, to give a list of
											NB. elements of y. to produce each x.; clamp
											NB. the list to #y., then extract the elements
											NB. to produce the final result
permuteytomatchkeys =: ( (null pymkfill pymkmatch)&>/@[ pymkinvperm ] ) f.

NB. x. and y. are lists
NB. Each element of y. is taken away from x., but only once (multiples in y.
NB. take away matching items of x., but only up to the number of occurrences
NB. in y.  The order of remaining items of x. is destroyed.
NB. We repeatedly take the nub of y. away from y. and x.
xminusyonce =: (0&{::) @: ( ( ( (#~ -.@~:)@[ , -.&(~.!.0) ) ,&< (#~ -.@~:)@] ) &> / ^:_ ) @: (,&<)

NB. y. is anything
NB. result is a (parenthesized) string that, when evaluated, equals y.
nountostring =: 3 : 'enparen 5!:5 <''y.'''

NB. obsolete NB. x. is 2- or 3-element boxed list (element must be representable as charstrings to ":)
NB. obsolete NB.   if 2=#x., it is a monad, else dyad
NB. obsolete NB. y. is a locale name (unboxed)
NB. obsolete NB. x. is executed in the locale given by y.
NB. obsolete NB. result is the result from x.
NB. obsolete exeinlocale =: 13 : '". (nountostring@{. butifnull '''' > _2 }. x.) , '' '' , (_2{::x.) , ''_'' , y. , ''_  '' , nountostring _1{::x.'
NB. obsolete 
NB. Adverb.  u. is a verb; x. is a list of locales; y. is arguments.  u. y. is executed in each locale in x.
inlocalesx =: ((((]:@[) 18!:4)~)"0 _ ([ 18!:4) (18!:5)@(''"_))

NB. obsolete 
NB. obsolete 
NB. obsolete NB. y. is name of locale; it is expunged
NB. obsolete eraselocale =: 18!:55
NB. obsolete 
NB. obsolete 
NB. Adverb: y. is initial state vector, x. is a sequence of cells
NB.  which become the x. to u.
NB. The verb u. should be written so that 0{::result becomes a cell of result,
NB. 1{::result becomes y. to next cell
applytoprefixes =: ((0&{::"1) @: > @: }. @: (( (]:&.> {:@>) /\.)&.|.)) @ ( (''&;)@] ; <"_1@[ )

NB. Adverb: y. is anything, x. is anything, (x.&u.) is applied to each infix of length #x.
appliedtoinfixes =: 1 : 0
[: y.
:
(#x.) (x.&u.)\ y.
)

NB. x. is a boxed program string
NB. y. is arguments to it
NB. x. is converted to a function and executed with y. as its argument
exex =: 4 : ' (3 : x.) y. '

NB. y. is boxed locale name
NB. Result is 1 if locale exists
localeexists =: e.   (4!:1)@:6:

NB. Indicate which script defined unboxed name y.
whichscript =: 13 : '((''Not from script''"_)`({ 4!:3))@.(0&<:) (4!:4) < > y.'

NB. y. is a string; expunge the variable of that name
expunge =: 13 : '4!:55 < y.'

NB. y. is a string; result is vector of boxed names beginning with y.
NB. If x. is present, only those name classes are searched (default 0 1 2 3)
NB. J3.04 bug: a: ,  required so s: doesn't think type is unboxed
listnameswithprefix =: (0 1 2 3&$:) : (13 : '(a: , ({.y.) 4!:1 x.) ( (] -: ({.~ #))S:0 _ # [ ) y. ')

NB. y. is a string.  We call the _close event for each subwindow (signified by
NB. existence of a variable with that prefix)
closewindowswithprefix =: 13 : '(#y.) (null@".@:(,&''_close 0'')@:(}. >)) rnk 0 (0 listnameswithprefix y.)'

NB. y. is a string
NB. x. is list of name classes (default 6, meaning locale)
NB. Return the (deprefixed) locales that have y. as a prefix
listnamesdroppingprefix =: (6&$:) : (13 : '(#y.) }. L:0 x. listnameswithprefix y.')

NB. x. and y. are anything
NB. Result is 1 if y. is lexicographically >= x. (i. e. using /:)
lexygex =: 13 : '{: /: x. ,&< y.'
NB. Result is 1 if y. is lexicographically > x. (i. e. using /:)
lexygtx =: 13 : '{. \: x. ,&< y.'

NB. u. is gerund, v. is a verb.  [x.] (k{u.)`:0 &. v is applied to cell k of y.
respectively =: 2 : 0
a: (<@:((,'2')&(,&<))@:((<,']')&,) "0 u.) respectively v. y.
:
z =. 0 {. y.	NB. prepare the proper shape
for_y. y. do. z=.z, x. (((#m.)|y_index){m.)`:0 &.v. y end.
z
)

NB. y. is a character string; we add on the current locale name (if there is no locale already)
inthislocale =: (, '_'&enclosing@>@(18!:5)@(0&$))^:('_'&~:@{:)

NB. Statistical functions

NB. y. is vector of observations
NB. Result is mean
mean =: +/ % #

NB. y. is a vector
NB. Result is rms value
rms =: mean&.(*:"_)

NB. y. is vector of #observations , sum , sumsq
NB. Result is variance
variancepoly =: ({: - *:@{.) @ (}. % {.)

NB. y. is vector of observations
NB. Result is vector of sum , sumsq % # observations
varianceinfo =: (# , +/ , +/@:*:)

NB. y. is vector of observations (any rank)
NB. Result is mean,variance
moments =: (- *:)~/\ @ (# %~ +/ ,&,: +/@:*:)

NB. x. and y. are lists to be regressioned (x. independent, y. dependent)
NB. Result is 5 $ values to pass into regress
regressinfo =: (#@] , +/@[ , +/@] , +/@:* , +/@:*:@[)

NB. x. is vector of 4 indices
NB. y. is vector of data
NB. Result is the determinant of the selected indices of the data
fetchdet =. 13 : '-/ . * (2 2 $ x.) { y.' "1
NB. y. is result from regressinfo (s,sx,sy,sxy,sxx)
NB. Result is regression coeffs a,b: multipliers of 1,independent
regress =: ((2 4 $ 2 1 3 4  0 2 1 3)&fetchdet % 0 1 1 4&fetchdet) "1 f.

NB. x. and y. are lists to be regressioned (x. independent, y. dependent)
NB. Result is a, b, standard error
regresssigma =: (regress@regressinfo ([ , rms@({:@] - (p. {.))) ,:)



NB. File searching

NB. y.is filename search path
NB. Result is list of files in the path - qualified to the same level
NB. as given in y.
searchdir =: 13 : '(; }: <;.2 y. , ''\'') ,L:0 butifnull (0$a:) 0 {"1 (1!:0) y.'

NB. x. is character string, y. is filename search path
NB. Result is script file names containing x.
findinscript =: 4 : 0
x. (((+./)@:E. 1!:1) rnk _ 0 # ]) searchdir y.
)

NB. x. is character string, y. is filename search path
NB. files with the strings are opened
editinscript =: 4 : 0
(null @: wd @: ('smsel "'&,) @: (,&'";smopen') @: >) rnk 0 x. findinscript y.
)

NB. Adverb.  Applies x. u. to the data in files y., without writing the file
applytofiles =: (]: bivalent (1!:1))"0 _ 0 bivalent searchdir

NB. Adverb.  Applies x. u. to the data in files y., write results to the file
modifyfiles =: ((]: bivalent (1!:1)) 1!:2 ])"0 _ 0 bivalent searchdir

NB. Count words in file.  Returns #lines with string, # blank lines, #comment lines.  y. is file data
NB. x., if given, is string to search for in lines, returning count containing it.  Default
NB. is '', which appears in all lines & gives a count of # lines
wcfile =: (''&$:) : (13 : '+/ x. ( (+./@E.) , (0&=)@#@] , (''NB.''&-:)@(3&{.)@] )S:_ 0 (}.~ <:@(i.&0)@('' ''&=)) L:0 < onpiecesbetweenm LF y.')

NB. y. is file descriptor, result is total wcfile in all files.  x., if given, is string to
NB. check for
wcfiles =: +/ @: (wcfile applytofiles)

NB. x. is string, y. is file data
NB. lines starting with x. (after removing leading blanks) are deleted
NB. We add an LF and take it away when we're done
dellinesprefixed =: 13 : '}: ; x. ( (,&LF@])`(''''"_) @. ( ([ -: (#@[ {. ]))  (}.~ (i.&0)@('' ''&=)) ) ) L:0 < onpiecesbetweenm LF y.'

NB. examples:
NB. 'obsolete' wcfiles 'd:\trade\*.ijs'
NB. 'NB. obsolete' dellinesprefixed modifyfiles 'd:\trade\*.ijs'
NB. ('oldstring';'newstring') stringreplace modifyfiles 'd:\trade\*.ijs'

NB. HTML stuff

NB. y. is a string, result has html tags (paired <...>) removed.
NB. We don't handle nesting, because YAHOO had a bug that left a hanging <a tag.
NB. To restore nesting, change the (]`[@.(*@[))/\.&.|.  to  +/\
removehtml =: 13 : '(''&amp;'';''&'') stringreplace (''&quot;'';''"'') stringreplace (''&nbsp;'';'' '') stringreplace ( -. (+. _1&(|.!.0)) 0 < ([^:(0&~:@[))/\.&.|. -/ ''<>'' ="0 _ y. ) # y.'
NB. nest removehtml =: 13 : '(''&nbsp;'';'' '') stringreplace ( -. (+. _1&(|.!.0)) 0 < +/\ -/ ''<>'' ="0 _ y. ) # y.'

NB. File utilities
NB. x. and y. are arguments to jreplace - the suffix (.jf default) must be present
NB. The file is locked before jreplace is run & unlocked afterwards
lockedjreplace =: 4 : 0
jf =. (<f =. 1!:21 {. y.) 0} y.
while. -. 1!:31 f , 0 , 1!:4 f do.
  wd 'mb "Lock failure" "Lock not granted on ' , (0{::y.) , '" mb_ok'
end.
x. jreplace jf
1!:22 f
NILRET
)

NB. x. is target drive ; source drive
NB. y. is <drive_placeholder:fileid; the file is copied from drive to drive, in the same path
copydrive =: 4 : 'null (1!:1 (1{x.) 0}L:0 y.) 1!:2 (0{x.) 0}L:0 y.' rnk 1 0

NB. y. is filename (boxed); x. is default date.
NB. Result is last-modified date of file
filemoddate =: 13 : '> (<x.) default~ (1&{"1) (1!:0) y.' "1 0

NB. System utilities
NB. y. is string to execute
NB. x. is sw_show type, (default sw_showminimized)
NB. Use 11!:0 instead of wd because we may redefine wd to null
winexec =: ('sw_showminimized'&$:) : (13 : '11!:0 ''winexec "'' , y. , ''" '' , x.')

NB. Reboot Windows.  y. is an option mask:
NB. 1=SHUTDOWN, 2=REBOOT, 4=FORCE, 8=POWEROFF
reboot =: ('user32 ExitWindowsEx i i'&(15!:0)) @ <

NB. y. is window name (string)
NB. result is 1 if window is defined.  Changes the selected window
NB. Use 11!:0 in case wd is redefined
selwindowifdefined =: (1:@(11!:0)@('psel '&,)) :: 0:

NB. y. is a variable name
NB. result is 1 if name is defined
ifdefined =: 13 : '0 <: 4!:0 < y.'

NB. x. and y. are sets; result is intersection
setintersect =: [ -. -.

NB. y. is n,2$ list of ranges (start,length).  Result is the ranges that are not
NB. wholly included in another range.
discardincludedranges =: (~. @: #~ ([: (>: >./\) +/"1))@:/:~

NB. Set box characters for email.  y. is 1 to go to email, _1 to come out of email
setboxforemail =: 3 : '9!:7 y. |. 9!:6 $0'

