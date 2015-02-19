NB. example scripts for user definitions

NB.*brep v boxed representation
NB.*tree v tree representation
NB.*lrep v linear representation
NB.*prep v parenthesized representation
NB.*snap v names snapshot
NB.*time v time
NB.*pps v set print precision

brep=:   5!:2@boxopen
tree=:   5!:4@boxopen
lrep=:   5!:5@boxopen
prep=:   5!:6@boxopen
snap=:   4!:5
time=:   6!:0
pps=:    9!:11

NB.*timex v time expressions
timex=:  3 : ('1 timex y.';':';';x. 6!:2&.> boxopen y.')

NB.*tolist v convert boxed list to LF delimited list
tolist=: }. @ ; @: (LF&, @ , @ ": each)
