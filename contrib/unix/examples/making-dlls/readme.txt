         Portable conversions of existing C APIs into J APIs.

                              Lorin Lund
                          W.B. Software Inc.
                           llund@wbs-inc.com

                            Martin Neitzel
                         Gaertner Datensysteme
                          neitzel@gaertner.de


Abstract
	Both in Unix and in Windows, libraries are _the_ modular
	building blocks for programmers.  They embody, often in
	a system-specific manner, an API defined at the C source
	level, which usually not at all system-dependent.  The only
	successful way to interface in a portable manner to such
	APIs from J is to target excusively this source level.
	C APIs are portable.  Hardwired constants with system
	specific values are not.

	This document explains how to make existing C functions and
	libraries available to J programmers.	Simple, orderly,
	and most of all:  truely portably.

Quote:
	There is no such thing as portable software.
	There is only software which has already been
	ported.
				-- The X Consortium, in
				"Mozilla's Guide to Porting X Servers"

** Introduction

This document explains how to write portable J scripts interfacing to C
libraries -- avoiding the pitfall of hardwired constants.  The solution
which makes this actually quite easy is called "sym2ijs".  The concept
and its implementation was developed by Gaertner Datensysteme for the
first portable implementations of the 15!:-based jmf, regex, and socket
libraries in J4.05/Unix.

Writing 15!:x-based J scripts is usually considered to be some kind
of black magic to most J application programmers, anyway.  Those three
library files in particular deal with quite advanced subject matter and
are not at all easy to understand.  In addition, they are burdened by
their historic ad-hoc genesis (in the case of jmf.ijs) and obligations
to be compatibel with older, J-defined APIs (regex, socket, jmf).
If those three initial applications should serve as an example at all,
than rather as abhorent ones for how not to do things if avoidable.

If you want to interface to some existing library, you must first be
familiar with J's 15!: family of foreigns.  Follow the J User Manual and
the "dll" labs coming with the standard J system.  This will get you up to
a level where you can call shared library functions.  This knowledge is
also a prerequisite to continue with this article and to proceed to the
next level: providing 15!:-based interfaces quickly and with out hunting
manually through header files for the required integer constants and such.

With some suitable tools, the work becomes not just a good deal easier.
Even better, your implemetation will be portable across hardware and OS
platforms (Windows, MacOS, and all Unix variations).

This example shows how to write a J interface for the standard UNIX
"syslog" interface.


** Our guinea pig:  the "syslog" API

Our choice for this demonstration is the Unix syslog() function and
its brethren.  In case you never heard about this function, it is the
one used to send diagnostics to the syslogd(8) daemon which will in
turn dump them to the console or to some file such as /var/log/messages.
Being able to syslog is essential for daemons running "in the background",
such as web servers.

The syslog API is very small and can be completely covered in this
example.  Syslogging is also extremely useful and not already provided
along with the standard distribution.  Three excellent reasons to tackle
it here.

Here is the beginning of a Linux "man 3 syslog" output:

	NAME
	       closelog,  openlog,  syslog  - send messages to the system
	       logger

	SYNOPSIS
	       #include <syslog.h>
	       void openlog( char *ident, int option, int  facility)
	       void syslog( int priority, char *format, ...)
	       void closelog( void )

The man page also lists that the following symbolic constants as
defined:

	options:	LOG_CONS LOG_NDELAY LOG_PERROR LOG_PID
	facilities:	LOG_AUTH LOG_AUTHPRIV LOG_CRON LOG_DAEMON
			LOG_KERN LOG_LOCAL0 through LOG_LOCAL7
			LOG_LPR  LOG_MAIL LOG_NEWS LOG_SYSLOG
			LOG_USER LOG_UUCP
	priorities:	LOG_EMERG LOG_ALERT LOG_CRIT LOG_ERR
			LOG_WARNING LOG_NOTICE  LOG_INFO LOG_DEBUG

This definition from the Linux system is actually identical to the one
of most other Unixen, and it actually became an official stadard in the
Single Unix Specifcation Version 3.


**  Making a J API for the syslog routines.

Our goal is to provide a J API which mimicks the original C API as
closely as possible.  While it may be tempting for you to provide "a
better, more J-ish API", perhaps aiming at J's array capabilites, and
at the same time to cut corners short where something appears to be of
lesser use, don't do that.  Other programmers will appreciate it if they
can exploit existing knowledge as much as possible.  Minimize
deviations.  You can always add another abstraction layer later.

It is important to keep in mind that both the man pages and the
standards define the names of the symbolic constants, not their values.
The values can easily change from implementation to implementation.
We will therefore *not* hard-wire these values into our source code.

Here is our source code for the syslog J API:

	<syslog.h>

	J colocale 'z'
	J require 'dll'

	; option flags for openlog:
	i LOG_CONS LOG_NDELAY LOG_PERROR LOG_PID

	; facilities:
	i LOG_AUTH LOG_AUTHPRIV LOG_CRON LOG_DAEMON LOG_KERN
	i LOG_LOCAL0 LOG_LOCAL1 LOG_LOCAL2 LOG_LOCAL3
	i LOG_LOCAL4 LOG_LOCAL5 LOG_LOCAL6 LOG_LOCAL7
	i LOG_LPR  LOG_MAIL LOG_NEWS LOG_SYSLOG
	i LOG_USER LOG_UUCP

	; priority levels:
	i LOG_EMERG LOG_ALERT LOG_CRIT LOG_ERR LOG_WARNING
	i LOG_NOTICE  LOG_INFO LOG_DEBUG

	J (find_dll 'c') mkapi noun define
	J openlog n  *c i i
	J syslog  n  i *c *c
	J closelog n
	J )
	J NB. The C syslog() is really a printf-style variadic
	J NB. function.  15!:0 cannot do varargs.  We therefore
	J NB. just provide a cover function which takes just
	J NB. the loglevel and a preformatted string:
	J jsyslog =. 4 : 'syslog x. ; ''%s'' ; y.'


The "i" lines above create J assignments for the symbolic integer
constants.  The script includes a few "J"-labeled lines of code which
are simply passed through unchanged.

The file "syslog.sym" in this contains the source above.  Run "make"
which will run "sym2ijs", perhaps after some minor adjustment.

Behind the scenes, "sym2ijs" creates now a temporary C source with mostly
a lot of printf()-statements.  The temporary C source is compiled to
create the temporary executable program.  Finally, this executable is
run once, and all the printf()-statements now create a -- surprise! --
J script which is saved in the file "syslog.ijs".  "sym2ijs" cleans up
its tempory files and Voila!  Our J API is finished.

Now have a look at the resulting script "syslog.ijs".

Because the C compiler uses the header file, the appropriate actual values
are interpolated.  The ".ijs" is only valid on the the platform/OS on
which "sym2ijs" was run.  The ".sym" source is portable.  Also portable
are J scripts which "require 'syslog'" and use the functions and symbols.
After all, this is overall goal of the "sym2ijs" tool: liberating J
scripts from system-dependent, hardwired constants.

For example, this test program should run on your platform, too:

	script <'syslog.ijs'
	openlog 'testing' ; (LOG_PERROR+LOG_PID) ; LOG_USER
	LOG_CRIT jsyslog 'hello world'

Do a "tail /var/log/messages" or whatever is appropriate
according to your syslog.conf(5) settings to see the log
entry.

That hasn't been very difficult, has it?  We are happy with our
syslog script, we invoke "make install" to move the syslog.ijs to
over to contrib/unix/main for production use.


** Where to go from here

Read the man page of sym2ijs which is distributed along with the program
in system/extras/util.  If you are curious about the temporary C program,
use "sym2ijs -k syslog.ijs" to keep source and binary.  If you are
extremely curious, have a look at the "sym2ijs" transmogrifier itself.
It is just a short shell/awk script -- shorter as its man page and much
shorter than this tutorial.

Another major job of "sym2ijs" is to make C structure types accessible
in J.  "sym2ijs" will transform structure/field names into corresponding
names for "memr/memw" accesses in J.  We didn't need this feature for
syslog, but it very important for any C API which uses structures.

System/main/unixsyms.sym is an example which deals with structures.
That file reflects just constants types defined in various Unix headers.
Other scripts such as regexp.ijs or jmf.ijs use these definitions and
provide the function defintions for the dll calls and elaborate wrapper
functions.  Historically, these scripts were riddled with hard-wired,
platform-specific, non-portable constants.  With all these constants
replaced by sym2ijs-derived names, the code and organisation is still
quite ugly, but it is now portable.

In contrast, our transformed syslog API is a shiny little gem.
The packaging of the dll functions along with the declarations of the
constants quite nice.  Having both in the same source simplifies things
by a long margin.  The code itself is also very clean: sym2ijs, mkapi,
and find_dll in concert achieve a lean and mean notation.  Baggage,
complications, and repititious replications stay out of our way.

Our local J system at Gaertner Datensystem has been modified to undertand
special source file / line number directives as employed between the
classic C preprocessor and the compiler proper.  With this extension, the
J system will even flag errors at the proper place in the .sym source --
and not the derived .ijs script.


**  Distributing your new syslog J API to te world

If you want to distribute this syslog J API  J code to the world at
large, you just distribute the portable "syslog.sym" source.  You tell
the receivers to run "sym2ijs" once, so they create their own derived
"syslog.ijs" on their own platform.  The J distribution comes with a
handy "Makefile" in $JLIB/system/main to make this extremely easy and
failsafe after updates.

Don't even try to distribute pre-compiled syslog.ijs files instead of you
.sym source.  You may think this would be a good service, but it is not,
for two reasons:

1: You may cough up the resources in your development lab to install
   ONE Linux system with J, ONE Solaris system with J,  and ONE BSD
   system with J.

   A pretty good coverage you may think.  But this is not so.  A Red
   Hat Linux system may very well have different C headers than a SuSE
   Linux system.   And a SuSE-x.y release may very well define different
   "constants" than their next release.  The troubles with not striclty
   upwards compatible versions of the GNU "standard" C library alone
   are legion.

   Can you equip your development lab with the 12 most-used Linux
   distributions each in say, thee major releases?  No way, right?

2: If somebody needs to fix a bug in your J API or has an improvement
   for it, s/he absolutely wants to do that in the real source.
   Nobody wants to wade through the thirty-three automatically ceated
   assignments for the constants in syslog.ijs.  It is not only drudgery
   to apply changes this generated file.  Any such improved file could
   not be redistrubted to the world at large -- because the syslog.ijs is
   system-dependent.  In addition, such change would be futile, because
   the modification would be overwritten as soon as new "official"
   version is distributed.

   And we, as the authors of the .sym source want to get patches to
   exactly this file.  Therefore:

Do everybody including yourself a favour and distribute the .sym source.
