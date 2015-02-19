NB. argscan:  tools for ARGV scanning (command line options & parameters).

coclass 'z'

NB.* argscan v -- scan ARGV for options and arguments.
NB. ARGV is scanned for initial option strings (indicated by a leading "-")
NB. and associated parameters.  The encountered flag and parameter options
NB. are remembered (for later enquiry through the "flags" verb), and the
NB. remaining arguments are returned.
NB. An argument consisting of '--' will stop option processing immediately
NB. and take _anything_ remaining as non-option arguments.
NB.
NB. format: (flag options;parameter options) argscan ARGV

argscan =: dyad define
	'flags parms' =. 2{. (boxopen x.),<''
	argv =. y.

	FLAGS =:''
	PARMS =: 0 2 $ a:
	unknowns =. ''

	while. #argv do.
		NB. Let's peek at the first argument:
		this =. >{. argv

		NB. Quit option processing on a non-option ...
		if. '-' ~: 1 {. this do. NB. (possible overtake)
			break.
		end.

		NB. ... or the end-of-options option:
		if. this -: '--' do.
			argv =. }. argv
			break.
		end.

		NB. We have an option.
		NB. Strip the initial '-', collect used options
		NB. as well as illegal, undeclared options:
		argv =. }. argv
		FLAGS =: FLAGS, this =. }. this
		if. # unknowns =. this -. flags,parms do.
			stderr 'unknown options: ',unknowns,LF
		end.

		NB. register parameters with their flags:
		parflags =. this (e. # [) parms
		if. parflags >&# argv  do.
			stderr 'ran out of parameters for -',parflags,LF
		end.
		PARMS =: PARMS ,  parflags ;"0 0 (#parflags) {. argv
		argv =. (#parflags) }. argv
	end.
	argv
)

NB.* arg_val v -- return the value of a parameter option
NB. format:  (default) arg_val option_letter
arg_val =: verb define
	_. arg_val y.
:
	where =. ({."1 PARMS) i. <y.
	> where { ({:"1 PARMS), <x.
)
