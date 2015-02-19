EDITOR_j_=: 'vi'

NB. edit files:   e 'foo.ijs'   later just:  e''
e_z_ =: verb define
	0 e_z_ y.
:
	if. #y. do.
		LAST_FILE_j_=:y.
	end.
	2!:1 EDITOR_j_,' ',LAST_FILE_j_
	if. x. do.
		<LAST_FILE_j_
	else.
		0 0 $ ''
	end.
)

NB. edit & run files:    r 'foo.ijs'   later just:  r''
r_z_ =: 0!:0 @ (1&e_z_)
