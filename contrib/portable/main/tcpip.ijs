NB. tcpip -- various tools to deal with TCP/IP
NB. These utilities are higher level routines than the low-level
NB. "socket" API.  These routines will give you TCP servers and
NB. simple, whole transmissions without too much effort.

require 'socket'

coclass 'tcpip'

NB.*read_all v   read all data from a socket as long as data is available
NB. form:   read_all socket

read_all =: monad define
	sk =. y.

	response=.''
	while. # frag =. ; sdcheck sdrecv sk, 10000, 0 do.
		response =. response, frag
	end.
	response
)

NB.*send_all v  send a complete message via a socket
NB. form:   socket send_all text
NB.
NB. sdsend may only send a partial chunk of a message.
NB. This function does the necessary looping.

send_all =: dyad define
	socket =. x.
	text =. y.

	while. #text do.
		transmitted =. > sdcheck text sdsend socket,0
		if. transmitted=0 do.
			NB. Ooops.  This essentially means something
			NB. has gone wrong.
			break.
		end.
		text =. transmitted }. text
	end.
	empty ''
)


NB.*tcp_server_loop c  repeatly accept tcp connections on a tcp port.
NB. form:	handler tcp_server_loop  (addr;port)
NB.
NB. This conjunction establishes and runs a loop to continuously
NB. accept connections on a specific server port.  For each connection,
NB. the "handler" verb is call as monad with the socket for the client
NB. as the right argument.  The handler should return a leading 0 in order
NB. to stop the loop.
NB.
NB. The conjunction is a bit odd since it will return a noun:
NB. The number of client connections that were accepted.
NB.
NB. BEWARE:  If no connection is ever coming in, this will block
NB. forever.
NB. Todo:  this could have zillions of variations/options/features.
NB. I'm thinking of timeouts, passed contexts, syslogging, and
NB. all kinds of monad/dyad/adv/conj variations.

tcp_server_loop =: conjunction define
	NB. monad with dummy argument.
	NB. returns the number of accepted connections.

	handler =. u.
	'addr port' =. n.
	accept_count=.0

	srv =. >0{sdcheck sdsocket ''
	sdcheck sdbind srv ; AF_INET_jsocket_; addr; port
	sdcheck sdlisten srv, 5
	whilst.
		goon =. handler client
		sdcheck sdshutdown client, 1
		sdcheck sdclose client
		goon
	do.
		client =. > sdcheck sdaccept srv
		accept_count =: >: accept_count
	end.
	sdcheck sdclose srv
	accept_count"_
)

NB.*demo_handler v   a trivial service suitable as tcp_server_loop function.
demo_handler =: monad define
	socket =. y.
	now=.6!:0''
	('Now is the time: ', (":now), CRLF) sdsend socket,0
	NB.  If we are within the first half of a minute,
	NB.  we are willing to continue with further requests.
	NB.  If we are in the second half, signal the end to the
	NB.  server loop:
	({:now) < 30
)
