NB.  HTTP utilities
NB.  The scope of this script should be:
NB.  - HTTP requests and responses,
NB.  - URL encoding/decoding
NB.  - HTTP header composition/analysis
NB.  - FORM/CGI-related tools
NB.
NB.  The most relevant standards are:
NB.  RFC 1945:  HTTP/1.0
NB.  RFC 2616:  HTTP/1.1
NB.  RFC 2396:  URI/URLs
NB.
NB.  Beyond the scope are:
NB.  - MIME-related tools
NB.  - HTML-related tools
NB.  These topics are complex enough to merit their own
NB.  utility scripts.

require 'contrib/portable/main/tcpip'

coclass 'http'

NB.*simple_get_request v send a simple GET request (HTTP/0.9)
NB. DEPRECATED DEPRECATED DEPRECATED
NB. form:       (server ; port)  simple_get_request  uri
NB. Example:	('www.jsoftware.com';80) get_request '/download/socktest.txt'
NB.
NB. Note that the use of HTTP/0.9 is strongly deprecated.
NB. This obsoleted first version of HTTP didn't use any Headers.
NB.
NB. Errors with the request or its fulfillment are not properly indicated
NB. by the server.  It is up to you to know the Content-Type of the
NB. returned data.  Usually, it will be HTML.
NB.
NB. The function returns the full server response as a character vector.
NB. If successfull, this should be the ressource as indicated by the
NB. uri.  Otherwise it may be an error message encoded as an HTML doc.

simple_get_request =: dyad define
	'host port' =. x. [ url=.y.

	sk=. > sdcheck sdsocket''
	sdcheck sdconnect sk; (sdcheck sdgethostbyname host) , <port

	sdcheck ('GET ', url, CR,LF) sdsend sk, 0
	response=.read_all_tcpip_ sk
	sdcheck sdclose sk
	response
)

plain_response =: monad define
	text =. y.

	status =. 'HTTP/1.0 200 OK', CRLF
	ct =. 'Content-Type: text/plain',CRLF
	cl =. 'Content-Length: ', (":#text), CRLF

	hdr =. status, ct, cl
	full_response =. hdr, CRLF, text
)


NB. Header parsing, CGI stuff
NB. CGI/1.1:  http://CGI-Spec.Golux.Com/draft-coar-cgi-v11-03.html
