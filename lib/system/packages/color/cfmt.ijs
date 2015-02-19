NB. color formatter
NB.
NB. form:  [colors] cfmt dat
NB.
NB. colors are integers from 0-7 as defined here
NB. dat is any numeric array

NB. define colors 0-7:
j=. ;:'BLACK BLUE GREEN CYAN RED PURPLE BROWN WHITE'
(,&'_z_' each j)=: i.8

load 'system/packages/color/cfmtfns.ijs'
cfmt_z_=: cfmt_cfmt_
