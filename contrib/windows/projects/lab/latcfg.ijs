NB. lab author configuration

NB. =========================================================
CFGHDR=: ; < @ ('NB. '&,) ;.2 (0 : 0)
Lab Author configuration

defines:
LATRECENT      recent lab author loads

)

NB. =========================================================
fullname=: 3 : 0
if. 0=#y. do. '' return. end.
if. ':' e. y. do. y.
elseif. '\' ~: {.y. do. JDIR_j_,y.
elseif. 1 do. (2{.JDIR_j_),y.
end.
)

extijt=: , ((0: < #) *. [: -. '.'"_ e. ]) # '.ijt'"_
extnone=: {.~ (i.&'.')

fexist=: 1:@(1!:4)@boxopen :: 0:
fexists=: #~ fexist&>

drophead=: ] }.~ #@[ * [ -: #@[ {. ]
jdirname=: JDIR_j_ & drophead
partname=: jdirname @ extnone

labfull=: fullname @ extijt

labpart=: 3 : 0
y=. LATPATH drophead extnone y.
x=. y {.~ y i. '\'
if. -. y -: x,'\',x do. y end.
)

NB. =========================================================
a=. ''''
quote=: (a&,@(,&a))@ (#~ >:@(=&a))

NB. =========================================================
NB. nounrep - good for character data
nounrep=: 3 : 0
dat=. ". y.
if. (0=#dat) +. 2=3!:0 dat do.
  if. LF e. dat do.
    dat=. dat, LF -. {:dat
    y.,'=: 0 : 0', LF, ; <;.2 dat,')',LF
  else.
    y.,'=: ',(quote dat),LF
  end.
else.
  y.,'=: ',(":dat),LF
end.
)

NB. =========================================================
NB. labcfgread
tcfgread=: 3 : 0
XLATRECENT=: LATRECENT=: ''
try. 0!:0 <LATCFG catch. end.
XLATRECENT=: fexists labfull each cutopen LATRECENT
)

NB. =========================================================
tcfgsave=: 3 : 0
LATRECENT=: tolist partname each XLATRECENT
dat=. CFGHDR
dat=. dat,LF,nounrep 'LATRECENT'
dat flwrites LATCFG
)

NB. =========================================================
NB. add to recent lab files:
taddrecent=: 3 : 0
f=. <LABPATH,LABFILE
if. -. f -: {.1{.XLATRECENT do.
  XLATRECENT=: ({.~ MAXRECENT"_ <. #) ~. f,XLATRECENT
  tcfgsave''
end.
)
