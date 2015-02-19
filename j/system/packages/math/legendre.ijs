NB. legendre symbol and quadratic residues
NB.
NB. legendre         Legendre symbol (n/p) for integer n, odd prime p
NB. quadres          quadratic residues of p
NB. quadrec          quadratic reciprocity
NB.
NB. e.g.
NB.      7 quadrec 11
NB.   _1
NB.
NB.      (>:i.7) legendre 7
NB.   1 1 _1 1 _1 _1 _1

quadres=: /:~ @ ~. @ (| *:@}.@ i.)
quadrec=: legendre * legendre~

NB. =========================================================
NB. legendre  (n/p) for integer n, odd prime p
NB.
NB. form: p legendre n

legendre=: 4 : 0 "0
p=. x.
n=. p|y.
if. n=0 do. 0 return. end.
r=. 1
while.
  parity=. 0
  while. 0=1|j=. n%2 do.
    n=. j
    parity=. -.parity
  end.
  if. 8=16|parity*<:*:p do.
    r=. -r
  end.
  n>1
do.
  if. 4=8|(<:n)*<:p do.
    r=. -r
  end.
  j=. n
  n=. n|p
  p=. j
end.
r
)

NB. alternative legendre for n < p that is more efficient for small p:
NB. legendre=: [: {&_1 1 |~ e. (| *:@}.@i.)@]
