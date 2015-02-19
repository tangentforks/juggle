NB. text utilities
NB.
NB. conventions:
NB.   the delimiter used is LF
NB.   "paragraph" is a character string terminated by a LF
NB.               paragraphs would normally be reformatted for display
NB.   "text"      is a character string with possibly several LFs.
NB.                    
NB. main verbs:
NB.   capitalize   capitalize text
NB.   cutpara      cut character string into boxed list of paragraphs
NB.   cuttext      cut character string into boxed list of texts
NB.   foldtext     fold character string to given width
NB.
NB. utilities:
NB.   foldpara     fold single paragraph to given width
NB.   topara       convert character string into paragraphs

require 'strings'

NB. =========================================================
NB.*capitalize v capitalize text
NB. capitalize text (vector delimited by LF, or matrix)
NB.
NB. all first letters are capitalized, otherwise:
NB. x.=0  capitalize first letter following a fullstop followed by
NB.       a blank or LF or LF,LF  (sentence capitalization=default)
NB.    1  capitalize any letter preceded by a blank
NB.    2  capitalize first letter in any alphabetic string
capitalize=: 3 : 0
0 capitalize y.
:
lower=. 'abcdefghijklmnopqrstuvwxyz'
upper=. 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
shape=. $txt=. y. ,"1 ' '
txt=. ,txt
chr=. txt e. lower,upper
has=. E.~

if. x.=0 do.
  b=. 1,}: (txt has LF,LF) +. (txt has '.',LF) +. txt has '. '
  b1=. chr +. 1,}: txt e. ' ',LF
  b2=. b +. b1
  b3=. b3 > }: 0,b3=. b2#b1
  b3=. b3 (b2#i.#b2) } b2*0
  b=. b3 +. b1 *. b
elseif. x.=1 do.
  b=. chr *. 1,}:txt=' '
elseif. x.=2 do.
  b=. chr > }:0,chr
elseif. 1 do.
  wdinfo 'invalid left argument to capitalize'
end.

cap=. (upper,a.) {~ (lower,a.)i.b#txt
txt=. cap (b#i.#b) } txt
}:"1 shape$ txt
)

NB. =========================================================
NB.*cutpara v cut text into boxed list of paragraphs
NB. form: cutpara text
cutpara=: 3 : 0
txt=. topara y.
txt=. txt,LF -. {:txt
b=. (}.b,0) < b=. txt=LF
b <;._2 txt
)

NB. =========================================================
NB.*cuttext v cut text into boxed list of texts
NB. form: cuttext text
cuttext=: 3 : 0
n=. +/LF = _2 {. y.
txt=. y.,(2-n)$LF
b=. _1 |. (2$LF) E. txt
b <;._2 txt
)

NB. =========================================================
NB.*foldtext v fold text to given width
NB. form: width foldtext text
foldtext=: 4 : 0
if. 0 e. $y. do. '' return. end.
y=. ; x.&foldpara each cutpara y.
y }.~ - (LF ~: |.y) i. 1
)

NB. =========================================================
NB.*foldpara v fold single paragraph
NB. syntax:   {width} fold data
NB. data is character vector
foldpara=: 4 : 0
if. 0=#y. do. LF return. end.
r=. ''
x1=. >: x.
while.
  ind=. ' ' i.~ |. x1{.y.
  s=. y. {.~ ndx=. x1 - >: x1 | ind
  s=. (+./\.s ~: ' ') # s
  r=. r, s, LF
  #y.=. (ndx + ind<x1) }. y.
do. end.
r
)

NB. =========================================================
NB.*topara v convert text to paragraphs
NB. form: topara text
NB. replaces single LFs not followed by blanks by spaces,
NB. except for LF's at the beginning
topara=: 3 : 0
if. 0=#y. do. '' return. end.
if. 1<#$y. do. y. return. end.
txt=. toJ y.
b=. txt=LF
c=. b +. txt=' '
b=. b > (1,}:b) +. }.c,0
txt=. ' ' (b#i.#b) } txt
)
