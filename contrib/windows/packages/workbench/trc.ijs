NB. trace facilities

NB. All output is routed through WRITE.
NB. Feel free to overwrite this with different
NB. verbs if you need to.
NB. WRITE is called with possibly empty arrays,
NB. so far all character.
NB. You have to do your own CR/LF'ing if you want to
NB. supply you own line breaks.
WRITE =: 1!:2&2

NB. level_prefix =: ,(<0 _2) { 9!:6 ''  NB. vertical bar
level_prefix =: ,'|'

ranktext =: >@({ & (;:'scalar vector matrix')) :: (": , '-dimensional array'"_)
heterogeneous =: 1: < #@~.

shrinkhead =: (0: >. [: <: [ <. #@]) {. ]
shrinkmid  =: (([ <  #@]) , }.@$@]) $ (<'...')"_
shrinktail =: -@*@#@] {. ]
shrink =: shrinkhead , shrinkmid , shrinktail

warnshape =: 3 : 0
	'something here' warnshape y.
:
	if. 1 0 +./ . e. y. do.
		'Notice: ', x., ' is really a ', (ranktext #y.), ' (with shape ', (":y.), ')'
	else.
		0 0 $''
	end.
)


recombi_analysisly =: 1 : 0
	write=.u.
	rcells=.y.
	heterogeneous =. heterogeneous_trc_
    rshapes =. $&.> rcells
	rtypes =. 'ncnnnb' {~ 2&^. @ (3!:0) @ > rcells

	NB. write 'type: ',,rtypes
	if. heterogeneous rtypes do.
		write 'Uh-oh, trouble ahead.  partial results are'
		write 'of incompatible types, for example:'
		write (~: rtypes) # rcells
	end.

	if. heterogeneous rshapes do.
		write 'Notice: result recombination gets tricky.'

		write '   samples for temporary results with different shapes:'
		write  (~: rshapes) # rcells

		todo =. ,:'   According to the Dictionary, II.B,'  NB. gathers comments
		if. heterogeneous rranks =. #@> rshapes do.
			write '   samples for different ranks:'
			write (ranktext@#@$@> ; ])"0   (~: rranks) # rcells
			todo=.todo, '   leading axes will be added where necessary'
		else.
			write '   every intermediate result is a ', ranktext #@>@{. rshapes
		end.

		NB. the following simplification misses some cases (eg. 2 4 vs 2 4 shapes)
		NB. but never shows the warning wrong when not justified.

		if. heterogeneous */@> rshapes do.
			todo=.todo, '   some filling with blanks or zeros will occur'
		end.
		write todo
	end.
	0 0 $''
)

NB.  u tc n
NB.  The conjunction tc derives a "traced verb" from u.
NB.  u tc n is ambivalent.
NB.
NB.  n can be a simple string, selecting trace features with letters:
NB.  a - args
NB.  r - result
NB.  o - one-liner with a and r
NB.  s - shape watcher
NB.  A - agreement style
NB.  p - cell arguments (arg pairs) shortened
NB.  P - cell arguments (rag pairs) full
NB.  t - table of arg cells & results, shortened
NB.  T - table of arg cells & results, full
NB.  R - result combination
NB.
NB.  L - print level indication
NB.  U - print u indication
NB.  C - print using compact representations (just planned)

NB.  Feature 'L' uses and maintains a growing and shrinking
NB.  prefix string in the global variable level_prefix.

tc =: 2 : 0
	options =. n.
	opt =. (+./ . e.) &options

	warnshape =. warnshape_trc_
	ranktext =. ranktext_trc_
	shrink =. shrink_trc_
	recombi_analysisly =. recombi_analysisly_trc_

	urep =. 5!:5 <'u.'
	if. 13<#urep do.
		urep =. (5{.urep), '...', _5{.urep
	end.

	pfx =. ''  NB. extend based on options.

	if. opt 'L' do.
		NB. reverse at end!
		level_prefix_trc_ =: level_prefix_trc_ , ({~ ?@#) '|!:I#>*;[]'
		pfx =. pfx, level_prefix_trc_, ' '
	end.

	if. opt 'U' do.
		pfx =. pfx, '  ', 13 {. urep, '  '
	end.

	w =. WRITE_trc_
	if. opt 'UL' do.
		write =. w @: (pfx&,"1) @: ":
	else.
		write =. w
	end.

	if. 0 = nc <'u.' do.
		write u.
		write 'sorry, cannot continue after tracing a left argument.'
		write 'trace verbs, adverbs, and conjunctions, but not nouns.'
		level_prefix_trc_ =: }: level_prefix_trc_
		level_prefix_trc_ =: }: level_prefix_trc_
		'tracer nonce error' 13!:8 ]10
	end.

	um =. uranks =. {. u. b. 0

	if. 0 do.
		write 'verb is: ', urep, ' (', (": uranks), ')'
		write '   y is: ', 5!:5 <'y.'
	end.

	if. opt 'a' do.
		write urep ; ": y.
	end.

	if. opt 's' do.
		write 'y' warnshape $y.
	end.

	cellu =. u.&.> @< "u.
	argpairs =. < "u.

	if. opt 'pP' do.
		write 'Argument cells:'
		ap =. argpairs y.
		write 3&shrink ^: (opt 'p') ap
	end.

	try.
		rcells =. cellu y.
	catch.
		t =. 'Execution of ', urep, ' failed: '
		write t, (>:@(13!:11) >@{ 9!:8) ''
		if. opt 'L' do.
			level_prefix_trc_ =: }:level_prefix_trc_
		end.
		13!:8 ] 13!:11 ''
	end.

	if. opt 'tT' do.
		write 'Argument cells and their results:'
		ap =.  (argpairs y.) ,"0 0 rcells
		write  3&shrink ^: (opt 't') ap
	end.

	try.
		if. opt 'R' do.
			write f. recombi_analysisly rcells
		end.
		NB. r =. u. y.
		r =. > rcells
	catch.
		t =. 'Intermediate results are not of same type.'
		write t
		if. opt 'L' do.
			level_prefix_trc_ =: }:level_prefix_trc_
		end.
		13!:8 ] 13!:11 ''
	end.

	if. opt 'o' do.
		write 1 1 ": urep ; y.; 'is' ,&< r
	end.

	if. opt 'r' do.
		write r
	end.

	if. opt 's' do.
		write 'result' warnshape $r
	end.

	if. opt 'L' do.
		level_prefix_trc_ =: }:level_prefix_trc_
	end.
	r
NB. ::::::::::::::::::::::::::::::::::::::::::::::::::
:
NB. ::::::::::::::::::::::::::::::::::::::::::::::::::
	options =. n.
	opt =. (+./ . e.) &options

	warnshape =. warnshape_trc_
	ranktext =. ranktext_trc_
	shrink =. shrink_trc_
	recombi_analysisly =. recombi_analysisly_trc_

	urep =. 5!:5 <'u.'
	if. 13<#urep do.
		urep =. (5{.urep), '...', _5{.urep
	end.

	pfx =. ''  NB. extend based on options.

	if. opt 'L' do.
		NB. reverse at end!
		level_prefix_trc_ =: level_prefix_trc_ , ({~ ?@#) '|!:I#>*;[]'
		pfx =. pfx, level_prefix_trc_, ' '
	end.

	if. opt 'U' do.
		pfx =. pfx, '  ', 13 {. urep, '  '
	end.

	w =. WRITE_trc_
	if. opt 'UL' do.
		write =. w @: (pfx&,"1) @: ":
	else.
		write =. w f.
	end.

	if. 0 = nc <'u.' do.
		write u.
		write 'sorry, cannot continue after tracing a left argument.'
		write 'trace verbs, adverbs, and conjunctions, but not nouns.'
		level_prefix_trc_ =: }: level_prefix_trc_
		'tracer nonce error' 13!:8 ]10
	end.

	(;:'ul ur') =. uranks =. }. u. b. 0

	if. 0 do.
		write 'verb is: ', urep, ' (', (": uranks), ')'
		write '   x is: ', 5!:5 <'x.'
		write '   y is: ', 5!:5 <'y.'
	end.

	if. opt 'a' do.
		write (":x.) ; urep ; ": y.
	end.

	if. opt 's' do.
		write 'x' warnshape $x.
		write 'y' warnshape $y.
	end.


	xfr =. ul fr_rank_ x.
	yfr =. ur fr_rank_ y.
	prf =. xfr <.&# yfr
	if. -. xfr -:&(prf&{.) yfr do.
		write 'Uh-oh.  It''s impossible to pair the arguments.'
		write (":xfr), ' is the left frame,'
		write (":yfr), ' is the right frame.'
		write 'There is no "prefix agreement" (see Dictionary, II.B)'
		if. opt 'L' do.
			level_prefix_trc_ =: }:level_prefix_trc_
		end.
		NB. raise length error
		13!:8 (9)
	end.
		
	remaining =. prf }. xfr [^:(>&#) yfr
    if. opt 'A' do.
		if.  0=#xfr,yfr do.
			t=.'trivially, cell to cell'
		elseif.      0=#yfr do.
			t=.'distributively, many-to-one'
		elseif.      0=#xfr do.
			t=.'distributively, one-to-many'
		elseif.  xfr -: yfr do.
			t=.'correspondently, one-to-one'
		elseif.	1 do.
			t=.'with correspondencies and distributions'
		end.
		write 'Cells are paired ', t, '.'
		if. 'w'={.t do.
			(;:'big small') =. |.^:(prf=#yfr) 'xy'
			t=.'Each cell from ', small,' gets distributed'
			write t, ' over each ', (ranktext #remaining), ' of ', big, '-cells'
		end.
	end.

	cellu =. u.&.> &< "u.
	argpairs =. ,&< "u.

	if. opt 'pP' do.
		write 'Pairings of argument cells:'
		ap =. x. argpairs y.
		write 3&shrink_trc_ ^: (opt 'p') ap
	end.

	try.
		rcells =. x. cellu y.
	catch.
		t =. 'Execution of ', urep, ' failed: '
		NB. write t, (e=.>:@(13!:11) >@{ 9!:8) ''
		write t=.t, > (e=.<: 13!:11'') { 9!:8''
		if. opt 'L' do.
			level_prefix_trc_ =: }:level_prefix_trc_
		end.
		(t) 13!:8 e-1
	end.

	if. opt 'tT' do.
		write 'Paired argument cells and their results:'
		ap =.  ( x. argpairs y.) ,"1 0 rcells
		write  3&shrink ^: (opt 't') ap
	end.

	try.
		if. opt 'R' do.
			write f. recombi_analysisly rcells
		end.
		NB. r =. x. u. y.
		r =. > rcells
	catch.
		t =. 'Intermediate results are not of same type.'
		write t
		if. opt 'L' do.
			level_prefix_trc_ =: }:level_prefix_trc_
		end.
		13!:8 ] 13!:11 ''
	end.

	if. opt 'o' do.
		write 1 1 ": x. ; urep ; y.; 'is' ,&< r
	end.

	if. opt 'r' do.
		write r
	end.

	if. opt 's' do.
		write 'result' warnshape $r
	end.

	if. opt 'L' do.
		level_prefix_trc_ =: }:level_prefix_trc_
	end.
	r
)

trc =: tc_trc_  'LarsARp'
NB.  > trc 'a';'bc';'def'

trc_z_ =: trc_trc_
tc_z_ =: tc_trc_

gtc =: 3 : 0
	'rtrc' gtc y.
:
	urep =. ;: y.
	unew =. ''
	while. #urep do.
		bx =. {. urep
		try.
			bx\
			unew =. unew, '(', (>bx), ' ', x.,')'
		catch.
			unew =. unew, >bx
		end.
		urep=. }.urep
	end.
	unew
)
gtc_z_ =: gtc_trc_

NB. gtc '(- *)'

rtrc =: 1 : 'u. tc''Los'' " u.'
