NB. built from project: addon\lapack\lapack\lapack

require 'dll'

coclass 'jlapack'

NB. lapack utils
NB.
NB. lapzero etc.
NB.
NB. cutarg        cut argument list
NB. error         display message and signal error
NB. extijs        ensure script has ijs extension
NB.
NB. clean         clean numbers near 0
NB. matchclean    if clean x-y is all 0
NB.
NB. diagmat       diagonal matrix
NB. idmat         identity matrix
NB. ltmat         lower triangular matrix
NB. utmat         upper triangular matrix
NB.
NB. ltri          return only lower triangular matrix
NB. utri          return only upper triangular matrix
NB. sltri         return only strictly lower triangular matrix
NB. sutri         return only strictly upper triangular matrix

bx=: # i.@#

izero=: 23-23
ione=: 23-22
dzero=: 1.1-1.1
done=: 2.1-1.1
zzero=: 1j1-1j1
zone=: 2j1-1j1

cutarg=: <;._1 @ (';'&,)
extijs=: , ((0: < #) *. [: -. '.'"_ e. ]) # '.ijs'"_

NB. =========================================================
matchclean=: 0: *./ . = clean @ , @: -

NB. =========================================================
diagmat=: * =@i.@#
idmat=: {.=/&i.{:

mp=: +/ . *

ltmat=: {. >:/&i. {:
utmat=: {. <:/&i. {:

ltri=: * ({. >:/&i. {:) @ $
utri=: * ({. <:/&i. {:) @ $
sltri=: * ({. >/&i. {:) @ $
sutri=: * ({. </&i. {:) @ $


NB. =========================================================
NB.*clean v clean numbers to tolerance (default 1e_10)
NB. sets values less than tolerance to 0
clean=: 3 : 0
1e_10 clean y.
:

if. L. y. do.
  x. clean each y.
else.
  if. 16 ~: 3!:0 y. do.
    y. * x. <: |y.
  else.
    j./"1 y.* x. <: | y.=. +.y.
  end.
end.
)

NB. =========================================================
NB. cxpair
cxpair=: 4 : 0
'i j'=: |: _2 [\ x.
r=. i {"1 y.
z=. j. j {"1 y.
n=. (r+z) ,. r-z
n (i,j)}"1 y.
)

NB. =========================================================
NB. error - display message and signal error
error=: 3 : 0
wdinfo y.
error=. 13!:8@1:
error ''
)


NB. lapack validation
NB.
NB. validation routines that check argument is a matrix:
NB.    vmatrix
NB.    vhermitian
NB.    vorthogonal
NB.    vsquare
NB.    vsymposdef

iscomplex=: -. @ (-: +)
ismatrix=: 2: = #@$
isreal=: -: +
issquare=: =/ @ $

NB. =========================================================
isorthogonal=: 3 : 0
q=. y. mp |: y.
*./ 0 = clean ,q - idmat $q
)

NB. =========================================================
NB. ishermitian=: 3 : 0
NB. q=. (+|:y.) mp y.
NB. *./ 0 = clean ,q - idmat $q
NB. )

ishermitian=: -: +@|:

NB. =========================================================
issymposdef=: 3 : 0
if. 0==/$y. do. 0 return. end.
y.-:|:y.
)

NB. =========================================================
f=. 2 : 'm.&(13!:8)@(#&12)@(0: e. v.)'

vmatrix=: 'argument should be a matrix' f ismatrix
vhermitian=: 'argument should be a hermitian matrix' f ishermitian [ vmatrix
vorthogonal=: 'argument should be an orthogonal matrix' f isorthogonal [ vmatrix
vsquare=: 'argument should be a square matrix' f issquare [ vmatrix
vsymposdef=: 'argument should be a symmetric positive-definite matrix' f issymposdef [ vmatrix

NB. lapack definitions

NB. liblapack requires libblas and libf2c, so force all of them here.
force_dll_load find_dll 'blas'
force_dll_load lapackdll=:find_dll 'lapack'
force_dll_load find_dll 'f2c'

NB. =========================================================
call=: 4 : 0
x=. lapackdll,' ',x.,'_ + i ',(+:#y.)$' *'
r=. x cd LASTIN=: , each y.
if. > {. r do.
  error x.;'lapack dll return code: ',": > {. r
else.
  LASTOUT=: }.r
end.
)

NB. =========================================================
docs=: 3 : 0
if. 0>4!:0 <'dirs' do. load 'dir' end.
dirs path,'doc\*.lap'
)

NB. =========================================================
need=: 3 : 0
require (<path) ,each (;:y.) ,each <'.ijs'
)

NB. =========================================================
routines=: 3 : 0
if. 0>4!:0 <'dirs' do. load 'dir' end.
dirs path,'*.ijs'
)
