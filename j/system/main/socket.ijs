NB. built from project: source\api\winsock\winsock
NB. Heavily modified by Martin Neitzel.

require 'dll unixsyms'

coclass 'jsocket'

NB.  Missing loads of constants at this spot?
NB.  They all went to Florida.  Well, netdefs.{sym,ijs}, to be honest.
NB.  There original place (with Alex) used to be sockcons.ijs.

require 'netdefs'

NB.  The only remaining few globals for this script which are _not_ supplied
NB.  by system headers appear to be these three:

INVALID_SOCKET=: 1
SOCKET_ERROR=: _1
BUFFER_SIZE=: 1024


NB.  Alex Kornilovski had the windows-specific euivalent of the
NB.  following code chunk in sockapi.ijs.
NB.
NB.  There are two changes in this context:
NB.
NB.  On the Unix side, we have to be a bit more careful which libraries
NB.  will provide the various functions.  It actually differs from system
NB.  to system.
NB.
NB.  The other difference is that _all_ pointer parameters are now
NB.  truthfully declared as "*" or "*typecode".  Having them declared
NB.  as "i" was simply to error prone.

NB. Locate file name for libc shared library/libraries.
NB. On most Unix systems, the socket routines are part of the
NB. standard C library.
NB. SunOS 4: like above, but we keep it unsopported for now.
NB. SunOS 5 (and higher): /lib/libsocket.so and /lib/libnsl.so
NB. Windows: some winsock.dll
NB.
NB. We compute the "different" library names according to all possible splits.
NB. (Right now: the Solaris splits are the dominating ones.

locatesocket =. monad define
	lib =. 'c' NB. default
	select. y.
	case. 'SunOS'	do. lib =. 'socket'
	end.
	find_dll lib
)

locatensl =. monad define
	lib =. 'c' NB. default
	select. y.
	case. 'SunOS'	do. lib =. 'nsl'
	end.
	find_dll lib
)

cdll=: find_dll 'c'
sockdll =: locatesocket uname
nsldll  =: locatensl    uname

ccdm=:    1 : '(cdll,   '' '',x.)&(15!:0)'
sockcdm=: 1 : '(sockdll,'' '',x.)&(15!:0)'
nslcdm=:  1 : '(nsldll, '' '',x.)&(15!:0)'

gethostbyaddrJ=: 'gethostbyaddr * * i i' nslcdm
inet_addrJ=: 'inet_addr i *c' nslcdm
inet_ntoaJ=: 'inet_ntoa i i' nslcdm
gethostbynameJ=: 'gethostbyname * *c' nslcdm
gethostnameJ=: 'gethostname i *c i' nslcdm
getprotobynameJ=: 'getprotobyname i *c' sockcdm
getprotobynumberJ=: 'getprotobynumber i i' sockcdm
getservbyportJ=: 'getservbyport i i i' sockcdm
getservbynameJ=: 'getservbyname i i i' sockcdm
acceptJ=: 'accept i i * *i' sockcdm
bindJ=: 'bind i i * i' sockcdm
closeJ=: 'close i i' ccdm
connectJ=: 'connect i i * i' sockcdm
getpeernameJ=: 'getpeername i i * *i' sockcdm
getsocknameJ=: 'getsockname i i * *i' sockcdm
getsockoptJ=: 'getsockopt i i i i * *i' sockcdm
htonlJ=: 'htonl i i' sockcdm
htonsJ=: 'htons s s' sockcdm
listenJ=: 'listen i i i' sockcdm
ntohlJ=: 'ntohl i i' sockcdm
ntohsJ=: 'ntohs s s' sockcdm
recvJ=: 'recv i i * i i' sockcdm
recvfromJ=: 'recvfrom i i * i i * *i' sockcdm
selectJ=: 'select i i * * * *' ccdm
sendJ=: 'send i i * i i' sockcdm
sendtoJ=: 'sendto i i * i * i' sockcdm
setsockoptJ=: 'setsockopt i i i i * i' sockcdm
shutdownJ=: 'shutdown i i i' sockcdm
socketJ=: 'socket i i i i' sockcdm

NB.  End of sockapi.ijs section.

res=: >@:{.
take =: {.
pick =: >@{
taketo=: [: ] (E. i. 1:) {. ]		NB. XXX unused
deb=: #~ (+. (1: |. (> </\)))@(' '&~:)	NB. XXX unused

address2string=: verb define
NB. get IP address from addr_in structure
NB. y. -  pointer to the structure
NB. This function preserves the network byte order.
NB. XXX IPv4 dependent.
}: ;'.',~each ":each a.i. memr y.,0,4
)

sdsockaddress=: verb define
NB. y. active socket
NB. ++
sockin=. mema sockaddr_in_sz		NB. XXX IPv4 only
if. 0=res ret =. getsocknameJ y.;(<sockin);,sockaddr_in_sz do.
  'unexpected sock addr length' assert sockaddr_in_sz = {. 3 pick ret
  addr=. address2string sockin+sin_addr_off
else.
  memf sockin
  _1;''
  return.
end.
memf sockin
0;addr
)

sdsend=: dyad define
NB. send data
NB. y.- socket;An in indicator specifying the way in which the call is made (0)
NB. x.- data
NB. ++
's indicator'=. y.
data=. x.
r=. sendJ s;data;(#data);indicator
if. _1 = >{.r do.
  r=. (sdsockerror '');0
else.
  r=. 0;{.r
end.
r
)

sdsendto=: dyad define
NB. send data
NB. y.- socket ; flags ; family ; address ; port
NB. x.- data
NB. ++ ?
's flags family address port'=. y.
data=. x.

sockaddr =. mema sockaddr_in_sz		NB. XXX IPv4 specific

(1 ic fam) memw sockaddr_in, sin_family_off, sin_family_sz, JCHAR

port=. res htonsJ port
(1 ic port) memw sockaddr_in, sin_port_off, sin_port_sz, JCHAR

addr=. a.{~".each '.' cutopen address	NB. preserving network byte order
in_addr =. sockaddr_in+sin_addr_off
addr memw in_addr, s_addr_off, s_addr_sz, JCHAR

r=. sendtoJ s;data;(#data);flags;(<sockaddr_in);sockaddr_in_sz
memf sockaddr_in
if. _1={.r do.
  r=. (sdsockerror '');0
else.
  r=. 0;{.r
end.
r
)

sdcleanup=: verb define
NB. initialize winsock
NB. ++

if. 0=nc <'SOCKETS' do.
  sdclose each SOCKETS
end.
SOCKETS=: i.0
0
)

sdreset=: sdcleanup


sdrecv=: verb define
NB. read data
NB. y.- socket,data_size,An indicator specifying the way in which the
NB.     call is made (0)
NB. ++
s=. 0{y.
size=. 1{y.
buff=. mema size
if. SOCKET_ERROR~:res dat=. recvJ s;(<buff);size;2{y.,0,0 do.
  if. 0=l=. >{.dat do. 0;'' else. 0;memr buff,0,l end.
else. (sdsockerror '');'' end.
if. memf buff do. end.
)


sdrecvfrom=: verb define
NB. read data from
NB. y.- socket,data_size,An indicator specifying the way in which the
NB.     call is made (0)
NB. -+
's size flags' =. 3{. y. ,<0
sockaddr=. mema sockaddr_in_sz

dat=.recvfromJ s;(size#'.');size;flags;(<sockaddr);,sockaddr_in_sz
if. SOCKET_ERROR = rcvd_size =. res dat do.
  memf sockaddr
  (sdsockerror '');'';''
  return.
end.

NB. There used to be a check here on the 0-length of the read data.
NB. However, nothing precludes a zero-length packet, in particular
NB. if an option preserving message bounderies should be set.
NB. The old code suppressed the source address in that case, we
NB. return it dutifully.   (It still does  not return the peer's
NB. port number, but that's just the way sdrecvfrom is designed.)
NB. The old was also erroneous in that it assumed that requested
NB. size would equal the received size.  They may differ.

'unexpected size of peer address' assert sockaddr_in_sz = 6 pick dat
packet =. rcvd_size {. 2 pick dat
adr=. address2string sockaddr+sin_addr_off
memf sockaddr
0;packet;adr
)


sdconnect=: verb define
NB. connect to the socket
NB. y. - socket , family , address , port
NB ++
's fam host port'=. >each y.

sockaddr_in=. mema sockaddr_in_sz

(1 ic fam) memw sockaddr_in, sin_family_off, sin_family_sz, JCHAR

port=. res htonsJ port
(1 ic port) memw sockaddr_in, sin_port_off, sin_port_sz, JCHAR

addr=. a.{~".each '.' cutopen host	NB. preserving network byte order
in_addr =. sockaddr_in+sin_addr_off
addr memw in_addr, s_addr_off, s_addr_sz, JCHAR

NB. XXX: why the "{.s" ?
if. 0~:z=. res connectJ ({.s);(<sockaddr_in);sockaddr_in_sz
do. z=. sdsockerror '' end.
memf sockaddr_in
z
)

sdsocket=: verb define
NB. creates a socket
NB. ++
s=. y.
if. 0=#y. do.
  s=. PF_INET,SOCK_STREAM,IPPROTO_TCP
end.
s=. 3{.s
s=. res socketJ (0{s);(1{s);2{s
if. s < 0 do.
  <INVALID_SOCKET
  return.
end.
SOCKETS=: SOCKETS,s
0;s
)


sdbind=: verb define
NB. bind socket
NB. y. - socket , family , address , port
NB. ++
's fam host port'=. >each y.
sockaddr_in =. mema sockaddr_in_sz

(1 ic fam) memw sockaddr_in, sin_family_off, sin_family_sz, JCHAR

port=. res htonsJ port
(1 ic port) memw sockaddr_in, sin_port_off, sin_port_sz, JCHAR

if. 0=#addr=. a.{~".each '.' cutopen host do.
  addr=. 2 ic res htonlJ INADDR_ANY
end.
in_addr =. sockaddr_in+sin_addr_off
addr memw in_addr, s_addr_off, s_addr_sz, JCHAR

NB. XXX Why  {.s  instead of plain s  ?
if. 0~:res bindJ ({.s);(<sockaddr_in);sockaddr_in_sz do.
  z=. sdsockerror ''
  if. s > 0 do.
    dummy=. sdclose {.s
  end.
  memf sockaddr_in
  z return.
end.
memf sockaddr_in
0
)

sdasync=: verb define
'not implemented under Unix/Linux - please use sdselect' assert 0
)


sdlisten=: verb define
NB. setup listener for the socket
NB. y. - socket [; queue_length]
NB. default SOMAXCONN - the maximum number of pending connections.
NB. ++
's l'=. 2{.y.,SOMAXCONN
if. 0=res listenJ s;l do.
  0
else.
  sdsockerror ''
end.
)


sdaccept=: verb define
NB. accept connection
NB. y. - socket
NB. ++
sockin=. mema sockaddr_in_sz
if. 0 ~: s=. res r =. acceptJ y.;(<sockin);,sockaddr_in_sz do.
  'unexpected peer address size' assert sockaddr_in_sz = >3{r
  SOCKETS=: SOCKETS,s
  0;s
else.
  <sdsockerror ''
end.
if. memf sockin do. end.
)

sdgethostbyname=: verb define
NB. Returns an address from a name
NB. y. - host name
NB. ++
NB. not a valid ('dotted' IP address)
if. _1=res addr=. inet_addrJ <y. do.   
  if. 0~: hostent =. res gethostbynameJ <y. do.
    addr_list =. memr hostent, h_addr_list_off, 1, JPTR
    first_addr =. memr addr_list, 0, 1, JPTR
    'name did not resolve to address' assert first_addr ~: 0
    addr=. address2string first_addr
  else.
    addr=. '255.255.255.255'
  end.
else.
  addr=. }: ;'.',~each ":each a.i.>1{addr
end.
0;PF_INET;addr
)


sdgethostbyaddr=: verb define
NB. Returns a name from an address
NB. y. - address family ; host ip address
NB. ++

NB. XXX IPv4 dependent. (So why the "fam" parameter at all?)

'fam addr'=. y.
try.
  addr=. a.{~".each '.' cutopen ;addr
catch.
  _1;'unknown host'
  return.
end.
in_addr=. mema in_addr_sz
addr memw in_addr,0,in_addr_sz,JCHAR  NB. aligned address in network byte order

host_ent =. res gethostbyaddrJ (<in_addr); in_addr_sz ;fam
if. host_ent ~:0 do.
  h_name =. memr, host_ent, h_name_off, 1, JPTR
  name=. memr h_name, 0, JSTR
  NB. XXX huh?  the canocical hostname is already a simple string,
  NB. and the \0 character is already stripped off.  So don't do:
  NB. name=. >1 take (0{a.)cutopen name
  NB. Also, there used to be a wrong deallocation of (now) h_name here:
  NB. memf 0{adr
else.
  memf in_addr
  _1;'unknown host'
  return.
end.
memf in_addr	NB. XXX bugfix: old "phe" should never have been de-alloc'ed
0;name
)


NB. sdshutdown          terminate a full-duplex connection properly
NB.                     well-behaving programs should to this prior
NB.                     to a close on a TCP socket.
NB. Arguments y. are:  socket [, how ]
NB. with how indication the further use of the socket:
NB.     0: no further reads on this socket,
NB.     1: no further writes to this socket,
NB.     2: no IO at all on this socket (default)

sdshutdown =: verb define
  'socket how' =. 2 {. y., 2
  Jshutdown
  if. 0=res shutdownJ socket;how do.
    0
  else.
    sdsockerror ''
  end.
)
		

sdclose=: verb define
NB. close socket
NB. y. - socket
if. 0=res closeJ {.y. do.
  SOCKETS=: SOCKETS-.y.
  0
else.
  sdsockerror ''
end.
)


NB. fdset_bytes		compute the fds_bits byte array marking from a vector
NB.			with file descriptors to be marked.
NB.
NB. Output is a character (byte) vector.  The length of this result
NB. vector is given by x. and must be
NB. - a multiple of the word size (4).
NB. - large enough to accomodate all elements
NB. - not larger than FD_SETSIZE/8
NB. The monad defaults x. to the smallest such value.
NB.
NB. y. is a list of the interesting file descriptors ("small ints").

fdset_bytes =: verb define
	max =. >./ y.
	'cannot represent fds within FD_SETSIZE limit' assert max<FD_SETSIZE
	len =. 4 * <. 32 %~ max+31
	len fdset_bytes y.
:
	len=. x.
	fds=. y.
	bitvector=. 1 fds} (len*8)#0
	bytes =. a. {~ _8 #.@|.\ bitvector
	NB. Dependending on the platform endiness, the bytes within the words
	NB. need to be reversed:
	if. -. 1 0 0 0 -: a. i. 2 ic 1  do.
		bytes =. , _4 |.\ bytes
	end.
	bytes
)

NB. fdset_fds	compute the list of file descriptors from
NB.		the fd_set byte array representation.
NB. Input y. is the byte array (as for example, filled by select(2)).

fdset_fds =: monad define
	bytes =. y.
        NB. Dependending on the platform endiness, the bytes within the words 
        NB. need to be reversed:
	if.  -. 1 0 0 0 -: a. i. 2 ic 1  do.
		bytes =. , _4 |.\ bytes
	end.
	bitvec =. , _8 |.\ , (8#2)&#: a. i. bytes
	fds =. (# i.@#) bitvec
)

sdselect=: verb define
if. 0=#y. do.
  'r w e t'=. SOCKETS;SOCKETS;SOCKETS;0
else.
  'r w e t'=. y.
end.

nul=. i.0
bytes=. 4*words=. >:<.32%~len=. >:>./r,w,e,0

fdsetr=. mema bytes
(bytes fdset_bytes r) memw fdsetr,fds_bits_off,bytes,JCHAR
fdsetw=. mema bytes
(bytes fdset_bytes w) memw fdsetw,fds_bits_off,bytes,JCHAR
fdsete=. mema bytes
(bytes fdset_bytes e) memw fdsete,fds_bits_off,bytes,JCHAR

time=. mema timeval_sz
NB. t is in milliseconds;  convert this into seconds and _micro_seconds:
(       <.t % 1000) memw time,tv_sec_off, 1,JINT
(1000 * <.t |~1000) memw time,tv_usec_off,1,JINT

if. _1=>{.selectJ len;(<fdsetr);(<fdsetw);(<fdsete);<<time do.
  memf"0 time,(#~ *) fdsetr,fdsetw,fdsete
  (sdsockerror '');nul;nul;nul
  return.
end.

r=. fdset_fds memr fdsetr,fds_bits_off,bytes,JCHAR
w=. fdset_fds memr fdsetw,fds_bits_off,bytes,JCHAR
e=. fdset_fds memr fdsete,fds_bits_off,bytes,JCHAR
	
memf"0 time,(#~ *) fdsetr,fdsetw,fdsete

0;r;w;e
)


sdgetsockopt=: verb define
's lev name'=. y.
NB. XXX the original implementation fails to provide
NB. the memory to receive the option value.  Allocating constantly only
NB. four bytes won't do in general.  We should really get the result
NB. space and length as a parameter.  Likewise, we shouldn't attempt
NB. to interpret the result.  It may well be something different than
NB. a short int or int.
buf=. mema 4 
len=. mema 4      
4 memw len,0,1,JINT
r=. getsockoptJ s;lev;name;(<buf);<<len
if. 0={.;r do.
  if. name-:SO_LINGER do.
    r=. _1 ic memr buf,0,(memr len,0,1,JINT), JCHAR
  else.
    r=. _2 ic memr buf,0,(memr len,0,1,JINT), JCHAR
  end.
  memf each buf,len
  0;r
  return.
end.
memf each buf, len
(sdsockerror '');0
)

sdsetsockopt=: verb define
's lev name'=. 3{.y.
NB. XXX The following assumes that the only option type is
NB. int (short int).  This is not valid.  The fixed length
NB. is buggy in the same way.
val=. 3}.y.
if. name-:SO_LINGER do.
  val=. ,/1 ic each 2{.val  
else.
  val=. 2 ic val
end.

buf=. mema 4
val memw buf,0,4
len=. 4
r=. setsockoptJ s;lev;name;(<buf);len
if. 0={.;r do.
  r=. _2 ic memr buf,0,len
  memf buf
  0;r
  return.
end.
memf buf
(sdsockerror '');0
)

sdsockerror=: verb define
> {. cderx ''
)

sdioctl=: verb define
  'Please use ioctl/fcntl from syscalls.ijs' assert 0
)


sdgethostname=: verb define
if. 0=res name=. gethostnameJ (256#' ');256 do.
  name=. >1 take (0{a.)cutopen ;1{name
else.
  name=. 'unknown host'
end.
0;name
)


sdgetpeername=: verb define
sockin=. mema sockaddr_in_sz
if. 0=ret=. res getpeernameJ y.;(<sockin);,sockaddr_in_sz do.
  fam=. AF_INET
  addr=. address2string socki+sin_addr_off
  port=. >{. ntohsJ {. _1 ic memr sockin,sin_port_off,sin_port_sz,JCHAR
else.
  fam=. 0
  addr=. ''
  port=. 0
end.
memf sockin
ret;fam;addr;port
)

sdgetsockname=: verb define
sockin=. mema sockaddr_in_sz
if. 0=ret=. res getsocknameJ y.;(<sockin);,sockaddr_in_sz do.
  fam=. AF_INET
  addr=. address2string sockin+sin_addr_off
  port=. >{.ntohsJ {. _1 ic memr sockin,sin_port_off,sin_port_sz,JCHAR
else.
  fam=. 0
  addr=. ''
  port=. 0
end.
memf each sockin
ret;fam;addr;port
)


sdgetsockets=: verb define
try.
  r=. 0;SOCKETS
catch.
  r=. ,<0
end.
r
)
sdcheck=: verb define
if. 0~:>0{y. do.
  (sderror y.)13!:8[3
else.
  1}.y.
end.
)

sderror=: verb define
  strerror >0{y.
)

NB. Publish the interface in the z locale.
NB. This used to be sockz.ijs at Alex' version before it got mangled.

nms=. <;._2 (0 : 0)
sdsocket
sdrecv
sdsend
sdrecvfrom
sdsendto
sdshutdown
sdclose
sdconnect
sdbind
sdlisten
sdaccept
sdselect
sdgetsockopt
sdsetsockopt
sdioctl
sdgethostname
sdgetpeername
sdgetsockname
sdgethostbyname
sdgethostbyaddr
sdgetsockets
sdasync
sdcleanup
sdreset
sdcheck
sderror
)
". > nms ,each (<'_z_=:') ,each nms ,each <'_jsocket_'

sdreset ''
