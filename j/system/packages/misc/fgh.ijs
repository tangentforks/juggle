NB. displays calling sequence for simple J expressions
NB.
NB.   f_       monadic f
NB.   _f_      dyadic f
NB.   _fI_     dyadic inverse of f etc..
NB.
NB. e.g.
NB.   f g h 1
NB.   (f g h) 1
NB.   f&g 1
NB.   f&.g 1
NB.   1 f g 2
NB.   f/1 2 3

bracket=: 3 : 0
if. (1=$,y.=.":y.) do. y. else. '(',y.,')' end.
)

def=. ("_) , bracket :  (((("_) , ]) ,~ [) &bracket)

ff=: 'f_ ' def ' _f_ '
fi=: 'fI_ ' def ' _fI_ '

ff=: f2 :. f3

ff=: 3 : 0
'f_ ',bracket y.
:
(bracket x.),' _f_ ',bracket y.
)

gg=: 3 : 0
'g_ ',bracket y.
:
(bracket x.),' _g_ ',bracket y.
)

hh=: 3 : 0
'h_ ',bracket y.
:
(bracket x.),' _h_ ',bracket y.
)

fi=: 3 : 0
'fI_ ',bracket y.
:
(bracket x.),' _fI_ ',bracket y.
)

gi=: 3 : 0
'gI_ ',bracket y.
:
(bracket x.),' _gI_ ',bracket y.
)

hi=: 3 : 0
'hI_ ',bracket y.
:
(bracket x.),' _hI_ ',bracket y.
)

f=: ff :. fi
g=: gg :. gi
h=: hh :. hi
