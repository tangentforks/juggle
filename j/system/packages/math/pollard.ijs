NB. Pollard factorizations
NB.
NB. pollardrho       Pollard rho factorization
NB. pollardpm1       Pollard p-1 factorization
NB.
NB. e.g.
NB.   1 0 1 pollardrho (*/p: 10000 20001x),7
NB.   pollardpm1 */p: 10000 20001x

require 'system/packages/math/primutil.ijs'

NB. =========================================================
NB. pollardrho      -  pollard rho factorization
NB.
NB. form:   poly pollardrho n,m
NB.    n      number to be factored
NB.    m      maximum iterations (default 1000)
NB.    poly   polynomial to be used (left argument to p.)
NB.            e.g. 1 0 3 for 1 + 3*x^2
NB.
NB. returns factor, else error message

pollardrho=: 4 : 0
'n m'=. 2{. y.,1000
n=. x: n
f=. n&| @ (x.&p.)

count=. 0
x1=. 2x
x2=. f x1
range=. 1

for_i. i. m+1 do.
  
  for. i. range do.
    x2=. f x2
    gcd=. n +. n | x2 - x1
    
    if. 1 < gcd do. return.
    end.
    
  end.
  
  x1=. x2
  range=. +: range
  x2=. f ^: range x2
  
end.

'maximum iterations exceeded: ',":m
)

NB. =========================================================
NB. pollard's p-1 algorithm
NB. returns:
NB.   0  = method failed
NB.   1  = factor not found
NB.   >1 = proper factor
NB. y. is a boxed list of 3 elements:
NB.    number to be factored
NB.    maximum prime factor of p-1 (default 10000)
NB.    list of primes to try out   (default p:i.10)
pollardpm1=: 3 : 0
'n m p'=: y.,(#y.)}.'';10000;p:i.10
n=: x: n
power=: n powermod
m=: m <. <.@%: n
pp=: primepowersto m
w=: _5 */\ pp
w=: pp
w=: >:i.1000
for_i. p do.
  s=: i
  for_j. w do.
    s=: n | s power j
    g=: n | n +. s-1
    
    if. 0=10|j do. return. end.
    if. g=0 do. break. end.
    if. g>1 do. return. end.
  end.
NB. 'g= ' out g
  g
end.
)

NB. x;pollardpm1 (*/ x: x=: p: 1e7 30101);10000;p:i.10
