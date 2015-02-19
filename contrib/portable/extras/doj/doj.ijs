require 'files regex format'

cocurrent 'dictionary'
DD=: JDIR_j_,'contrib/portable/extras/doj/'

strip_comments =: monad define
	(('^#.*',LF);'') rxrplc y.
)

txt=:strip_comments toJ fread DD,'part-II.txt'

entry_pat =: '^N'
section_pat =: '^[A-Z]'

entries=: <;.1~ entry_pat&rxE

ee=: > 1 { entries txt

format_name =: monad define
	, LF ,.~ '=' ,:~ }: 2 }. y.
)

format_text =: monad define
	fmt ; <@}. ;. 2 ] 2 }. y.
)

format_example =: monad define
	script =. format_text y.
	fn=. <'sample.log'
	fn 0!:110 script
	z=.fread fn
	ferase fn
	LF, 'Example:', LF, z, LF
)

original_text =: monad define
	y.
)

format_section =: monad define
	select. {. y.
	case. 'N' do. format_name y.
	case. 'T';'H' do. format_text y.
	case. 'E' do. format_example y.
	case. do. original_text y.
	end.
)

format_entry =: monad define
	; (section_pat rxE y.) <@format_section;.1 y.
)

fe=:format_entry ee
