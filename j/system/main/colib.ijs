NB. class/object library
NB.
NB. main verbs:
NB. conl           return co name list
NB. copath         set/get co path
NB. cocreate       create object
NB. cocurrent      set current locale
NB. coname         return current co name
NB. coerase        erase object
NB.
NB. utility verbs:
NB. coclass        set co class
NB. codestroy      destroy current object
NB. coextend       add class locale to path (before z)
NB. coinfo         return info on co classes
NB. conames        formatted co name list
NB. conew          create object
NB. conouns        nouns referencing object
NB. conounsx       object references with locales
NB. copathnl       path name list
NB. copathnlx      formatted path name list with defining classes
NB. corequire      load class if not already loaded
NB. coreset        destroy all object locales
NB. costate        state of class objects

NB. =========================================================
NB.*conl v return co name list
NB. form: conl n
NB.   0 e. n  = return named locales
NB.   1 e. n  = return numbered locales
NB.   conl '' = return both, same as conl 0 1
conl=: 18!:1 @ (, 0 1"_ #~ # = 0:)

NB. =========================================================
NB.*copath v set/get co path
copath=: 18!:2 & boxxopen

NB. =========================================================
NB.*cocreate v create object
cocreate=: 18!:3

NB. =========================================================
NB.*cocurrent v set current locale
cocurrent=: 18!:4 & boxopen

NB. =========================================================
NB.*coname v return current co name
coname=: 18!:5

NB. =========================================================
NB.*coerase v erase object
NB. example: coerase <'jzplot'
coerase=: 18!:55

NB. =========================================================
NB.*coclass v set current co class
coclass=: 3 : 0
18!:4 <y.
COCLASSPATH=: y.;'z'
)

NB. =========================================================
NB.*codestroy v destroy current object
codestroy=: coerase @ coname

NB. =========================================================
NB.*coextend v add class locale to path (before z)
coextend=: 3 : 0
c=. boxxopen y.
COCLASSPATH=: (}:COCLASSPATH),COCLASSPATH__c
)

NB. =========================================================
NB.*coinfo v return info on co classes
NB. returns noun refs;object;creator;path
coinfo=: 3 : 0
ref=. boxxopen y.
if. 0 e. $ref do. i.0 4 return. end.
if. 0=4!:0 <'COCREATOR__ref'
do. c=. COCREATOR__ref else. c=. a: end.
(conouns ref),ref,c,< ;:inverse copath ref
)

NB. =========================================================
NB.*conames v formatted co name list
conames=: list_z_ @ conl

NB. =========================================================
NB.*conew v create object
conew=: 3 : 0
c=. <y.
obj=. cocreate''
COCLASSPATH__c copath obj
COCREATOR__obj=: coname''
obj
:
w=. conew y.
create__w x.
w
)

NB. =========================================================
NB.*conouns v nouns referencing object
conouns=: 3 : 0 "0
n=. nl 0
t=. n#~ (<y.)-:&> ".each n
< ;: inverse t
)

NB. =========================================================
NB.*conounsx v object references with locales
NB. returns: object;references;locales
conounsx=: 3 : 0
r=. ''
if. #y. do.
  s=. #y=. boxxopen y.
  loc=. conl 0
  for_i. loc do. r=. r,conouns__i y end.
  r=. (r~:a:) # (y$~#r),.r,.s#loc
end.
/:~~.r
)

NB. =========================================================
NB.*copathnl v path name list
NB. path name list
copathnl=: ''&$: : (4 : 0)
r=. ''
t=. (coname''),copath coname''
for_i. t -. <,'z' do.
  r=. r,x. nl__i y.
end.
/:~~.r
)

NB. =========================================================
NB.*copathnlx v formatted path name list with defining classes
copathnlx=: ''&$: : (4 : 0)
r=. ''
t=. (coname''),copath coname''
for_i. t=. t -. <,'z' do.
  r=. r,<x. nl__i y.
end.
n=. ~.;r
n,.|:( n&e. &> r) #each t
)

NB. =========================================================
NB.*corequire v load class if not already loaded
corequire=: 3 : 0
y=. boxxopen y.
if. -. y e. conl 0 do. load y end.
)

NB. =========================================================
NB.*coreset v destroy all object locales
coreset=: coerase @ conl @ 1:

NB. =========================================================
NB.*costate v state of class objects
costate=: 3 : 0
r=. ,: ;:'refs id creator path'
if. #n=. conl 1 do. r,coinfo &> n end.
)
