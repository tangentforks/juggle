NB. make various matrices
NB.
NB. bandmat       band matrix
NB. diagmat       diagonal matrix
NB. hilbertmat    Hilbert matrix
NB. idmat         identity matrix
NB. cidmat        counter identity matrix
NB. utmat         upper triangular matrix (of 1's)

NB. =========================================================
NB. bandmat   band matrix in position x. from diagonal y.
NB. e.g.
NB.     1 bandmat 3 5 7
NB.  0 3 0 0
NB.  0 0 5 0
NB.  0 0 0 7
NB.  0 0 0 0
NB.
NB.     _1 bandmat 3 5 7
NB.  0 0 0 0
NB.  3 0 0 0
NB.  0 5 0 0
NB.  0 0 7 0

sh=. |. !. 0                  NB. shift in zeroes
sl=. [ + #@] * _1: ^ [ < 0:   NB. signed length
bandmat=: ((sl {. ]) * [ sh =@i.@sl) f.

NB. =========================================================
NB. cidmat   counter identity matrix of size y.
NB. e.g.
NB.    cidmat 3
NB. 0 0 1
NB. 0 1 0
NB. 1 0 0

cidmat=: ]\ (([: <: +:) {. - {. 1:)

NB. =========================================================
NB. diagmat   diagonal matrix with y. on diagonal
NB. e.g.
NB.     diagmat 3 5 7
NB.  3 0 0
NB.  0 5 0
NB.  0 0 7

diagmat=: * =@i.@#

NB. =========================================================
NB. hilbertmat   Hilbert matrix of size y.
NB. e.g.
NB.     hilbertmat 3
NB.  1r1 1r2 1r3
NB.  1r2 1r3 1r4
NB.  1r3 1r4 1r5

hilbertmat=: % @ x: @ >: @ +/~ @ i.

NB. =========================================================
NB. idmat   identity matrix of size y.
NB. e.g.
NB.     idmat 3
NB.  1 0 0
NB.  0 1 0
NB.  0 0 1

idmat=: =@i.

NB. =========================================================
NB. utmat   upper triangular matrix of size y.
NB. e.g.
NB.     utmat 4
NB.  1 1 1 1
NB.  0 1 1 1
NB.  0 0 1 1
NB.  0 0 0 1

utmat=: <:/~ @ i.
