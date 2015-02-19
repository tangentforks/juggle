/* ip.c - map hostnames */

/*  Copyright 1992  Mark Russell, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ukcprog_ip_sccsid[] = "@(#)ip.c	1.6 17 Apr 1994 UKC";

#ifndef MSDOS
#include <sys/types.h>
#else
#include <sys/tk_types.h>
#endif
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "ukcprog.h"

/*  Map a hostname to an IP address.  The address is returned in network
 *  byte order.  Return 0 for success, -1 and an error message on failure.
 *
 *  If the hostname looks like an IP quad we convert that to an IP address.
 */
int
get_host_addr(hostname, p_addr)
const char *hostname;
struct in_addr *p_addr;
{
	struct hostent *h;
	int b3, b2, b1, b0;
	char c;

	if (sscanf(hostname, "%d.%d.%d.%d%c", &b3, &b2, &b1, &b0, &c) == 4) {
		 unsigned long val;

		 val = (b3 << 24) | (b2 << 16) | (b1 << 8) | b0;
		 p_addr->s_addr = htonl(val);
		 return 0;
	}

	if ((h = gethostbyname(hostname)) == NULL) {
		errf("Can't find address of %s", hostname);
		return -1;
	}

	if (h->h_addrtype != AF_INET) {
		errf("%s has non-IP address (addrtype=%d)",
						hostname, h->h_addrtype);
		return -1;
	}

	memcpy((char *)p_addr, (char *)h->h_addr_list[0], sizeof(*p_addr));
	return 0;
}

/*  Map a service name to a port number in network byte order.
 *  If the service name looks like a number we return that.
 */
int
get_service_port(servname, p_port)
const char *servname;
int *p_port;
{
	struct servent *sp;
	char *endstr;
	unsigned short hport;

	hport = strtol(servname, &endstr, 0);
	if (endstr != servname && *endstr == '\0') {
		*p_port = htons(hport);
		return 0;
	}

	if ((sp = getservbyname(servname, "tcp")) == NULL) {
		errf("Unknown service `%s'", servname);
		return -1;
	}

	*p_port = sp->s_port;

	return 0;
}
