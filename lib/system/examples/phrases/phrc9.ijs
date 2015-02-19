NB.  Phrases from Chapter 9, Section C of J Phrases.

d0=: sum=: +/@,:                NB.Polynomial sum. Try 1 2 sum 1 3 3 1 
d1=: dif=: -/@,:                NB.        "       difference
d2=: ppr=: +//.@(*/)            NB.         "       product
m3=: pdi=: 1: }. ] * i.@#       NB.        "       derivative
d4=: pin=: , ] % >:@i.@#        NB.       "       integral (left arg gives constant)
m5=: piz=: 0&pin                NB.       "       integral 0 constant of integration
m6=: atop=: [ +/ .* 1 0"_    ,ppr/\@(<:@#@[# ,:@])  NB.Composition: (c atop d)&p. is equivalent to (c&p.) @ (d&p.)
m7=: i.@>: ! ]                  NB.Binomial coefficients
m8=: !/~@i.                     NB.Binomial coefficients table
m9=: expand=: m8@# +/ . * ]     NB.Expand coefficients
m10=: !/~@i.@#                  NB.Binomial coefficients
m11=: |:@m8                     NB.Pascal’s triangle
m12=: %.@m8                     NB.Alternating binomial coefficients table
m13=: contract=: m12@# +/ .*]   NB.Inverse of expand (gives c p. x-1) 
m14=: p.                        NB.Transformation between roots and coefficients 
d15=: p.                        NB.Polynomial in terms of roots or coefficients
c16=: FIT=: 2 :'x. %.     ]^/(i.y.)"_'  NB.f FIT d gives coeffs of pn fit of degree d-1
d17=: ff=: ^!._1                NB.Falling factorial (_1-stope)
d18=: fp=: p.!._1 " 1 0         NB.Falling factorial polynomial
a19=: VM=: ((/ ~)(@i.))(@#)     NB.Vandermonde adverb 
m20=: fcFc=:]+/ .*~^VM%.ff VM   NB.Falling coeffs From ordinary coeffs
m21=: cFfc=: fcFc^:_1           NB.Ordinary coeffs From falling coeffs
d22=: taut=: p. -: fcFc@[ fp ]  NB.Tautology
d23=: rf=: ^!.1                 NB.Rising factorial
a24=: S=: 1 : '^!.x.'           NB.Stope adverb (1 S is rf Try 0.1 S) 
d25=: mtn=:{.@[+/ .*]*/ .^}.@[  NB.Multinomial e.g. (c,E) mtn x,y,z
c26=: R=: [. & p. % (]. & p.)   NB.Rational conjunction
c27=: TR=: ([.&p.%(].&p.)) t.   NB.Taylor series of rational function
d28=: dp=: (|.@[ p. ])"1 1 0    NB.Polynomial in descending powers
d29=: dsum=: sum&.|.            NB.Polynomial sum in descending powers
d30=: ddif=: dif&.|.            NB.Polynomial difference in descending powers
d31=: dppr=: ppr                NB.Polynomial product in descending powers
m32=: dpdi=: pdi&.|.            NB.Polynomial derivative in descending powers
m33=: a=:{. [. b=:1&{ [. c=:{:  NB.Coefficients a, b, and c of quadratic 
m34=: dsc=: (b*b) - 4:*a*c      NB.Discriminant of quadratic
m35=: r=:(-@b(+,-)%:@dsc)%+:@a  NB.Roots of quadratic
d36=: m35@(1: , ,)              NB.b d36 c gives roots of  1,b,c
m37=: ] d36"0 i.@>.@(*: % 4:)   NB.Arguments limited to real results
