NB. string manipulation
NB.
NB. charsub        character substitution
NB. cut            cut text, by default on blanks
NB. cuts           cut y. at x. (conjunction)
NB. deb            delete extra blanks
NB. dlb            delete leading blanks
NB. dltb           delete leading and trailing blanks
NB. dtb            delete trailing blanks
NB. delstring      delete occurrences of x. from y.
NB. ljust          left justify
NB. rjust          right justify
NB. rplc           replace in string
NB. ss             string search
NB.
NB. dropafter      drop after x. in y.
NB. dropto         drop to x. in y.
NB. takeafter      take after x. in y.
NB. taketo         take to x. in y.
NB.
NB. For example:
NB.
NB.   3       =  'de' # cuts _1 'abcdefg'
NB.   'abcfg' =  'de' delstring 'abcdefg'
NB.   'abcde' =  'de' dropafter 'abcdefg'
NB.   'defg'  =  'de' dropto    'abcdefg'
NB.   'fg'    =  'de' takeafter 'abcdefg'
NB.   'abc'   =  'de' taketo    'abcdefg'

NB. =========================================================
NB.*cuts v cut y. at x. (conjunction)
NB. string (verb cuts n) text
NB.   n=_1  up to but not including string
NB.   n= 1  up to and including string
NB.   n=_2  after but not including string
NB.   n= 2  after and including string
cuts=: 2 : 0
if. n.=1 do. [: u. (#@[ + E. i. 1:) {. ]
elseif. n.=_1 do. [: u. (E. i. 1:) {. ]
elseif. n.= 2 do. [: u. (E. i. 1:) }. ]
elseif. 1 do. [: u. (#@[ + E. i. 1:) }. ]
end.
)

NB. =========================================================
NB.*cut v cut text, by default on blanks
NB.*deb v delete extra blanks
NB.*dlb v delete leading blanks
NB.*dltb v delete leading and trailing blanks
NB.*dtb v delete trailing blanks
NB.*delstring v delete occurrences of x. from y.
NB.*ljust v left justify
NB.*rjust v right justify
NB.*ss v string search

cut=: ' '&$: :([: -.&a: <;._2@,~)
deb=: #~ (+. 1: |. (> </\))@(' '&~:)
delstring=: 4 : ';(x.E.r) <@((#x.)&}.) ;.1 r=. x.,y.'
dlb=: }.~ =&' ' i. 0:
dltb=: #~ [: (+./\ *. +./\.) ' '&~:
dtb=: #~ [: +./\. ' '&~:
ljust=: (|.~ +/@(*./\)@(' '&=))"1
rjust=: (|.~ -@(+/)@(*./\.)@(' '&=))"1
ss=: (#i.@#) @ E.

NB. =========================================================
NB.*dropafter v drop after x. in y.
NB.*dropto v drop to x. in y.
NB.*takeafter v take after x. in y.
NB.*taketo v take to x. in y.

dropto=: ] cuts 2
dropafter=: ] cuts 1
taketo=: ] cuts _1
takeafter=: ] cuts _2

NB. =========================================================
NB.*charsub v character substitution
NB. characterpairs charsub data
NB. For example:
NB.    '-_$ ' charsub '$123 -456 -789'
NB.  123 _456 _789
NB. Use <rplc> for arbitrary string replacement.
charsub=: 4 : 0
'f t'=. ((#x.)$0 1)<@,&a./.x.
t {~ f i. y.
)

NB. =========================================================
NB.*rplc v replace in string
NB. replace characters in text string
NB. syntax: text rplc old;new
rplc=: 4 : 0
'o n'=. ,&.>y.
l=. #o
c=. o E. x=. ,x.
if. (0<l) *: 1 e. c do. x return. end.
bx=. #i.@#
c=. bx c
while. 0 e. d=. 1,<:/\(#o)<:(}.-}:)c
do. c=. d#c end.
p=. (i.#x) e. 0,c
x=. p <;.1 x
b=. o&-:@(l&$) &> x
f=. n&,@(l&}.) &.>
;(f b#x) (bx b) }x
)
