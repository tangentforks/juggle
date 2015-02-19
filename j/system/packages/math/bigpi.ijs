NB. calculate several digits of pi
NB.
NB. from Borwein
NB.
NB. each step adds about 14 digits of precision

NB. y. = number of steps
NB.
NB. e.g. y.=72 (approx 1000 digits of pi)
bigpi=: 3 : 0
a=. 545140134x
b=. 640320x ^ 3
c=. 13591409x
d=. 6541681608x
n=. i. >: x: y.
s=. (!6*n) * c + a * n
e=. (!3*n) * ((!n)^3) * b^n
m=. {:e
f=. d * -/ (s * m) % e
k=. (a*m) * <.@%: b * 10x^28*y.
k <.@% f
)
