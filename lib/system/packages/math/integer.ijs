NB. various integer definitions
NB.
NB. inta    augmented integers     inta 4   is   1 2 3 4
NB. inte    extended integers      inte 4   is   0 1 2 3 4
NB. ints    symmetric integers     ints 4   is   _4 _3 _2 _1 0 1 2 3 4
NB. intm    minus integers         intm _4  is   _1 _2 _3 _4
NB. intn    normal integers        intn _4  is   0 _1 _2 _3
NB. intr    reflexive integers     intr 4   is   3 2 1 0 1 2 3
NB.
NB. Examples:
NB.
NB.    inta each _5 0 5
NB. +---------++---------+
NB. |5 4 3 2 1||1 2 3 4 5|
NB. +---------++---------+
NB.
NB.    inte each _5 0 5
NB. +-----------+-+-----------+
NB. |5 4 3 2 1 0|0|0 1 2 3 4 5|
NB. +-----------+-+-----------+
NB.
NB.    ints each _5 0 5
NB. +--------------------------+-+--------------------------+
NB. |5 4 3 2 1 0 _1 _2 _3 _4 _5|0|_5 _4 _3 _2 _1 0 1 2 3 4 5|
NB. +--------------------------+-+--------------------------+
NB.
NB.    intm each _5 0 5
NB. +--------------++---------+
NB. |_1 _2 _3 _4 _5||0 1 2 3 4|
NB. +--------------++---------+
NB.
NB.    intn each _5 0 5
NB. +-------------++---------+
NB. |0 _1 _2 _3 _4||0 1 2 3 4|
NB. +-------------++---------+
NB.
NB.    intr each _5 0 5
NB. +-----------------++-----------------+
NB. |0 1 2 3 4 3 2 1 0||4 3 2 1 0 1 2 3 4|
NB. +-----------------++-----------------+

inta=: >:@i.
inte=: i.@(+ (* + 0&=))
ints=: i.@(+: + * + 0&=) - |
intm=: i. + (* 0&>)
intn=: * * i.@|
intr=: (|.@}. , ])@i.
