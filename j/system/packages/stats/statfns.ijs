NB. Statistical functions
NB.
NB. mean          arithmetic mean
NB. geomean       geometric mean
NB. harmean       harmonic mean
NB.
NB. dev           deviation from mean
NB. ssdev         sum squares of deviation
NB. var           variance
NB. stddev        standard deviation
NB. skewness      skewness
NB. kurtosis      kurtosis
NB.
NB. spdev         sum of products of deviations
NB. cov           covariance
NB. corr          correlation
NB.
NB. min           minimum
NB. max           maximum
NB. midpt         index of midpoint
NB. median        median
NB.
NB. cile          x. cile values of y.
NB. comb          combinations of size x. from i.y
NB. dstat         descriptive statistics
NB. freqcount     frequency count
NB. lsfit         least-squares fit
NB. perm          permutations of size y.
NB. regression    multiple regression

t=. 'cile comb cov corr dev dstat freqcount'
t=. t,' geomean harmean kurtosis lsfit'
t=. t,' max midpt mean median perm'
t=. t,' regression skewness sort spdev ssdev stddev var'
SCRIPTNAMES=. t

mean=:     +/ % #
geomean=:  */ %:~ #
harmean=:  mean &. (%"_)

dev=:      -"_1 _ mean
ssdev=:    +/ @: *: @ dev
var=:      ssdev  % <:@#
stddev=:   %: @ var

NB. skewness = 3rd moment coefficient
skewness=: %:@# * +/@(^&3)@dev % ^&1.5@ssdev

NB. kurtosis = 4th moment coefficient
kurtosis=:  # * +/@(^&4)@dev % *:@ssdev

spdev=:    +/ @ (*~ dev)
cov=:      spdev % <: @ # @ ]
corr=:     cov % *~ & stddev

min=:      <./
max=:      >./
midpt=:    -:@<:@#
median=:   -:@(+/)@((<. , >.)@midpt { /:~)

NB. cile    e.g. 3 cile i.12
cile=: $@] $ ((* <.@:% #@]) /:@/:@,)

NB. comb
NB. all combinations of size x. from i.y.
comb=: 4 : 0
i=.1+x.
z=.1 0$k=.i.#c=.1,~(y.-x.)$0
while. i=.<:i do. z=.(c#k),.;(-c=.+/\.c){.&.><1+z end.
)

NB. descriptive statistics
dstat=: 3 : 0
t=. '/sample size/minimum/maximum/median/mean'
t=. t,'/std devn/skewness/kurtosis'
t=. ,&':  ' ;._1 t
v=. $,min,max,median,mean,stddev,skewness,kurtosis
t,. ": ,. v y.
)

NB. frequency count (value, frequency) sorted by decreasing frequency
freqcount=: (\: {:"1)@(~. ,. #/.~)

NB. lsfit
NB. n lsfit xy
NB. coefficients of polynomial fitting data points
NB. using least squares approximation.
NB. xy = 2 row matrix of x ,: y
NB. n  = order of polynomial
lsfit=: {:@] %. {.@] ^/ i.@>:@[

NB. all permutations of size y.
perm=: 1 0&$`([: ,/ 0&,.@($:&.<:) {"2 1 \:"1@=@i.) @. *

NB. regression
regression=: 4 : 0
NB. syntax:  independent regression dependent
NB.    dependent = vector of n observations (Y value)
NB.  independent = n by p matrix of n observations for p independent
NB                 variables (X value)
NB.
NB. returns formatted values
x=. 1,.x.
y=. y.
b=. y %.x
k=. <:{:$x
n=. $y
sst=. +/*:y-(+/y) % #y
sse=. +/*:y-x +/ .* b
mse=. sse%n->:k
seb=. %:({.mse)*(<0 1)|:%.(|:x) +/ .* x
ssr=. sst-sse
msr=. ssr%k
rsq=. ssr%sst
F=.   msr%mse

r=. ,: '             Var.       Coeff.         S.E.           t'
r=. r, 15.0 15.5 15.5 12.2 ": (i.>:k),.b,.seb,.b%seb
r=. r, ' '
r=. r, '  Source     D.F.        S.S.          M.S.           F'
r=. r, 'Regression', 5.0 15.5 15.5 12.2 ": k, ssr,msr,F
r=. r, 'Error     ', 5.0 15.5 15.5": (n-k+1), sse,mse
r=. r, 'Total     ', 5.0 15.5 ": (n-1), sst
r=. r, ' '
r=. r, 'S.E. of estimate    ', 12.5":%:mse
r=. r, 'Corr. coeff. squared', 12.5": rsq
)
