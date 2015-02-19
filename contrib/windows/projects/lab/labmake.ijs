NB. make lab system

require 'files'
'j' load 'user\main\fileutil.ijs'

cocurrent 'j'

f=. 'source\main\labs\' & , @ (, & '.ijs')

LABFNS=: f each <;._2 (0 : 0)
labutil
labfiles
labini
labjmp
labrtf
labsel
labwin
)

LATFNS=: f each <;._2 (0 : 0)
labini
labutil
latinit
latfns
latcfg
latchap
latsel
latfont
latorder
latinsnd
latrecnt
latsnd
latwin
latprop
)


coerase <'jlab'
coerase <'jlabauthor'

'system\extras\labs\labdir.ijs' fncopy 'source\main\labs\labdir.ijs'
'system\extras\labs\labs.txt' fncopy 'source\main\labs\labs.txt'

t1=. 'temp\t42.ijs'
t2=. 'temp\t43.ijs'

t1 scriptmake LABFNS
dat=. freads t1
dat=. 'require ''dir files kfiles regex text''',LF,dat
dat=. 'coclass ''jlab''',LF,dat
dat fwrites t1

t2 scriptmake LATFNS
dat=. freads t2
dat=. 'require ''print''',LF,dat
dat=. 'coclass ''jlabauthor''',LF,dat
dat fwrites t2

fsqz t1
fsqz t2

'system\extras\util\lab.ijs' fncopy t1
'system\extras\util\lauthor.ijs' fncopy t2
