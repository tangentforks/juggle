NB. [chunkname] loadnw filename
NB. *loads a node from a noweb file.
loadnw_z_ =: verb define
	'*' loadnw y.
:
	0!:100 (2!:0) 'notangle -t8 ''-R', x., ''' -filter emptydefn ', y.
)
