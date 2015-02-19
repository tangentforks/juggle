NB. dgetri computes the inverse of a matrix

coclass 'jlapack'

NB. =========================================================
NB.*dgetri v computes the inverse of a matrix
NB.
NB. form: dgetri mat
NB.
NB. returns: inverse

dgetri=: 3 : 0

wdinfo 'dgetri: not yet'
return.

vsquare y.

if. iscomplex y. do.
  need 'zgetri'
  zgetri y.
  return.
end.

n=. lda=. #y.
a=. dzero + |: y.
wr=. wi=. n$dzero
jobvl=. jobvr=. 'V'
vl=. vr=. a * dzero
lwork=. 10*n
work=. lwork$dzero
info=. izero

arg=. 'jobvl;jobvr;n;a;lda;wr;wi;vl;ldvl;vr;ldvr;work;lwork;info'

(cutarg arg)=. 'dgetri' call ".arg

val=. wr
lvec=. |:s$vl
rvec=. |:s$vr

if. 1 e. wi ~: 0 do.
  val=. val + j. wi
  cx=. bx wi ~: 0
  lvec=. cx cxpair lvec
  rvec=. cx cxpair rvec
end.

lvec;val;rvec

)

NB. =========================================================
NB.*tdgetri v test dgetri
tdgetri=: 3 : 0
if. y. -: '' do. m=. m0 else. m=. y. end.
match=. matchclean;;
smoutput 'L V R'=. dgetri m
smoutput (m mp R) match V *"1 R
smoutput ((+|:L) mp m) match V * +|:L
)

NB. =========================================================
NB. test matrices:

NB. real eigenvalues 2 0.5
m0=: 8 %~ 2 2$13 9 3 7

NB. real eigenvalues 0 3
NB. note fails test because of rounding error
m1=: 2 2$2 _2 _1 1

NB. complex eigenvalues:
m2=: 2 2$1 _1 1 1

'tdgetri m0'


















DGETRI computes the inverse of a matrix using the LU factorization
computed by DGETRF.

This method inverts U and then computes inv(A) by solving the system
inv(A)*L = inv(U) for inv(A).


Arguments
=========

N       (input) INTEGER
        The order of the matrix A.  N >= 0.

A       (input/output) DOUBLE PRECISION array, dimension (LDA,N)
        On entry, the factors L and U from the factorization
        A = P*L*U as computed by DGETRF.
        On exit, if INFO = 0, the inverse of the original matrix A.

LDA     (input) INTEGER
        The leading dimension of the array A.  LDA >= max(1,N).

IPIV    (input) INTEGER array, dimension (N)
        The pivot indices from DGETRF; for 1<=i<=N, row i of the
        matrix was interchanged with row IPIV(i).

WORK    (workspace/output) DOUBLE PRECISION array, dimension (LWORK)
        On exit, if INFO=0, then WORK(1) returns the optimal LWORK.

LWORK   (input) INTEGER
        The dimension of the array WORK.  LWORK >= max(1,N).
        For optimal performance LWORK >= N*NB, where NB is
        the optimal blocksize returned by ILAENV.

INFO    (output) INTEGER
        = 0:  successful exit

        < 0:  if INFO = -i, the i-th argument had an illegal value

        > 0:  if INFO = i, U(i,i) is exactly zero; the matrix is
        singular and its inverse could not be computed.
