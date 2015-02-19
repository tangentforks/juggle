NB. primes    - prime testing programs
NB.
NB. main functions:
NB.
NB.  nextprime        next prime number
NB.  prevprime        previous prime number
NB.  primesto         primes up to n
NB.  primepowersto    prime powers up to n
NB.  primeq           test for prime (uses strong pseudo prime test)
NB.
NB.  carmichaelq      test for carmichael number
NB.  mersenneq        test for mersenne prime
NB.
NB. utilities:
NB.
NB.  pprimeq          pseudo prime test
NB.  spprimeq         strong pseudo prime test
NB.
NB.  powermod         x (n powermod) y
NB.  timesmod         x (n timesmod) y

powermod=: (&|) @ ^
primesto=: p: @ i. @ (p: inverse) @ >:
timesmod=: (&|) @ *

NB. =========================================================
NB. carmichaelq
NB. test for carmichael number
NB.
NB. e.g.
NB.     carmichaelq 41 * 61 * 101
NB.   1
NB.
NB. first few such are:
NB.     (#~ carmichaelq) (>:}.i.3000) -. primesto 3000
NB.   561 1105 1729 2465 2821

carmichaelq=: 3 : 0 "0
n=. (primesto y.) -. q: y.
*./ 1 = n (y. powermod) y.-1
)

NB. =========================================================
NB. mersenneq
NB. test if prime p generates a mersenne prime
NB. i.e. _1+2^p is prime
NB.
NB. e.g.
NB.      [x=. (#~ mersenneq) p: i.20
NB.   2 3 5 7 13 17 19 31 61
NB.      _1 + 2x ^ x
NB.   3x 7x 31x 127x 8191x 131071x 524287x 2147483647x 2305843009213693951x
NB.
NB. first few such primes are:
NB. 2 3 5 7 13 17 19 31 61 89 107 127 521 607 1279 2203 2281 3217 4253 4423

mersenneq=: 3 : 0 "0
if. y.=2 do. 1 return. end.
m=. <:2^x:y.
f=. m&| @ (-&2) @ *:
0 = f^:(y.-2) 4
)

NB. =========================================================
nextprime=: 3 : 0
if. y. < <: 2^31 do.
  p: p: inverse y.+1
else.
  blk=. 100
  q=. #~ ([: -. 0: e. (p:i.11) & |)"0
  while. 1 do.
    for_n. q y. + >:i.blk do.
      if. primeq n do. n return. end.
    end.
    y.=. y. + blk
  end.
end.
)

NB. =========================================================
prevprime=: 3 : 0
if. y.=2 do. '' return. end.
if. y. < 2^31 do.
  p: <: p: inverse y.
else.
  blk=. 100
  q=. #~ ([: -. 0: e. (p:i.11) & |)"0
  while. 1 do.
    for_n. q y. - >:i.blk do.
      if. primeq n do. n return. end.
    end.
    y.=. y. - blk
  end.
end.
)

NB. =========================================================
NB. primepowersto
NB. e.g.
NB.      primepowersto 50
NB.   32 27 25 49 11 13 17 19 23 29 31 37 41 43 47
primepowersto=: 3 : 0
p=. primesto y.
s=. <.@%: y.
p0=. (p <: s) # p
w=. p0 <.@^. y.
p ^ 1 >. (#p) {. w
)

NB. =========================================================
NB. pseudo prime test
NB. apply pseudo prime test to y.
NB. result of 0 indicates composite
NB.
NB. e.g.
NB.   1 1 1 1 = 2 3 5 7 pprimeq 337     (337 is prime)
NB.   1 0 0 0 = 2 3 5 7 pprimeq 341     (341 is a 2-pseudo prime)

pprimeq=: 4 : '1 = x. (y. powermod) <:y.'

NB. =========================================================
NB. primeq   - apply strong pseudo prime test
NB. result of 0 indicates composite
NB.
NB. x. = optional primes used in test (default p:100)
NB. y. = single number to be tested
NB.
NB. e.g.
NB.     primeq _1 + 2x ^ 521
NB.   1
NB.      (#~ primeq) 10000+i.80
NB.   10007 10009 10037 10039 10061 10067 10069 10079
NB.      p: 1229+i.8
NB.   10007 10009 10037 10039 10061 10067 10069 10079

primeq=: 3 : 0 "1 0
(p:100) primeq y.
:
p=. _10 <\ x.
while. #p do.
  if. 0 e. (>{.p) spprimeq y. do. 0 return. end.
  p=. }. p
end.
1
)

NB. =========================================================
NB. strong pseudo prime test
NB. result of 0 indicates composite
NB.
NB. x. = one or more primes
NB. y. = single number to be tested
NB.
NB. e.g.
NB.         2 3 5 7 11 strongpseudop 151*751*28351
NB.      1 1 1 1 0
NB.
NB.         +/(p:i.1000) strongpseudop 151*751*28351
NB.      249

spprimeq=: 4 : 0

bx=. #i.@#

n=. x: {.y.
n1=. n-1

a=. 0
t=. n1
while. 1 do.
  if. 1=2|t do. break. end.
  t=. -: t
  a=. >: a
end.

s=. x. n powermod t
r=. s e. 1,n1
if. -. 0 e. r do. return. end.
s=. s #~ -.r

while. 0 < a=. <:a do.
  s=. n | s * s
  b=. s=n1
  r=. b (bx r=0) } r
  if. -. 0 e. r do. return. end.
  s=. s #~ -.b
end.

r +. x.=y.
)
