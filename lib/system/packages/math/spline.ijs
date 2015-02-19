NB. calculate cubic spline

NB. =========================================================
NB. cubicspline        - calculate cubic spline
NB. y. is a 2-row matrix x ,: f(x)
NB. result is x values;coefficient matrix,one row per interval.
cubicspline=: 3 : 0
diff=. }.-}:
'x y'=. y.
h=. diff x
k=. diff y
w=. 3 * diff k % *: h
n=. +:(2}.x)-_2}.x
sm=. ,~_2+#x
m=. sm$}.,(sm+0 1){.(}:h),.n,.}.h
c=. 0,w %. m
a=. }:y
b=. (k%h) - h * ((+:c) + }.c,0) % 3
d=. (diff c,0) % 3 * h
(}:x);a,.b,.c,.d
)

NB. =========================================================
NB. interspline        - interpolate spline
NB. x. is a result from cubicspline
NB. y. is a set of x coordinates
NB. returns corresponding f(x) values
interspline=: 4 : 0
'i m'=. x.
n=. <: +/ i <:/ y.
(n{m) p. y.-n{i
)

NB. examples:
NB. H=: 1 2 4 5 8 10 ,: 2 1.5 1.25 1.2 1.125 1.1
NB. H=: (i.6) ,: (i.6)^3
NB. H, (cubicspline H) interspline {.H
