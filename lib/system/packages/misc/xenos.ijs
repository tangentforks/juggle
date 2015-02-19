NB. suggested names for external conjunctions
NB.
NB. Names given here are referenced in J system libraries stdlib.ijs
NB. and winlib.ijs only if they are also defined there.
NB.
NB. Debug/Data Driver/DLL/socket names are also in files:
NB. debug.ijs/dd.ijs/dll.ijs/socket.ijs
NB.
NB. For file access, the definitions in files.ijs are recommended.
NB.
NB. Names are not given for conjunctions specific to Mac or PC DOS, or
NB. for conjunctions 128!:x
NB.
NB. Note: this file is not required in the system, and is for 
NB. convenience only.

script=:          0!:0      NB. script
scriptd=:         0!:0      NB. display script
scriptx=:         0!:100    NB. execute noun as script
scriptnx=:        0!:100    NB. execute noun as noisy script

fdir=:            1!:0      NB. file directory
fread=:           1!:1      NB. file read
fwrite=:          1!:2      NB. file write
fappend=:         1!:3      NB. file append
fsize=:           1!:4      NB. file size
fcd=:             1!:5      NB. create directory
fattr=:           1!:6      NB. query/set attributes
fperm=:           1!:7      NB. query/set permissions
freadx=:          1!:11     NB. indexed file read
fwritex=:         1!:12     NB. indexed file write
fnms=:            1!:20     NB. open file numbers/names
fopen=:           1!:21     NB. file open
fclose=:          1!:22     NB. file close
flocks=:          1!:30     NB. file locks
flock=:           1!:31     NB. lock file
funlock=:         1!:32     NB. unlock file
ferase=:          1!:55     NB. erase file

host=:            2!:0      NB. host
hosts=:           2!:1      NB. host spawn
getenv            2!:5      NB. get environment
off=:             2!:55     NB. exit from J

ntype=:           3!:0      NB. noun storage type
nrep=:            3!:1      NB. noun internal representation
nrepx=:           3!:2      NB. convert from internal representation
ic=:              3!:4      NB. convert integer/character
fc=:              3!:5      NB. convert float/character

nameclass=:       4!:0      NB. name class
namelist=:        4!:1      NB. name list
scriptlist=:      4!:3      NB. loaded script list
scriptindex=:     4!:4      NB. index into script list
nameset=:         4!:5      NB. names set 1=start counting, 0=stop
erase=:           4!:55     NB. erase

fixrep=:          5!:0      NB. fix from 5!:1 representation
atomic=:          5!:1      NB. atomic representation
display=:         5!:2      NB. display representation
tree=:            5!:4      NB. tree representation
linear=:          5!:5      NB. linear representation
paren=:           5!:6      NB. parenthesized representation

time=:            6!:0      NB. time
timess=:          6!:1      NB. time since session start
timex=:           6!:2      NB. time expression
timedl=:          6!:3      NB. time delay

space=:           7!:0      NB. space in use
spaces=:          7!:1      NB. space used since session start
spacex=:          7!:2      NB. space used to execute expression
memq=:            7!:3      NB. memory manager query
memrel=:          7!:4      NB. memory manager release

rlq=:             9!:0      NB. query random link
rls=:             9!:1      NB. set random link
promptq=:         9!:4      NB. query input prompt
prompts=:         9!:5      NB. set input prompt
boxdrawq=:        9!:6      NB. query box drawing characters
boxdraws=:        9!:7      NB. set box drawing characters
errormsgq=:       9!:8      NB. query error messages
errormsgs=:       9!:9      NB. set error messages
ppq=:             9!:10     NB. query print precision
pps=:             9!:11     NB. set print precision
sysq=:            9!:12     NB. query system
verq=:            9!:14     NB. query version
psq=:             9!:15     NB. query positioning and spacing
pss=:             9!:16     NB. set positioning and spacing
ctq=:             9!:18     NB. query comparison tolerance
cts=:             9!:20     NB. set comparison tolerance

wd=:              11!:0     NB. windows driver

dbr=:             13!:0     NB. reset, set suspension mode
dbs=:             13!:1     NB. display stack
dbsq=:            13!:2     NB. stop query
dbss=:            13!:3     NB. stop set
dbrun=:           13!:4     NB. run again
dbnxt=:           13!:5     NB. run next
dbret=:           13!:6     NB. exit and return argument
dbjmp=:           13!:7     NB. jump to line number
dbsig=:           13!:8     NB. signal error
dberr=:           13!:11    NB. last error number
dberm=:           13!:12    NB. last error message
dbstk=:           13!:13    NB. call stack
dblxq=:           13!:14    NB. latent expression query
dblxs=:           13!:15    NB. latent expression set
dbtrace=:         13!:16    NB. trace control
dbq=:             13!:17    NB. queries suspension mode (set by dbr)

ddcon=:           14!:0     NB. connect
dddis=:           14!:1     NB. disconnect
ddsql=:           14!:2     NB. SQL
ddfet=:           14!:3     NB. fetch
ddcol=:           14!:4     NB. columns
ddcnm=:           14!:5     NB. columns selected
ddsrc=:           14!:6     NB. data source names
ddsel=:           14!:7     NB. selection
ddend=:           14!:8     NB. end sql statement
dderr=:           14!:9     NB. error info
ddtrn=:           14!:10    NB. begin transaction
ddcom=:           14!:11    NB. commit transaction
ddrbk=:           14!:12    NB. rollback transaction
ddtbl=:           14!:13    NB. tables
ddfch=:           14!:14    NB. fetch in columns
ddcnt=:           14!:15    NB. rowcount of last ddsql

cd=:              15!:0     NB. call DLL procedure
memr=:            15!:1     NB. memory read
memw=:            15!:2     NB. memory write
mema=:            15!:3     NB. memory allocate
memf=:            15!:4     NB. memory free

sdsocket=:        16!:0     NB. create socket
sdrecv=:          16!:1     NB. receive data from socket
sdsend=:          16!:2     NB. send data to socket
sdrecvfrom=:      16!:3     NB. as sdrecv, used with SOCK_DGRAM socket
sdsendto=:        16!:4     NB. as sdsent, used with SOCK_DGRAM socket
sdclose=:         16!:5     NB. close socket
sdconnect=:       16!:6     NB. connect to socket
sdbind=:          16!:7     NB. bind socket to address
sdlisten=:        16!:8     NB. set socket to listen for connections
sdaccept=:        16!:9     NB. clones listening socket for new channel
sdselect=:        16!:10    NB. check socket status
sdgetsockopt=:    16!:11    NB. get value of socket option
sdsetsockopt=:    16!:12    NB. set value of socket option
sdioctl=:         16!:13    NB. read/write socket control information
sdgethostname=:   16!:14    NB. returns host name
sdgetpeername=:   16!:15    NB. returns address this socket is connected to
sdgetsockname=:   16!:16    NB. returns address of this socket
sdgethostbyname=: 16!:17    NB. returns address from name
sdgethostbyaddr=: 16!:18    NB. returns name from address
sdgetsockets=:    16!:19    NB. returns result code and all socket numbers
sdasync=:         16!:20    NB. make socket non-blocking
sdcleanup=:       16!:21    NB. close all sockets

rxmatch=:         17!:0     NB. regex match one
rxmatches=:       17!:1     NB. regex match all
rxcomp=:          17!:2     NB. regex compile
rxfree=:          17!:3     NB. free regex handle
rxhandles=:       17!:4     NB. list regex handles
rxinfo=:          17!:5     NB. info on pattern handles
rxerror=:         17!:6     NB. regex error msg

classnl=:         18!:1     NB. class namelist
classpath=:       18!:2     NB. class path
classcreate=:     18!:3     NB. class create
classcurrent=:    18!:4     NB. set current class 
classname=:       18!:5     NB. current class name
