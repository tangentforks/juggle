NB. Statistical Distributions
NB.
NB. betarand         - random numbers in a beta distribution
NB.
NB. binomialdist     - discrete values for binomial distribution
NB. binomialprob     - probability of success in binomial distribution
NB. binomialrand     - random numbers 0 and 1 in binomial distribution
NB.
NB. cauchyrand       - random numbers in a cauchy distribution
NB.
NB. discreterand     - random numbers in a discrete distribution
NB.
NB. exponentialrand  - random numbers in an exponential distribution
NB.
NB. gammarand        - random numbers in a gamma distribution
NB.
NB. normalprob       - probability of success in normal distribution
NB. normalrand       - random numbers in a standard normal distribution,
NB.
NB. poissondist      - discrete values for poisson distribution
NB. poissonprob      - probability of success in poisson distribution
NB. poissonrand      - random numbers in a poisson distribution

t=. 'betarand binomialdist binomialprob binomialrand'
t=. t,' cauchyrand discreterand exponentialrand'
t=. t,' gammarand normalprob normalrand'
t=. t,' poissondist poissonprob poissonrand'
SCRIPTNAMES=. t

NB. betarand
NB. random numbers in a beta distribution
NB. y. has 3 elements p,q,n
NB.   0 = power parameter
NB.   1 = power parameter
NB.   2 = number of trials
betarand=: 3 : 0
'p q n'=. y.
if. (1>p) *. 1>q do.
  b=. n#1
  r=. n#0
  whilst. 1 e. b do.
    m=. +/b
    x=. (rand01 m)^%p
    y=. x+(rand01 m)^%q
    t=. 1>:y
    z=. (t#x)%t#y
    i=. t#b#i.#b
    b=. 0 i } b
    r=. (z+i{r) i } r
 end.
else.
s%(gammarand q,n)+s=. gammarand p,n
end.
)

binomialdist=: 3 : 0
NB. binomial distribution
NB. y. has 2 elements p,n:
NB.  0  =  probability of success in one trial
NB.  1  =  number of trials
NB.
NB. E=n*p, var=n*p*-.p
NB.
NB. e.g.  binomialdist 0.25 5  ...distribution of results from 0 to 5
'p n'=. y.
if. b=. p<:0.5 do. p=. -. p end.
q=. -.p
r=. }.i.>:n
r=. (q^n)**/\1,(p%q)*(>:n-r)%r
if. b do. |. r end.
)

binomialprob=: 3 : 0
NB. probability of successes in binomial distribution
NB. y. has 3 or 4 elements:
NB.   0  =  probability of success in one trial
NB.   1  =  number of trials
NB.   2  =  minimum number of successes
NB.  {3} =  maximum number of successes
NB.
NB. e.g.  binomialprob 0.25 100 30 40    ...probability that there are
NB. between 30 and 40 successes in 100 trials, where probability = 0.25
'p n s'=. 3{.y.
m=. >:3{y.,n
+/ s}.m{.binomialdist p,n
)

binomialrand=: 3 : 0
NB. random numbers 0 and 1 in a binomial distribution
NB.
NB. y. has 2 elements:
NB.  0  =  probability of success in one trial
NB.  1  =  number of trials
NB.
'p n'=. y.
r=. 2147483647
s=. <:p*r
s>?n#<:r
)

cauchyrand=: 3 : 0
NB. random numbers in a cauchy distribution
NB. with F(x)=0.5+(arctan x)%o.1
NB.
NB. y.  =  number of trials
3 o. o. _0.5+rand01 y.
)

discreterand=: 3 : 0
NB. random numbers in a discrete distribution
NB.
NB. y. has two elements
NB.   0 =  2-row matrix: 0 =  discrete values
NB.                      1 =  corresponding probabilities
NB.   1 =  number of trials
'm n'=. y.
'v p'=. m
f=. 0,+/\p%+/p
l=. #f
r=. /:f,rand01 n
s=. +/\l>r
r=. s r } r
v {~ <:l}.r
)

exponentialrand=: 3 : 0
NB. random numbers in an exponential distribution
NB. with mean=1. F(x)=1-^-x
NB.
NB. y.  =  number of trials
-^.rand01 y.
)

NB. gammarand
NB. random numbers in a gamma distribution
NB. y. has 2 elements p,n
NB.   0 = power parameter
NB.   1 = number of trials
NB.
NB. if p=1 this is the exponential distribution
gammarand=: 3 : 0
'p n'=. y.
r=. n#0
k=. p-i=. <.p
if. k do.
  r=. betarand k,(-.k),n
  r=. r * -^.rand01 n
end.
if. i do.
  r-^.*/rand01 i,n
end.
)

normalprob=: 3 : 0
NB. probabilities of normal distribution
NB.
NB. y. has 3 or 4 elements:
NB.   0  =  mean of distribution
NB.   1  =  standard deviation
NB.   2  =  minimum result
NB.  {3} =  maximum result
NB.
NB. e.g.  normalprob 0 1 2    ...probability that result will be
NB. greater than 2, where mean = 0, standard deviation 1
NB.
NB. Result is rounded to 7 decimal places
NB. Algorithm has accuracy ~ 7.5*1e_8
'm s'=. 2{.y.
x=. s %~ m -~ 2}.y.
sgn=. *x
x=. |x
b=. 0.31938153 _0.356563782 1.781477937 _1.821255978 1.330274429
p=. 0.2316419
r=. ((2p1)^_0.5)*^_0.5**:x
r=. r*b+/ .**/\5#(1,#x)$%>:p*x
r=. -/|(sgn=_1)-r
(<.0.5+r*c)%c=. 1e7
)

normalrand=: 3 : 0
NB. random numbers in a standard normal distribution,
NB. with  mean=0, standard deviation=1.
NB. y.  = number of trials.
NB. Polar method.
r=. i.0
while. y. ~: #r do.
  j=. >.0.65*y.-#r
  t=. (2,j)$<:+: rand01 +:j
  b=. 1>s=. +/*:t
  s=. 0.5^~(_2*^.s)%s=. b#s
  r=. r,,(b#"1 t)*(2,#s)$s
  r=. (y.<.#r){.r
end.
)

poissondist=: 3 : 0
NB. discrete values for poisson distribution
NB.
NB. y. has 2 elements:
NB.   0 = mean of distribution
NB.   1 = maximum value to show
NB.
NB. e.g.  poissondist 2 10
NB.       = list of probabilities of values from 0 to 10
NB.         in poisson distribution of mean 2
'm n'=. y.
(^-m)**/\1,m%}.i.>:n
)

poissonprob=: 3 : 0
NB. probability of successes in poisson distribution
NB.
NB. y. has 2 or 3 elements:
NB.  0   =  mean of distribution
NB.  1   =  minimum number of successes
NB.  {2} =  maximum number of successes
NB.
NB. e.g.
NB.   poissonprob 5 4 7    ...probability that result will be
NB.         between 4 and 7 inclusive, where mean result is 5.
NB.   poissonprob 5 6 6    ...probability that result will be
NB.         exactly 6, where mean result is 5.
m=. {.y.
s=. }.y.
b=. 1=#s
'x y'=. _2{.0,s-b
if. 0>y do. 1 return. end.
|b-(^-m)*+/x}.*/\1,m%}.i.>:y
)

poissonrand=: 3 : 0
NB. random numbers in a poisson distribution
NB.
NB. y. has 2 elements:
NB.   0  = mean of distribution (=variance)
NB.   1  = number of trials
'm n'=. y.
roll=. -@^.@rand01
r=. b=. m >: t=. roll n
i=. i.n
while. #i=. b#i do.
  b=. m >: t=. (b#t) + roll #i
  r=. (b + i{r) i } r
end.
r
)
