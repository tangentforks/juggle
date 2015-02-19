NB. package utilities
NB.
NB. a package is a 2-column matrix of:  name, value
NB. that can be used to store nouns, or otherwise
NB. associate names and values.
NB.
NB. A "name" is any character vector. pack and pdef work
NB. only when the names are proper J names.
NB.
NB. definitions for nouns only:
NB.   pk=.       pack nl         create package from namelist
NB.   nl=.  [nl] pdef pk         define [namelist from] package
NB.
NB. definitions for any names:
NB.   text=. pk1  pcompare pk2   compare packages
NB.   val=.  name pget pk        get value of name in package
NB.   pk=.   new  pset old       merge new and old packages

NB. ========================================================
NB.*pack v package namelist
NB.
NB. form:  pack 'one two three'
NB.        pack 'one';'two';'three'
pack=: [: /:~ [: (, ,&< ".) &> ;:^:(L. = 0:)

NB. ========================================================
NB.*pdef v package define
NB. form: [nl] pdef pk         if nl not given, define all
pdef=: 3 : 0
if. 0 e. $y. do. empty'' return. end.
names=. {."1 y.
if. #names do. (names)=: {:"1 y. end.
names
:
names=. {."1 y.
nl=. ;:^:(L. = 0:) x.
pdef (names e. nl)#y.
)

NB. ========================================================
NB.*pcompare v compare two packages
NB. form: pk1 pcompare pk2
pcompare=: 4 : 0
n0=. {."1 x. -. y.
n1=. {."1 x.
n2=. {."1 y.
list=. ;:^:_1
r=. ''
r=. r,(*#d)#LF,'not in 1: ',list d=. n2 -. n1
r=. r,(*#d)#LF,'not in 2: ',list d=. n1 -. n2
r=. r,(*#n)#LF,'not same in both: ',list n=. n0 -. d
}.r,(0=#r)#LF,'no difference'
)

NB. ========================================================
NB.*pget v return value of name in package
NB. form: name pget pk        - return value of name in package
pget=: 4 : '> {: y. {~ ({."1 y.) i. {. boxopen,x.'

NB. ========================================================
NB.*pset v merge new into old
NB. form: new pset old
NB. result has values in new, plus any values in old that
NB. were not replaced in new
pset=: (#~ [: ~: {."1) @ ,