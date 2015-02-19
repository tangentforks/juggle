NB. various random utilities
NB.
NB. see also system/packages/stats/statdist for distributions
NB.
NB.    setrl n       set random link
NB.
NB.    rand01 n      generate n random numbers in interval (0,1)
NB.    randomize     sets a random value into random link
NB.
NB.    deal p        deal p (no repetition) (i.e. shuffle p)
NB.  m deal p        deal m items from p (no repetition)
NB.  m toss p        pick m items from p (with repetition)

t=. ' deal rand01 randomize setrl toss'
SCRIPTNAMES=. t

setrl=: 9!:1

deal=: (# ? #) : (? #) { ]
toss=: ? @ (# #) { ]
rand01=: (>: @ ? % 2147483647&[) @ $&2147483646

randomize=: 3 : 0
([ 9!:1) >:<.0.8*0 60 60 24 31#.0 0 0 0 _1+|.<.}.6!:0 ''
)