NB. fermat  - find factor of n near square root
NB.           using Fermat's method
NB.
NB. form:  [maxiterate] fermat number
NB.
NB. returns factor and cofactor
NB.
NB. starts with x=. >.%:n, and increments by 2 until done
NB.
NB. efficient only where there is a factor near the square root
NB.
NB. e.g.  (;fermat@*/) x: p:11000 12000

fermat=: 3 : 0
1000 fermat y.
:
x=. >.@%: x: y.
u=. >:+:x
v=. 1
r=. (*:x)-y.
while. r ~: 0 do.
  if. 0=x. do.
    'max iterations exceeded' return.
  end.
  while. r>0 do.
    r=. r-v
    v=. v+2
  end.
  while. r<0 do.
    r=. r+u
    u=. u+2
  end.
  x.=. <:x.
end.
-:(u-v),u+v-2
)
