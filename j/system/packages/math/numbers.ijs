NB. various number definitions
NB.
NB.  bell              Bell numbers
NB.  bernouilli        Bernouilli numbers
NB.  catalan           Catalan numbers
NB.  cycle             Stirling cycle numbers
NB.  cycles            Stirling cycle number table
NB.  euler             Euler numbers
NB.  eulers            Euler numbers table
NB.  fibonacci         Fibonacci numbers
NB.  lucas             Lucas numbers
NB.  subset            Stirling subset numbers
NB.  subsets           Stirling subset number table
NB.  tangent           tangent numbers

NB. =========================================================
bell=: 3 : 0
NB. Number of ways of partitioning y. things into subsets.
step=. (+/\) @ (,~ {:)
{. step ^: y. 1x
)

NB. =========================================================
bernouilli=: 3 : 0
NB. Bernouilli numbers from 0 to y.
NB. y. is a non-negative integer
t=. 1,}.}:tangent y.
b=. _1,t*n*%(* <:)2^n=. >:i.#t
b*(#b)$_1 _1 1 1
)

NB. =========================================================
catalan=: (! +:) % >:

NB. =========================================================
cycles=: 3 : 0
NB. table of Stirling cycle numbers (S1)
NB. y. is a non-negative integer
if. y.=0 do. 1 1$1 return. end.
c,(0,~t*<:y.) + 0,t=. {:c=. cycles <:y.
)

NB. =========================================================
cycle=: 3 : 0
NB. k cycle n  =  [n/k]
NB.   =  number of ways of partitioning n items into k cycles
(i.>:>./y.) cycle y.
:
|:({y.;x.){ cycles >./y.
)

NB. =========================================================
eulers=: 3 : 0
NB. table of Eulerian numbers
NB. y. is a non-negative integer
if. y.=0 do. 1 1$1 return. end.
s,(0,~t*i) + 0,(y.-i=. >:i.y.)*t=. {:s=. eulers <:y.
)

NB. =========================================================
euler=: 3 : 0
NB. k euler n  =  <n/k>
NB.   =  number of permutations of size n with k ascents
(i.>:>./y.) euler y.
:
|:({y.;x.){ eulers >./y.
)

NB. =========================================================
NB. table of first y.+1 Fibonacci + Lucas numbers
NB. e.g. try
NB.   (i.@>: ,. fibonacci ,. lucas) 40
NB.   (fibonacci@+: =&{: fibonacci*lucas) 40

fibonacci=: 3 : 'if. y. do. (, +/@(_2&{.)) ^: (<:y.) 0 1x else. 0 end.'
lucas=: 3 : 'if. y. do. (, +/@(_2&{.)) ^: (<:y.) 2 1x else. 2 end.'

NB. following uses the Binet formula for first n numbers,
NB. but does not use extended precision (good to about fib 60)
NB. fib=: 3 : 0
NB. y=. i.y.
NB. s=. 5^0.5
NB. r=. ((1+s)^y)-(1-s)^y
NB. r=. (}:r)+0.5*}.r
NB. 1,r%s*2^}:y
NB. )

NB. =========================================================
subsets=: 3 : 0
NB. table of Stirling subset numbers (S2)
NB. y. is a non-negative integer
if. y.=0 do. 1 1$1 return. end.
s,(0,~t*i.y.) + 0,t=. {:s=. subsets <:y.
)

NB. =========================================================
subset=: 3 : 0
NB. k subset n  =  {n/k}
NB.   =  number of ways of partitioning n items into k sets
(i.>:>./y.) subset y.
:
|:({y.;x.){ subsets >./y.
)

NB. =========================================================
tangent=: 3 : 0
NB. tangent numbers from 0 to y.
NB. y. is a non-negative integer
NB. Tn+1(x)=(1+x^2)Tn'(x)
f=. [: +//. 1 0 1"_ */ [: }. [ * i.@#
{."1 f^:(i.>:y.) 0 1
)
