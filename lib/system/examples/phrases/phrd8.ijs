NB.  Phrases from Chapter 8, Section D of J Phrases.

d0=: [: >: #:                   NB.Add 1 to cyclic countr y with upper lim x
d1=: +//.                       NB.Sum items of y corresponding to keys x
d2=: +//. {~ 'abcde'"_ i. ~.@[  NB.Sum y according to keys x from key set 'abcde'. (substitute your ordered keyset for 'abcde')
d3=: +.                         NB.Greatest common divisor of x and y
m4=: >:@i.@(>./) |/ ]           NB.1 thru max y residues of y
m5=: 0: = m4                    NB.Locate positive integers <: y dividing y
d6=: +"1                        NB.Add x to each row of y
d7=: +                          NB.Add list x to each column of table y
d8=: +                          NB.Add list y to each column of table x
d9=: *.                         NB.Least common multiple of x and y
