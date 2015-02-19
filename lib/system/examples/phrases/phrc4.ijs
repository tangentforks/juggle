NB.  Phrases from Chapter 4, Section C of J Phrases.

d0=: -:&(/:~)                   NB.Are x and y permutations of each other?
m1=: /:~-:i.@#                  NB.Is y a permutation vector?
m2=: -:-@|:                     NB.Is y antisymmetric?
m3=: -:|:                       NB.Is y symmetric?
m4=: [:+./[:*./]=/0 1"_         NB.Are all atoms of Boolean list y equal?
m5=: *./ .= +./                 NB.Are all atoms of Boolean list y equal?
m6=: *./ .= *./                 NB.Are all atoms of Boolean list y equal?
d7=: -.@(] <:/ .>: >.@] , [)"1  NB.Is y in the half open on the right interval x and is it an integer?
d8=: e.                         NB.Is list x a row of array y?
m9=: *./@(= >./\)               NB.Are columns of y in ascending order?
m10=: *./@(= <./\)              NB.Are columns of y in descending order?
m11=: >./=<./                   NB.Are atoms of numerical list y equal?
m12=: *./ +. -.@(+./)           NB.Are atoms of Boolean list y equal? 
m13=: *./ = +./                 NB.Are atoms of Boolean list y equal?
m14=: *./@(= {.)                NB.Are atoms of list y equal?
m15=: 0:=#|+/                   NB.Are atoms of Boolean list y equal?
m16=: *./@(#1&|.)               NB.Are atoms of Boolean list y equal?
m17=: ([:,:0:,#)-: v19"_ rxmatch ]  NB.Is y a legal J name?
d18=: rxmatch=: 17!:0           NB. load 'regex' to get rxmatch
v19=: '[[:alpha:]][[:alnum:]_]* '"_  NB.load 'regex' to get alpha: and alnum:
