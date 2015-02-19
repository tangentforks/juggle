NB. numeric utilities
NB.
NB.  baserep        y. in base x.
NB.  clean          clean y. to tolerance of x. (default 1e_10)
NB.  colsum         sum data columns of matrix by key
NB.  fraction       convert decimal number to fraction
NB.  groupndx       group indices of y. in x.
NB.  int01          interval in n steps from 0 to 1 (= steps 0 1,n)
NB.  linsert        linear insert x. (default 2) steps into y.
NB.  randomize      sets a random value into random link
NB.  range          range from a to b [in steps of c]
NB.  recur          solves recurrence r(i)=a(i)+r(i-1)*m(i-1)
NB.  round          round y. to nearest x. (e.g. 1000 round 12345)
NB.  rounddist      round y. to nearest x. preserving total
NB.  roundint       round to nearest integer
NB.  steps          steps from a to b in c steps

NB.*baserep v y. in base x.
baserep=:  (&#.) (^:_1)

NB.*fraction v convert decimal number to fraction
fraction=: [: (%"1 [: ,:~ +./) ,:&1

NB.*int01 v interval in n steps from 0 to 1 (= steps 0 1,n)
int01=:    i.@(+ *) % |

NB.*linsert v linear insert x. (default 2) steps into y.
linsert=:  2&$: : ([: +/\ {.@] , [ # (}. - }:)@] % [)

NB.*round v round y. to nearest x. (e.g. 1000 round 12345)
round=:    ((%&) [.) (<.@+&0.5&.)

NB.*roundint v round to nearest integer
roundint=: <.@+&0.5

NB. =========================================================
NB.*clean v clean y. to tolerance of x. (default 1e_10)
NB. form: tolerance (default 1e_10) clean numbers
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

NB. =========================================================
NB.*colsum v sum data columns of matrix by key
NB. form: key colsum mat
NB. sum data columns of matrix on key columns
NB. e.g. if column 2 of mat is age, then
NB.    2 colsum mat
NB. sums the remaining columns by age
colsum=: 3 : 0
:
nub=. ~. key=. x.{"1 y.
nub /:~ nub x.}"_1 1 key +//. y.
)

NB. =========================================================
NB.*groupndx v group indices of y. in x.
NB. Return group indices of elements of y.
NB. x. is an integer vector of the starting numbers of each group,
NB. assumed to be in ascending order.
NB. e.g.  0 0 0 1 1 1 2 2  =  0 3 6 groupndx i.8
NB. i.e.  <:@(+/@(<:/))
groupndx=: 4 : '<: (#x.) }. (+/\r<#x.) /: r=. /: x.,y.'

NB. =========================================================
NB.*randomize v sets a random value into random link
randomize=: 3 : 0
([ 9!:1) >:<.0.8*0 60 60 24 31#.0 0 0 0 _1+|.<.}.6!:0 ''
)

NB. =========================================================
NB.*range v range from a to b [in steps of c]
range=: 3 : 0
NB. range a,b[,c] = range from a to b [in steps of c]
'x y n'=. 3{.y.,1
s=. _1^y<x
x+s*n*i.>:<.n%~|y-x
)

NB. =========================================================
NB.*recur v solves recurrence r(i)=a(i)+r(i-1)*m(i-1)
NB. form: r = m recur a
NB.   r(0) = a(0)
NB.   r(i) = a(i)+r(i-1)*m(i-1)
NB. e.g    1.05 1.10 recur 100 100 100
NB.     100 205 325.5
recur=: 4 : 'r*+/\y.%r=.*/\1,x.$~<:#y.'

NB. =========================================================
NB.*rounddist v round y. to nearest x. preserving total
NB. distributive rounding
NB. round y. to nearest x. preserving total to nearest x.
NB. e.g.    0.1 rounddist 6$0.45
NB.      0.5 0.5 0.5 0.4 0.4 0.4
rounddist=: 4 : 0
r=. <.j=. ,y.%x.
($y.)$x.*r+((+/r)+/:\:1|j)<<.0.5++/j
)

NB. =========================================================
NB.*steps v steps from a to b in c steps
NB. form: steps a,b,c
steps=: {. + (1&{ - {.) * (i.@>: % ])@{:
