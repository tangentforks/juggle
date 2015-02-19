LOWERCASE =: 'abcdefghijklmnopqrstuvwxyz'
UPPERCASE =: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
DIGITS =: '0123456789'
WHITE =: 9 10 12 13 32 { a.
LETTERS =: UPPERCASE,LOWERCASE
ALNUM =: LETTERS,DIGITS

is_idchar =: e.&(ALNUM,'_')

id_stretch =: bk_stretch , fw_stretch
  fw_stretch =: id_extent @ }.
  bk_stretch =: (id_extent&.|.) @ {.
    extent =: *./\@]: # ]
	id_extent =: is_idchar extent