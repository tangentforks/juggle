NB. debug definitions and utilities
NB.
NB. e.g.  dbss 'f 0'   monadic line 0
NB.       dbss 'f :2'  dyadic line 2
NB.       dbss 'f *:*' all lines
NB.
NB. The call stack (dbstk'') is an 8-column boxed matrix:
NB.   0  name
NB.   1  error number, or 0 if this call is not erroneous
NB.   2  line number
NB.   3  name class
NB.   4  definition
NB.   5  source script
NB.   6  argument list
NB.   7  locals

NB.*dbr vreset, set suspension mode (0=disable, 1=enable)
NB.*dbs v display stack
NB.*dbsq v stop query
NB.*dbss v stop set
NB.*dbrun v run again (from current stop)
NB.*dbnxt v run next (skip line and run)
NB.*dbret v exit and return argument
NB.*dbjmp v jump to line number
NB.*dbsig v signal error
NB.*dbrr v re-run with specified arguments
NB.*dbrrx v re-run with specified executed arguments
NB.*dberr v last error number
NB.*dberm v last error message
NB.*dbstk v call stack
NB.*dblxq v latent expression query
NB.*dblxs v latent expression set
NB.*dbtrace v trace control
NB.*dbq v queries suspension mode (set by dbr)

dbr=:       13!:0
dbs=:       13!:1
dbsq=:      13!:2
dbss=:      13!:3
dbrun=:     13!:4
dbnxt=:     13!:5
dbret=:     13!:6
dbjmp=:     13!:7
dbsig=:     13!:8
dbrr=:      13!:9
dbrrx=:     13!:10
dberr=:     13!:11
dberm=:     13!:12
dbstk=:     13!:13
dblxq=:     13!:14
dblxs=:     13!:15
dbtrace=:   13!:16
dbq=:       13!:17

NB.*dbstack v displays call stack with header
NB. if  x.=0  ignores definition and source script (default)
NB.        1  displays full stack
NB. y. is the number of lines to display, all if empty
NB. limits display of each item to length 30.
dbstack=: 3 : 0
0 1 dbstack y.
:
'x n'=. 2{.x.
hdr=. ;:'name en ln nc def script args locals'
stk=. (>:n)}.13!:13''
if. #y. do. stk=. (,y.){.stk end.
stk=. hdr,stk
stk=. stk #~"1 (0~:x) >. 1 1 1 1 0 0 1 1
tc=. 31&<.@$ {.!.'.' ({.~ 30&<.@$)
tc@": &.>stk
)