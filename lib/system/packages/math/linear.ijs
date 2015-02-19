NB. solve linear equations
NB.
NB. =========================================================
NB. elimination functions:
NB.   gauss_elimination    Gauss elimination
NB.   gauss_jordan         Gauss-Jordan elimination
NB.   simplex              simplex method
NB.
NB. =========================================================
NB. iterative methods for solving Ax=B
NB.   gauss_seidel         Gauss-Seidel iteration
NB.   jacobi_iteration     Jacobi iteration
NB.
NB. Typically gauss_seidel converges faster than jacobi, however for
NB. some matrices, jacobi will converge while gauss_seidel does not.

require 'system/packages/math/matutil.ijs'

NB. =========================================================
NB. gauss_elimination: - Gauss elimination (partial pivoting)
NB.  y. is matrix
NB.  x. is optional minimum tolerance, default 1e_15.
NB.     If a column below the current pivot has numbers of magnitude all
NB.     less then x., it is treated as all zeros.
NB.
NB. returns 3 elements: matrix;permutation;row swaps
NB. where: permutation{matrix restores the original row order
NB.        row swaps is a matrix of rows that were swapped
gauss_elimination=: 3 : 0
1e_15 gauss_elimination y.
:
m=. y.
'r c'=. $m
rws=. i.r
i=. j=. 0
p=. ''
max=. i.>./
while. (i<r-1) *. j<c do.
  k=. max col=. | i}. j{"1 m
NB. if all col < tol, set to 0:
  if. 0 < x.-k{col do.
    m=. 0 (<(i}.rws);j) } m
NB. otherwise sort and pivot:
  else.
    if. k do.
      p=. p,t=. <i,i+k
      m=. t C. m
    end.
    m=. (i,j) ppivot m
    i=. >:i
  end.
  j=. >:j
end.
q=. (,rws&-.) C. p
m;q;>p
)

NB. =========================================================
NB. gauss_jordan: Gauss-Jordan elimination (full pivoting)
NB.  y. is matrix
NB.  x. is optional minimum tolerance, default 1e_15.
NB.     If a column below the current pivot has numbers of magnitude all
NB.     less then x., it is treated as all zeros.
NB. if used to compute matrix inverse, first stitch on the identity matrix

gaussjordan=: 3 : 0
1e_15 gaussjordan y.
:
m=. y.
'r c'=. $m
rws=. i.r
i=. j=. 0
max=. i.>./
while. (i<r) *. j<c do.
  k=. max col=. | i}. j{"1 m
NB. if all col < tol, set to 0:
  if. 0 < x.-k{col do.
    m=. 0 (<(i}.rws);j) } m
NB. otherwise sort and pivot:
  else.
    if. k do.
      m=. (<i,i+k) C. m
    end.
    m=. (i,j) pivot m
    i=. >:i
  end.
  j=. >:j
end.
m
)

NB. =========================================================
NB. gauss_seidel
NB. Solves Ax=B for matrix A, vector B
NB.   y. = A;B
NB.   x. = optional max iterations (20), error tolerance (1e_8), sor (1)
NB.
NB. sor = successive-over-relaxation constant, between 1 and 2.
NB.       Default 1 means not used.
NB.       Set to adjust the convergence, typically between 1.2 and 1.7.
NB.
NB. returns table of convergents

gauss_seidel=: 3 : 0
'' gauss_seidel y.
:
'A B'=. y.
('count';'tol';'sor')=. x.,(#x.) }. 20 1e_8 1
max=. (i.>./)@|

M=. A * >:/~ i.#A
N=. M-A
Mi=. %.M

n=. Mi mp N
b=. Mi mp B
t=. b
r=. ,: t

while. count=. <:count do.
  s=. t
  t=. (sor*b + n mp s) + s*-.sor
  r=. r,t
  if.
    big=. (<_1 _2;max t){r
    (-/big) <&| tol*{.big
  do. break. end.
end.
)

NB. =========================================================
NB. jacobi_iteration
NB. Solves Ax=B for matrix A, vector B
NB.   y. = A;B
NB.   x. = optional max iterations (20), error tolerance (1e_8)
NB. returns table of convergents

jacobi_iteration=: 3 : 0
'' jacobi_iteration y.
:
'A B'=. y.
('count';'tol')=. x.,(#x.) }. 20 1e_8
max=. (i.>./)@|

m=. diag A
M=. m * idmat #m
N=. M-A

n=. N % m
b=. B % m
t=. b
r=. ,: t

while. count=. <:count do.
  s=. t
  t=. b + n mp s
  r=. r,t
  if.
    big=. (<_1 _2;max t){r
    (-/big) <&| tol*{.big
  do. break. end.
end.
)

NB. =========================================================
NB. simplex
simplex=: 3 : 0
min=. i. <./
m=. y.
while.
  r0=. }:{.m
  c=. min r0
  0 > c{r0
do.
  t=. {:"1 m
  d=. c{"1 m
  f=. (0 > d){0 _	
  r=. min f + t % d
  m=. (r,c) pivot m
end.
)

NB. =========================================================
NB. testing...

NB. (-/ . *  -: determinant) >:?.5 5$10
NB.
NB. mat=: 1 _2 _3 0 0 0 , 0 4 1 1 0 12 ,: 0 2 5 0 1 15
NB. simplex mat
NB. 1 0 0  0.2222222   0.5555556  11
NB. 0 1 0  0.2777778 _0.05555556 2.5
NB. 0 0 1 _0.1111111   0.2222222   2

NB. solve Ax=b for x
NB. A=: 6 1 _2 0 0, 0 4 0 _1 0, 1 _1 5 2 1, _1 0 1 5 0,: 0 1 0 _1 3
NB. B=: _2.2 _4.4 16.5 _19.8 18.7
NB. jacobi_iteration A;B
NB. gauss_seidel A;B

NB. ge=: gauss_elimination
NB. gj=: gauss_jordan
NB. ji=: jacobi_iteration
NB. gs=: gauss_seidel
