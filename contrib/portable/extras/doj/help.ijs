cocurrent 'dictionary'

HD=:(1!:42''), 'contrib/portable/extras/doj/full.html'

h =: monad define
	NB. sanitize y.  ---  oops sanitizing destroys search for '18!:'
	NB. y.=.>{.;:y.
	2!:1 'lynx ''',HD,'#',y.,''''
	empty 1!:2&2 '[back to J]'
)

h_z_=:h_dictionary_
