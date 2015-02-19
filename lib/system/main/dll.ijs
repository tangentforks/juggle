NB. utilities for calling DLLs (dynamic link libraries)

NB.*cd   v call DLL procedure
cd=: 15!:0

NB.*memr v memory read
NB.*memw v memory write
NB.*mema v memory allocate
NB.*memf v memory free
memr=: 15!:1
memw=: 15!:2
mema=: 15!:3
memf=: 15!:4

NB.*cdf v free DLLs
NB.*cder v error information
NB.*cderx v GetLastError information
cdf=: 15!:5
cder=: 15!:10
cderx=: 15!:11

NB.*gh v allocate header
NB.*fh v free header
NB.*symget v get address of locale entry for name
NB.*symget v set array as address
gh =. 15!:8
fh =. 15!:9
symget =: 15!:6
symset =: 15!:7

JB01  =: 1
JCHAR =: 2
JSTR  =: _1,JCHAR
JINT  =: 4
JPTR  =: JINT
JFL   =: 8
JCMPX =: 16
JBOXED=: 32
JTYPES=: JB01,JCHAR,JINT,JPTR,JFL,JCMPX,JBOXED
JSIZES=: 1   ,1    ,4   ,4   ,8  ,16   ,4

NB.*ic   v integer conversion
NB. conversions
NB. e.g.
NB.    25185 25699  =  _1 ic 'abcd'
NB.    'abcd'  =  1 ic _1 ic 'abcd'
NB.    1684234849 1751606885  = _2 ic 'abcdefgh'
NB.    'abcdefgh'  =  2 ic _2 ic 'abcdefgh'
ic=: 3!:4

NB.*fc   v float conversion
fc=: 3!:5

NB.*bitwise a bitwise operations
NB. (monadic and dyadic)
NB. e.g.  7  =  1 OR 2 OR 4
NB.          =  OR 1 2 4
bitwise=. 1 : '[: x./&.#: ,'

NB.*AND  v bitwise AND (&)
NB.*OR   v bitwise OR  (|)
NB.*XOR  v bitwise XOR (^)
AND=: *. bitwise
OR=:  +. bitwise
XOR=: ~: bitwise

NB.*mkapi	v define J functions corresponding to shared lib functions.
NB. (dyadic)
NB. e.g.  '/usr/lib/libc.so' mkapi 'strcmp i *c *c;strncmp i i *c *c;'
NB. The prototype vector is cut using the final character. More often:
NB. '/usr/lib/libc.so' mkapi noun define
NB. strcmp i *c *c
NB. strncmp i i *c *c
NB. )
NB. Also nice to know: mkapi_locname_ will create the functions in that locale.
mkapi =: dyad define
	'lib prototypes' =. x. ; y.

	NB. Determine whether we need to prepend an underscore
	NB. or not.  This is currently dependent on both the
	NB. Unix platform and the J release.
	NB. Actually, J should do this properly internally, but there
	NB. are still some old versions in use which require this to be
	NB. here.
	NB. Starting with release J4.05, 15!:0 on all Unix platforms expects
	NB. the function name without any initial underscore.
	cd_needs_bar =. 0
	version =. ". (#~ *./\@(e.&'0123456789.'))  9!:14''
	if. (5 = 9!:12'') *. version < 4.05 do.
		cd_needs_bar =. (<}: 2!:0 'uname') e. ;:'SunOS NetBSD'
	end.

	for_line. <;._2 prototypes do.
		name=.>{.;:>line
		(name) =: (lib, ((>:cd_needs_bar) {. ' _'), >line)&cd
	end.
	i. 0 0
)

NB. *DLL_PATH      n standard library load path.
NB. initialized from a standard UNIX environment variable
NB. or, otherwise, from a sensible default.
3 : 0 ''
	NB. On many systems, LD_LIBRARY_PATH works as an add-on to
	NB. to a default system library path.  If we don't find '/lib'
	NB. in it, we regard it as an extension and add some default
	NB. library path.  Any replicated dirs will be expunged by
	NB. the final Nub.
	def_path =. '/usr/local/lib:/usr/lib:/usr/lib/ccs/lib:/etc/lib:/lib'
	DLL_PATH =: (2!:5 'LD_LIBRARY_PATH') 
	if. 0-:DLL_PATH do.
		DLL_PATH=:def_path
	elseif. -. +./ '/usr/lib' E. DLL_PATH do.
		DLL_PATH=:DLL_PATH,':',def_path
	end.
	DLL_PATH =: ~. (<;._1~ =&':') ':',DLL_PATH
)


NB. *uname          n the current general platform id.
NB. We need to know this because some things are really system-dependent
uname =: }: 2!:0 'uname'

NB. *find_dll   v locate a shared library in (standard) directories.
NB. (monadic and dyadic)
NB. e.g.   find_dll 'X11'
NB.        (find_dll 'c') mkapi 'strcmp i *c *c;'
find_dll =: verb define
	DLL_PATH find_dll y.
:
	NB. turn scalar lib names (as 'c') into singleton strings to be safe:
	y.=. ,y.
	if. (uname -: 'Linux') *. (y. -: ,'c') do.
		NB. The Linux /lib/libc.so happens to be a special
		NB. linker directive file, not a lib suitable for
		NB. dlopen.  For now, provide a crude hack to
		NB. patch this oh so common problem case.
		'/lib/libc.so.6' return.
	end.
	for_dir. x. do.
		l=. (>dir), '/lib', y., '.so*'
		NB. the sort will prefer the highest version number:
		if. # fns =. \:~ 1!:0 l do.
			(>dir), '/', > (<0 0) { fns
			return.
		end.
	end.
	('could not locate dll ',y.) 13!:8 ] 24
)

NB. *force_dll_load   v make sure that a dll is loaded.
NB. (monadic)
NB. e.g.      force_dll_load find_dll 'X11'
NB.           before you trigger any Tk stuff, in particular when
NB.           nobody told you about a harmless X11 routine like
NB.           XiDisplayName which would be helpful to get things going.
NB. This is a crude implementation but does the job.
force_dll_load=:monad define
	(y.,' n j_wants_you') cd :: 0: ''
	i. 0 0
)

NB. Because every work with library functions and system calls
NB. will trigger errors sooner or later, allow to show errno type
NB. values nicely:

(find_dll 'c') mkapi_syscalls_ noun define
strerror *c i
perror n *c
)

strerror =: monad define
	txt =. 0 pick strerror_syscalls_ y.
	memr txt,0,JSTR
)
perror =: monad define
	perror_syscalls_ <y.
	i. 0 0
)

cder_texts=: <;._2 noun define
check cderx (15!:11)
file not found
procedure not found
too many DLLs loaded 
parameter count does not match declarations
declaration invalid
parameter type does not match declaration
)
cderr =: monad define
  errorclass =. {. errorcode =. cder''
  smoutput errorcode; ({errorclass){cder_texts
  if. errorclass = 0 do.
	smoutput cderx''
  end.
  i. 0 0
)
