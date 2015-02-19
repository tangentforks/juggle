NB. fields.ijs
NB.
NB. Record types as known from many other programming
NB. languages are easy to emulate in J using boxed lists.
NB.
NB. The verb mkfields creates symbolic field indexes and access
NB. functions. The advantages of symbolic
NB. field references are of course better readability (as
NB. opposed to numeric indixes) and enhanced robustness
NB. in the case of program changes.
NB.
NB. The verb mkfields creates a set of names to access boxed lists,
NB. for example:
NB.
NB.    'DAT' mkfields 'name pos wd'
NB.
NB. If you wish, run mkfields in a locale, to avoid cluttering
NB. the base namespace.
NB.
NB. mkfields creates pairs of get/set verbs for the fields, e.g.:
NB.    getDATname list          (1)
NB.    newval setDATname list   (_ 1)
NB.
NB. In addition, the following nouns are created:
NB.    emptyDAT   is an empty list of appropriate length.
NB.    fieldsDAT  is suitable to stitch names to the lists.
NB.
NB. plus index constants:
NB.    DATname =: 0
NB.    DATdob  =: 1
NB.    DATwd   =: 2
NB.
NB. Also, the conjunction fieldop is created:
NB.    DATpos fieldop verb   creates a monad transforming
NB.                          a specific list element

mkfields =: 3 : 0
:
NB.  create field indexes:
fields=. x.&,&.> ;:y.
(fields) =: i.#fields

NB.  Create access functions:
". (('g'&,) , ('=: >@('&,) , ('&{) "1' "_))      @ > fields
". (('s'&,) , ('=: (<@[ ('&,) , ('}) ])"_ 1'"_)) @ > fields

NB.  create remaining nouns:
". 'empty',x., '=: (#fields) # a: '
". 'fields',x.,'=: ;:y.'
)

fieldop =: ''& (].&.>@([.&{)@]`([."_)`]})"1
