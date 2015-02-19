NB. labdir.ijs
NB.
NB. defines noun LABDIR as a list of shortname + pathname
NB. for lab directories. Modify this as required.
NB.
NB. Use an underscore for a blank in the shortname.
NB.
NB. Note that any other subdirectories of system\extras\lab
NB. not specified here will be included anyway.
NB.
NB. typical entries:
NB.   Math       system\extras\labs\math
NB.   Mystuff    source\main\mystuff
NB.   Soc101     d:\j\class\soc101

LABDIR=: noun define
Language           system/extras/labs/language
System             system/extras/labs/system
Concrete_Math      system/extras/labs/cmc
General_Interest   system/extras/labs/general
Math               system/extras/labs/math
Addons             addons
User               user/labs
)
