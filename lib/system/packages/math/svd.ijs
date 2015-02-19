NB. singular value decomposition
NB.
NB. for real matrices only

require 'system/packages/math/jacobi.ijs'

NB. =========================================================
NB. svd
NB. returns:  left singular vectors;singular values;right singular vectors
svd=: 3 : 0
if. b=. </$y. do. y.=. |:y. end.
'r s'=. jacobi (|:y.) mp y.
t=. %:r
u=. (y. mp s) %"1 t
|.^:b u;t;s
)

NB. =========================================================
NB. test for random matrices of size y. (default 3 3), or given matrix
NB. e.g. testsvd 4 5
testsvd=: 3 : 0
if. 2=#$y. do. mat=. y.
else. mat=. ? (2{.y.,3 3) $ 10 end.
'x y z'=. svd mat
NB. mat should be:
t=. x mp (diagmat y) mp |: z
clean each mat;t;mat-t
)
