NB. conversion utilities
NB.
NB. av         convert between characters and indices
NB. detab      remove tab stops
NB. dfh        decimal from hex
NB. hex        create verb for hex calculation
NB. hfd        hex from decimal
NB. mfv        matrix from vector
NB. vfm        vector from matrix
NB. quote      quote text

NB.*dfh v decimal from hex
NB.*hfd v hex from decimal
h=.   '0123456789ABCDEF'
dfh=: 16&#. @ (h&i.) f.
hfd=: dfh ^:_1 f.

NB. ============================================
NB.*hex a create verb for hex calculation
NB. e.g. 'FF' + hex '8'
hex=: &. dfh

NB. ============================================
NB.*av v convert between characters and indices
NB. e.g.   av 'abcde'
av=: 3 : '({&a.)`(a.&i.) @. (2&=@(3!:0)) y.'

NB. ============================================
NB.*mfv v matrix from vector
NB. [delimiter] mfv vector
NB. default delimiter is ' '
mfv=: 3 : 0
' ' mfv y.
:
if. 2 <: #$y. do. y.
else. ];._2 y.,x. #~ x. ~: _1{.x.,y.
end.
)

NB. ============================================
NB.*quote v quote text
NB. quote 'Pete''s Place'
a=. ''''
quote=: (a&,@(,&a))@ (#~ >:@(=&a))

NB. ============================================
NB.*detab v remove tab stops
NB. remove tabs from character string
NB. left argument is tab width, default 4
detab=: 3 : 0
4 detab y.
:
tab=. 9{a.
r=. y.
while.
  i=. >: r i. tab
  i <: #r
do.
  r=. ((x. * >. i % x.){.!.' ' }:i{.r) , i}.r
end.
r
)

NB. ============================================
NB.*vfm v vector from matrix
NB. vector from matrix, lines separated by LF
vfm=: 3 : '}:(,|."1 [ 1,.-. *./\"1 |."1 y.='' '')#,y.,.LF'