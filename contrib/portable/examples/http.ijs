NB.  HTTP utilities

require 'socket'

NB. get_request
NB. Example:	('www.jsoftware.com';80) get_request '/download/socktest.txt'

get_request =: dyad define
	'host port' =. x. [ url=.y.

	sk=.sdcheck sdsocket''
	sdcheck sdconnect sk; (sdcheck sdgethostbyname host) , <port

	sdcheck ('GET ', url, CR,LF) sdsend sk, 0
	response=.''
	while. # frag =. ; sdcheck sdrecv sk, 10000, 0 do.
		response =. response, frag
	end.
	sdcheck sdclose sk
	response
)
