NB. do not edit -- created by sym2ijs from -
sockaddr_sz =: 16
sa_family_off =: 0
sa_family_sz =: 2
sa_data_off =: 2
sa_data_sz =: 14

sockaddr_in_sz =: 16
sin_family_off =: 0
sin_family_sz =: 2
sin_port_off =: 2
sin_port_sz =: 2
sin_addr_off =: 4
sin_addr_sz =: 4

in_addr_sz =: 4
s_addr_off =: 0
s_addr_sz =: 4

hostent_sz =: 20
h_name_off =: 0
h_name_sz =: 4
h_aliases_off =: 4
h_aliases_sz =: 4
h_addrtype_off =: 8
h_addrtype_sz =: 4
h_length_off =: 12
h_length_sz =: 4
h_addr_list_off =: 16
h_addr_list_sz =: 4


SIOCATMARK =: 35077


IPPROTO_IP =: 0
IPPROTO_ICMP =: 1
IPPROTO_IGMP =: 2
IPPROTO_ENCAP =: 98
IPPROTO_TCP =: 6
IPPROTO_EGP =: 8
IPPROTO_PUP =: 12
IPPROTO_UDP =: 17
IPPROTO_IDP =: 22
IPPROTO_RAW =: 255
IPPROTO_MAX =: 256

IPPORT_ECHO =: 7
IPPORT_DISCARD =: 9
IPPORT_SYSTAT =: 11
IPPORT_DAYTIME =: 13
IPPORT_NETSTAT =: 15
IPPORT_FTP =: 21
IPPORT_TELNET =: 23
IPPORT_SMTP =: 25
IPPORT_TIMESERVER =: 37
IPPORT_NAMESERVER =: 42
IPPORT_WHOIS =: 43
IPPORT_MTP =: 57

IPPORT_TFTP =: 69
IPPORT_RJE =: 77
IPPORT_FINGER =: 79
IPPORT_TTYLINK =: 87
IPPORT_SUPDUP =: 95
IPPORT_EXECSERVER =: 512
IPPORT_LOGINSERVER =: 513
IPPORT_CMDSERVER =: 514
IPPORT_CMDSERVER =: 514
IPPORT_EFSSERVER =: 520
IPPORT_BIFFUDP =: 512
IPPORT_WHOSERVER =: 513
IPPORT_ROUTESERVER =: 520
 IPPORT_HTTP=: 80

IPPORT_RESERVED =: 1024
IPPORT_USERRESERVED =: 5000


INADDR_ANY =: 0
INADDR_LOOPBACK =: 2130706433
INADDR_BROADCAST =: -1
INADDR_NONE =: -1
INADDR_UNSPEC_GROUP =: -536870912
INADDR_ALLHOSTS_GROUP =: -536870911
INADDR_MAX_LOCAL_GROUP =: -536870657
IN_LOOPBACKNET =: 127

SOCK_STREAM =: 1
SOCK_DGRAM =: 2
SOCK_RAW =: 3
SOCK_RDM =: 4
SOCK_SEQPACKET =: 5

SOL_SOCKET =: 1
SO_DEBUG =: 1
SO_REUSEADDR =: 2
SO_KEEPALIVE =: 9
SO_DONTROUTE =: 5
SO_BROADCAST =: 6
SO_LINGER =: 13
SO_OOBINLINE =: 10

SO_SNDBUF =: 7
SO_RCVBUF =: 8
SO_SNDLOWAT =: 19
SO_RCVLOWAT =: 18
SO_SNDTIMEO =: 21
SO_RCVTIMEO =: 20
SO_ERROR =: 4
SO_TYPE =: 3

linger_sz =: 8
l_onoff_off =: 0
l_onoff_sz =: 4
l_linger_off =: 4
l_linger_sz =: 4

AF_UNSPEC =: 0
AF_UNIX =: 1
AF_INET =: 2
AF_SNA =: 22
AF_DECnet =: 12
AF_APPLETALK =: 5
AF_X25 =: 9
AF_IPX =: 4
AF_MAX =: 32
PF_UNSPEC =: 0
PF_UNIX =: 1
PF_INET =: 2
PF_SNA =: 22
PF_DECnet =: 12
PF_APPLETALK =: 5
PF_X25 =: 9
PF_IPX =: 4
PF_MAX =: 32

SOMAXCONN =: 128
MSG_OOB =: 1
MSG_PEEK =: 2
MSG_DONTROUTE =: 4

msghdr_sz =: 28
msg_name_off =: 0
msg_name_sz =: 4
msg_namelen_off =: 4
msg_namelen_sz =: 4
msg_iov_off =: 8
msg_iov_sz =: 4
msg_iovlen_off =: 12
msg_iovlen_sz =: 4
msg_control_off =: 16
msg_control_sz =: 4
msg_controllen_off =: 20
msg_controllen_sz =: 4
msg_flags_off =: 24
msg_flags_sz =: 4




HOST_NOT_FOUND =: 1
TRY_AGAIN =: 2
NO_RECOVERY =: 3
NO_DATA =: 4
NO_ADDRESS =: 4
NETDB_INTERNAL =: -1
NETDB_SUCCESS =: 0


