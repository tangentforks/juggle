NB.  Phrases from Chapter 7, Section C of J Phrases.

m0=: Isodd=: 2&|                NB.Test if y is an odd integer
m1=: Iseven=: -.@Isodd          NB.Test if y is an even integer
m2=: Isperm=: -: /:@/:          NB.Test if y is a permutation vector
a3=: 1 : 'x. -: x.@(?@!@#A.])'  NB.Necessary condition  for symmetry of fn.
m4=: m2*_1:^>/~ ~:/@,@:* </~@i.@#  NB.Classify argument as a permutation
m5=: L=: >/~                    NB.Left, centre, right limbs of the fork
m6=: C=: ~:/@,@:*               NB.evaluated in m4. See their use below
m7=: R=: </~@i.@#               NB.to demonstrate design of its definition
m8=: m2*_1:^+/@(<:@#@>@(C.@~.))  NB.Parity of permutation from cycle lengths
m9=: -/@(|:-:"2],:-)            NB.Classify matrix (skew, neither, sym)
a10=: skn=: .:-                 NB.Skew      part with respect to negate
a11=: syn=: ..-                 NB.Symmetric           "
a12=: skt=: .:|:                NB.Skew      part with respect to transpose
a13=: syt=: ..|:                NB.Symmetric           "
m14=: sinh=: 5&o.               NB.Hyperbolic sine
m15=: cosh=: 6&o.               NB.Hyperbolic cosine
n16=: m=: 3 1 4,2 0 5,:1 4 1    NB.A 3-by-3 matrix
d17=: ip=: +/ . *               NB.Inner (matrix) product
m18=: L=: m&ip                  NB.A linear function
m19=: cst=: m4"1@(#: i.)@:(#~)  NB.Complete skew tensor; m4 tests for perm
d20=: cross1=: [ip cst@#@[ip]   NB.Generalized cross-product
d21=: cross2=: ((_1: |.[)*(1:     |.]))-((1: |.[)*(_1: |. ]))  NB.Conventional cross product (not valid for dimension greater than 3)
m22=: det1=: +/@,@(*// * cst@#)  NB.Determinant in terms of cst
m23=: det2=: -/ . *             NB.Determinant
m25=: arcsin=: _1&o.            NB.Arcsine
m26=: angle=:arcsin@(length@ cross1     % length@[*length@])  NB.Angle between two vectors
m27=: dfr=: 180p_1&*            NB.Degrees from radians
