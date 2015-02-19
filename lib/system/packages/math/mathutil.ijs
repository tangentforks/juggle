NB. math utilities
NB.
NB. clean         clean small numbers near to 0
NB. det           determinant of matrix
NB. mp            M mp N  = matrix product of M and N
NB. powermod      x (n powermod) y computes n|x^y

det=: -/ .*
mp=: +/ .*
powermod=: (&|) @ ^

NB. =========================================================
NB. clean
NB. tolerance (default 1e_10) clean numbers
NB. sets values less than tolerance to 0
clean=: 3 : 0
1e_10 clean y.
:
if. 16 ~: 3!:0 y. do.
  y. * x. <: |y.
else.
  j./"1 y.* x. <: | y.=. +.y.
end.
)


