NB. Standard unix system calls.
NB.
NB. "Standard" means: POSIX 1003.1 aka ISO 9945-1: 1996
NB. plus really universal facilities (such as select(2)),
NB. as they can usually be found in the Unix95 Spec.
NB.
NB. The definitions here are from the time before there was
NB. the "sym2ijs" converter.  It would perhaps make sense
NB. to fuse the function prototypes here with their associated
NB. constant and typedefintions.
NB. The associated sym file for this script is unixsyms.sym.

require 'dll'
require  'unixsyms'

NB. This list of prototypes is currently very short.
NB. It just covers the system calls as needed for jmf.ijs.

LIB =: find_dll 'c'

LIB mkapi_syscalls_ noun define
open i *c i i
close i i
read i i * i
write i i * i
lseek i i i i
mmap * * i i i i i
munmap i * i
)

NB. Provide properly typed interfaces for various flavours of
NB. both ioctl and fcntl:

ccd =. 1 : '(LIB, '' '', m.) & cd'

ioctl_syscalls_     =: 'ioctl i i i' ccd
ioctl_i_syscalls_   =: 'ioctl i i i i' ccd
ioctl_p_syscalls_   =: 'ioctl i i i *' ccd
fcntl_i_syscalls_   =: 'fcntl i i i i' ccd
fcntl_p_syscalls_   =: 'fcntl i i i *' ccd

NB. Miles Z. used the c_foo functions, with "c_" indicating "from the C
NB. library".  These are actually all unix system calls, and I would
NB. prefer to have the whole posix-and-more shebang in its own locale.
NB. (Guess why this file is called syscalls.ijs...)
NB. I intend to get rid of the c_foo layer next.

NB. c_open filename;flags
NB. c_close fd
NB. c_read fd;buf;len
NB. c_mmap  start; length; prot; flags; fd; offset (start is typically <0)
NB. c_munmap   start; length
c_open =: open_syscalls_
c_close =: close_syscalls_
c_read =: read_syscalls_
c_write =: write_syscalls_
c_lseek =: lseek_syscalls_
c_mmap =: mmap_syscalls_
c_munmap =: munmap_syscalls_
