NB. date and time utilities
NB.
NB.   calendar        calendar for year [months]
NB.   getdate         get date from character string
NB.   todate          convert to date
NB.   todayno         convert to day number
NB.   tsdiff          differences between dates
NB.   tsrep           timestamp as a single number
NB.   tstamp          formatted timestamp
NB.   valdate         validate dates
NB.   weekday         weekday from date

NB.*calendar v calendar for year [months]
NB. returns calendar for year, as a 12 element list
NB.
NB. argument is one or more numbers: year, months
NB. If no months are given, it defaults to all months.
NB.
NB. example:
NB.    calendar 1998 5 6
NB. +---------------------+---------------------+
NB. |         May         |         Jun         |
NB. | Su Mo Tu We Th Fr Sa| Su Mo Tu We Th Fr Sa|
NB. |                 1  2|     1  2  3  4  5  6|
NB. |  3  4  5  6  7  8  9|  7  8  9 10 11 12 13|
NB. | 10 11 12 13 14 15 16| 14 15 16 17 18 19 20|
NB. | 17 18 19 20 21 22 23| 21 22 23 24 25 26 27|
NB. | 24 25 26 27 28 29 30| 28 29 30            |
NB. | 31                  |                     |
NB. +---------------------+---------------------+

calendar=: 3 : 0
y=. ((j<100)*(-100&|){.6!:0'')+j=. {.y.
b=. y+-/<.4 100 400%~<:y
r=. 28+3,(~:/0=4 100 400|y),10$5$3 2
r=. ,(-7|b+0,+/\}:r)|."0 1 r(]&:>:*"1>/)i.42
m=. m,(0=#m=. <:}.y.)#i.12
h=. 'JanFebMarAprMayJunJulAugSepOctNovDec'
h=. ' Su Mo Tu We Th Fr Sa',:"1~_3(_12&{.)\h
<"2 m{h,"2[12 6 21$,>(<'') ((r=0)#i.#r)} <"1 [ 3":,.r
)

NB.*getdate v get date from character string
NB. form: [opt] getdate string
NB.
NB. useful for input forms that have a date entry field
NB.
NB. date forms permitted:
NB.     1986 5 23
NB.     May 23 1986
NB.     23 May 1986
NB. and:
NB.   opt=0  (days first - default)
NB.     23 5 1986
NB.   opt=1  (months first)
NB.     5 23 1986
NB.
NB. other characters allowed:  ,-/:
NB.
NB. if not given, century defaults to current
NB.
NB. only first 3 characters of month are tested.
NB.
NB. examples:  23/5/86; may 23, 1986; 1986-5-23
NB.
NB. requires: valdate

getdate=: 3 : 0
0 getdate y.
:
r=. ''

chr=. [: -. [: *./  e.&'0123456789 '
dat=. ' ' (bx y.e.',-/:') } y.

if. chr dat do.
  x.=. 0
  dat=. a: -.~ <;._1 ' ',dat
  if. 1=#dat do. r return. end.
  typ=. chr &> dat
  dat=. (2{.typ{dat),{:dat
  mth=. 3{.>1{dat
  uc=. 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  lc=. 'abcdefghijklmnopqrstuvwxyz'
  mth=. (lc,a.) {~ mth i.~ uc,a.
  mos=. _3[\'janfebmaraprmayjunjulaugsepoctnovdec'
  mth=. <": >:mos i. mth
  dat=. ;' ',each mth 1 } dat
end.

dat=. ". :: (''"_) dat
if. 0 e. #dat do. return. end.

if. 3 ~: #dat do. r return. end.

if. 31 < {.dat do. 'y m d'=. dat
else. ((x.|.'d m '),' y')=. dat
end.

if. y<100 do.
  y=. y + (-100&|) {. 6!:0''
end.

(#~ valdate) y,m,d
)

NB.*todate v converts day numbers to dates
NB. converts day numbers to dates, converse <todayno>
NB.
NB. This conversion is exact and provides a means of
NB. performing exact date arithmetic.
NB.
NB. y. = day numbers
NB. x. = optional:
NB.   0 - result in form <yyyy mm dd> (default)
NB.   1 - result in form <yyyymmdd>
NB.
NB. example:
NB.    todate 72460
NB. 1998 5 23
NB.
NB.    todate 0 1 2 3 + todayno 1992 2 27
NB. 1992 2 27
NB. 1992 2 28
NB. 1992 2 29
NB. 1992 3  1

todate=: 3 : 0
0 todate y.
:
s=. $y.
y.=. 657377.75 +, y.
d=. <. y. - 36524.25 * c=. <. y. % 36524.25
d=. <.1.75 + d - 365.25 * y=. <. (d+0.75) % 365.25
r=. (1+12|m+2) ,: <. 0.41+d-30.6* m=. <. (d-0.59) % 30.6
r=. s $ |: ((c*100)+y+m >: 10) ,r
if. x. do. r=. 100 #. r end.
r
)

NB.*todayno v converts dates to day numbers
NB. converts dates to day numbers, converse <todate>
NB.
NB. y. = dates
NB. x. = optional:
NB.   0 - dates in form <yyyy mm dd> (default)
NB.   1 - dates in form <yyyymmdd>
NB. 0 = todayno 1800 1 1, or earlier
NB.
NB. example:
NB.    todayno 1998 5 23
NB. 72460

todayno=: 3 : 0
0 todayno y.
:
if. x. do. y.=. 0 100 100 #: y. end.
y.=. ((*/r=. }: $y.) , {:$y.) $,y.
'y m d'=. <"_1 |: y.
y=. 0 100 #: y - m <: 2
n=. +/ |: <. 36524.25 365.25 *"1 y
n=. n + <. 0.41 + 0 30.6 #. (12 | m-3),"0 d
0 >. r $ n - 657378
)

NB.*tsdiff v differences between pairs of dates.
NB.
NB. form:  end tsdiff begin
NB.   end, begin are vectors or matrices in form YYYY MM DD
NB.   end dates should be later than begin dates
NB.
NB. method is to subtract dates on a calendar basis to determine
NB. integral number of months plus the exact number of days remaining.
NB. This is converted to payment periods, where # days remaining are
NB. calculated as: (# days)%365
NB.
NB. example:
NB.    1994 10 1 tsdiff 1986 5 23
NB. 8.35799

tsdiff=: 4 : 0
r=. -/"2 d=. _6 (_3&([\)) \ ,x.,"1 y.
if. #i=. i#i.#i=. 0 > 2{"1 r do.
  j=. (-/0=4 100 400 |/ (<i;1;0){d)* 2=m=. (<i;1;1){d
  j=. _1,.j + m{0 31 28 31 30 31 30 31 31 30 31 30 31
  n=. <i;1 2
  r=. (j + n{r) n } r
end.
r +/ . % 1 12 365
)

NB.*tsrep v timestamp representation as a single number
NB.
NB. form: [opt] timerep times
NB.   opt=0  convert timestamps to numbers (default)
NB.       1  convert numbers to timestamps
NB.
NB. timestamps are in 6!:0 format, or matrix of same.
NB.
NB. examples:
NB.    tsrep 1800 1 1 0 0 0
NB. 0
NB.    ":!.13 tsrep 1995 5 23 10 24 57.24
NB. 6165887097240
tsrep=: 3 : 0
0 tsrep y.
:
if. x. do.
  r=. $y.
  'y n t'=. |: 0 86400 1000 #: ,y.
  y=. y + 657377.75
  d=. <. y - 36524.25 * c=. <. y % 36524.25
  d=. <.1.75 + d - 365.25 * y=. <. (d+0.75) % 365.25
  s=. (1+12|m+2) ,: <. 0.41+d-30.6* m=. <. (d-0.59) % 30.6
  s=. |: ((c*100)+y+m >: 10) ,s
  r $ s,. (_3{. &> t%1000) +"1 [ 0 60 60 #: n
else.
  y.=. ((*/r=. }: $y.) , {:$y.) $, y.
  'y m d'=. <"_1 |: 3{."1 y.
  y=. 0 100 #: y - m <: 2
  n=. +/ |: <. 36524.25 365.25 *"1 y
  n=. n + <. 0.41 + 0 30.6 #. (12 | m-3),"0 d
  s=. 3600000 60000 1000 +/ .*"1 [ 3}."1 y.
  r $ s+86400000 * n - 657378
end.
)

NB.*tstamp v format time stamp as:  23 May 1998 16:06:39
NB. y. is time stamp, if empty default to current time
tstamp=: 3 : 0
y=. <.y.,(0=#y.)#6!:0 ''
'y m d h n s'=. 6{.y
mth=. _3[\'   JanFebMarAprMayJunJulAugSepOctNovDec'
f=. _2: {. '0'&,@":
t=. (2":d),(m{mth),(":y),;f&.>h,n,s
r=. 'xx xxx xxxx xx:xx:xx'
t (bx r='x') } r
)

NB.*valdate v validate dates
NB. form: valdate dates
NB. dates is 3-element vector
NB.       or 3-column matrix
NB.       in form YYYY MM DD
NB. returns 1 if valid
valdate=: 3 : 0
s=. }:$y.
'y m d'=. t=. |:((*/s),3)$,y.
b=. *./(t=<.t),(_1 0 0<t),12>:m
day=. (13|m){0 31 28 31 30 31 30 31 31 30 31 30 31
day=. day+(m=2)*-/0=4 100 400|/y
s$b*d<:day
)

NB.*weekday v returns weekday from date, 0=Sunday ... 6=Saturday
NB. arguments as for <todayno>, e.g.
NB.
NB.     5 = weekday 1997 5 23 = 1 weekday 19970523
weekday=: 7: | 3: + todayno