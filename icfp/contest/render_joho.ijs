NB. Render Prototype
NB. ! To make this work add the argument given to pop below to the
NB. definition of render in operatorlist in  parser.ijs (I didn't want to cause version conflicts in the last moment)
NB.  runs with /gml/mini_render.gml (modified args of render to make shure it would work)

coclass 'z'

render=: verb define
	tmp=. pop STACK_TYPE_ARRAY,STACK_TYPE_ARRAY,STACK_TYPE_INTEGER,STACK_TYPE_INTEGER,STACK_TYPE_FLOAT,STACK_TYPE_INTEGER,STACK_TYPE_INTEGER, STACK_TYPE_STRING
	'amb lights obj depth fov wid ht file'=. ({:)"1 tmp
	'P6'fappends file
	'# juggle-icfp potemkin PPM file' fappends file
	(":wid,ht)fappends file
	'255' fappends file
	((*/3,wid,ht)#'J')fappend file
	file
)
