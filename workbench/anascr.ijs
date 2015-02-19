NB. scanning and analysis of scripts

ww =: 1!:2&2

require 'strings'

v=:"_
lfend =: ,&LF`]@.(_1&{. -: (,LF)v)

onlines =: (;._2) @ lfend @ toJ
anascript =: analine onlines
esmp =: 3 : 0
	11
	12
	13
:
	21
	22
)

arr =. i. 3 3

NB. a few predicates:
is_comment =: 'NB.'v -: 3: {. ;@;:
is_clopar  =: -:&(,')')
is_glo =: +./ @ ('=:'&E.)
is_loc =: +./ @ ('=.'&E.)
NB. is_scr_start =: ' :0'&E. +.&(+./) ' : 0'&E.
is_scr_start =: +./@(*./)@(0 1&(|."0 1))@:((;:': 0')v ="0 _ ;:)

analine =: #. @ (is_comment , is_scr_start , is_clopar , is_glo, is_loc)
dispflags =: (_5:{.#:) # 'cs):.'v

script_blocks =:  <;.2~ 1&(_1})@(_2&|.)@((LF,')',LF)&E.)
start_stop =: (is_scr_start +. is_clopar)onlines # <onlines

NB. strip leading blanks and the very last LF from definitions
defclean =: +/@(*./\)@:(' '&=)  }. }:

NB. read a script file and
NB. convert it into chunks.
NB. For each chunk, we return
NB. a tripel
NB. - introductory comments
NB. - name
NB. - definition text.
NB.
NB. Consecutive external comments
NB. are run together.

read_script=: 3 : 0
	scr =. lfend y.
	ll =. #;.2 scr
	offsets =. 0, }: +/\ll
	li =. offsets ,. ll
	i=.0
	WHITE =. 9 10 11 12 13 32 { a.
	deflist =. 0 3 $ a:
	nm=.cmts=.def=.''
	while. i<#li do.
		line=. ((+i.)/ i{li) { scr
		i=.>:i

		NB. collect any comments
		if. is_comment line do.
			cmts =. cmts, 'NB.' takeafter line
			continue.
		end.

		NB. first comment goes separate, even if it's empty
		if. 0 = #deflist do.
			deflist=.deflist, nm;cmts; defclean def
			nm=.cmts=.def=.''
		end.

		if. *./ line e. WHITE do. continue. end.

		if. -. (is_loc +. is_glo) line do.
			deflist =. deflist, nm;cmts;defclean line
			nm=.cmts=.def=.''
			continue.
		end.

		NB. assignment
		nm =. >{.;:line
		def =. }. '=' takeafter line
		if. is_scr_start line do.
			whilst. ')' ~: {.line do.
				line=. (({. + i.@{:)i{li) { scr
				i=.>:i
				def =. def,line
			end.
		end.
		deflist =. deflist, nm;cmts;defclean def
		nm=.cmts=.def=.''
	end.
	deflist
)

fmt_triple =: 3 : 0
	'n c d' =. y.
	t=.''
	spcline =. (LF e. _2}.d) # LF

	if. #c do.
		t =. t, (; <@('NB. '&,) ;.2 lfend c), spcline
	end.
	if. # n do. t=.t,n,' =: ' end.
	t=.t,d,LF,spcline
	t
)

NB. Merge chunks into a script.
NB. For each chunk, we have
NB. - introductory comments
NB. - name
NB. - definition text.
NB. We keep the existing script as is
NB. but replace all definitions we have
NB. a corresponding chunk for.
NB. All unused chunks go to the end
NB. of the script.
NB. chunks merge_script oldscript

merge_script =: 4 : 0
	chunks =. x.
	scr =. lfend y.
	ll =. #;.2 scr
	offsets =. 0, }: +/\ll
	li =. offsets ,. ll
	i=.0
	WHITE =. 9 10 11 12 13 32 { a.
	newscript=.''
	deflist =. 0 3 $ a:
	nm=.cmts=.def=.''
	while. i<#li do.
		line=. (({. + i.@{:)i{li) { scr
		i=.>:i

		NB. collect any comments
		if. is_comment line do.
			cmts =. cmts, 'NB.' takeafter line
			continue.
		end.

		NB. first comment goes separate
		if. 0 = #deflist do.
			deflist=.deflist, nm;cmts;def
			newscript =. newscript,fmt_triple nm;cmts;def
			nm=.cmts=.def=.''
			continue.
		end.

		if. *./ line e. WHITE do.
			newscript=.newscript,LF
			continue.
		end.

		if. -. (is_loc +. is_glo) line do.
			deflist =. deflist, nm;cmts;line
			newscript =. newscript,fmt_triple nm;cmts;def
			nm=.cmts=.def=.''
			continue.
		end.

		NB. assignment
		nm =. >{.;:line
		def =. }. '=' takeafter line
		if. is_scr_start line do.
			whilst. ')' ~: {.line do.
				line=. (({. + i.@{:)i{li) { scr
				i=.>:i
				def =. def,line
			end.
		end.
		ww 'found "',nm,'" in old script'
		deflist =. deflist, nm;cmts;def
		if. (idx =. ({."1 chunks) i. <nm) < #chunks do.
			ww 'in new script, too',LF
			newscript =. newscript,fmt_triple idx{chunks
			chunks =. (<<<idx) {chunks
		end.
		nm=.cmts=.def=.''
	end.

	ww 'Remaining chunks:'
	ww >{."1 chunks
	newscript =. newscript, ; <@fmt_triple"1 chunks
	newscript
)
