NB. convert between color triples and RGB values

NB. ============================================================
NB. RGB   - convert between color triples and RGB values
RGB=: 0&$: : (4 : 0)
NB. form:  opt RGB dat
NB.   opt = 0 integers to RGB   (default)
NB.   dat = red, green, blue values or 3-col matrix of same
NB.
NB.   opt = 1 RGB to integers
NB.   dat = one or more RGB values
NB.
NB. RGB format is a 4 byte integer: unused blue green red
NB.
NB. e.g.  RGB 255 255 0   =  RGB value for bright yellow
if. x. do. |."1[ 256 256 256 #: y.
else. y. +/ .* 1 256 65536
end.
)
