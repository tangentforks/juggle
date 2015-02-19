NB. Unix-specific fixes



NB. ====== Prokey

prokey_z_=: verb define
f=.<(getenv'HOME'),'/.j_prokey'
y. 1!:2 f
9!:31 (1!:1) f
>(9!:30''){'Failed';'OK'
)

NB. ====== wd substitutes

NB. A lot of the J Software assume the window driver is available
NB. without a second thought.  Some labs require wdinfo, for example.

wdinfo_z_ =: smoutput_z_
wd_z_ =: smoutput_z_

NB. ====== Lab support

jrequires_j_=: dyad define
if. -. (<'COCLASSPATH') e. ". 'namelist_',x.,'_ 0'
do. load y. end.
)

jlablist_jlab_=: verb define
'jlab' jrequires_j_ 'system/extras/util/lab.ijs'
IFWINCE=: 1
labgetfiles ''
LABCATS=: ALL;{."1 LABDIR
if. 0 e. $y. do.
	(":,.i.#LABCATS),"1 ' - ',"1 >LABCATS
elseif. (y.>:0)*.(y.<#LABCATS)*.(y.=<.y.)*.(''-:$y.) do.
	m=. (y.=0) +. (y.{LABCATS)={."1 LABS
	m # (":,.(#LABCATS)+i.#LABS),"1 ' - ',"1 >1{"1 LABS
elseif. 1 do.
	'invalid argument' assert_z_ 0
end.
)


jlabrun_jlab_=: verb define
'jlab' jrequires_j_ 'system/extras/util/lab.ijs'
IFWINCE=: 1
labgetfiles ''
LABCATS=: ALL;{."1 LABDIR
'invalid argument' assert_z_ (y.>:#LABCATS)*.(y.<LABCATS+&#LABS)*.(y.=<.y.)*.(''-:$y.)
labinit >2{(y.-#LABCATS){LABS
)



lablist_z_=: jlablist_jlab_
labrun_z_=: jlabrun_jlab_
labgo_z_=: labrun_jlab_ bind ''
