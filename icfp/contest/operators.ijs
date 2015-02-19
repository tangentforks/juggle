NB. GML operations
coclass'z'

addf=:addi =: 13 : '0 push +&.>/ {:"1 pop y.'
divf =: 13 : '0 push %&.>/ {:"1 pop y.'
divi =: 13 : '0 push GMLdivi {:"1 pop y.'
eqf=:eqi =: 13 : '0 push =&.>/ {:"1 pop y.'
lessf=:lessi =: 13 : '0 push <&.>/ {:"1 pop y.'
mulf=:muli =: 13 : '0 push *&.>/ {:"1 pop y.'
modi =: 13 : '0 push GMLmodi&.> {:"1 pop y.'
negf=:negi =: 13 : '0 push -&.> {:"1 pop y.'
subf=:subi =: 13 : '0 push -&.>/ {:"1 pop y.'
real =: 13 : '0 push {:"1 pop y.'
cos=:13 : '0 push GMLcos&.> {:"1 pop y.'
sin=:13 : '0 push GMLsin&.> {:"1 pop y.'
acos=:13 : '0 push GMLacos&.> {:"1 pop y.'
asin=:13 : '0 push GMLasin&.> {:"1 pop y.'
sqrt=:13 : '0 push GMLsqrt&.> {:"1 pop y.'
floor=:13 : '0 push GMLfloor&.> {:"1 pop y.'
frac=:13 : '0 push GMLfrac&.> {:"1 pop y.'
clampf=:13 : '0 push GMLclampf&.> {:"1 pop y.'
length=: 13 : '0 push $&.> {:"1 pop y.'
point=: 13 : '0 push GMLpoint {:"1 pop y.'
getx=: 13 : '0 push GMLgetx {:"1 pop y.'

GMLcos=: [: rfd 2: o. [
GMLacos=: [: rfd _2: o. [
GMLasin=: [: rfd _1: o. [
GMLclampf=: verb define
if. y.<0
	do. 0
elseif. y.>1
	do. 1
elseif.
	do. y.
end.
)
GMLdivi=: verb define
'n1 n2'=. y.
assert 0~:n2
GMLfloor n1%n2
)
GMLdivf=: %/
GMLfloor=: ([: * ]) * [: <. [: | ]
GMLfrac=: 1&#:
GMLmodi=: [: |/ |.
GMLsin=: [: rfd 1: o. [
GMLsqrt=: verb define
assert _1~:*y.
%:y.
)

NB. points, just a 3 element vector, 2.5
GMLgetx=: 0: { ]
GMLgety=: 1: { ]
GMLgetz=: 2: { ]
GMLpoint=: [: < 3: {. ]

NB. arrays, 2.6
GMLget=: verb define
'arr i'=. y.
i{arr
)
GMLlength=: $

NB. rendering, 3.8
GMLrender=: verb define
'amb lights obj depth fov wid ht file'=. y.
'P6'fappends file
'# juggle-icfp potemkin PPM file' fappends file
(":wid,ht)fappends file
'255' fappends file
((*/3,wid,ht)#'J')fappend file
file
)

NB. utility
assert=: 0 0"_ $ 13!:8^:((0: e. ])`(12"_))
rfd=: %&180 @ o. NB. radians from degrees
null=: a:
