NB. labutil
NB.
NB.   assert       assert
NB.   cat          cat
NB.   chsub        character sub
NB.   deb
NB.   dtb
NB.   info         information msg box
NB.   quote
NB.   pathname
NB.   pdef
NB.   playsound    play a sound
NB.   playwav      play wav file
NB.   plurals      make word plural
NB.   round        round
NB.   start        start at section in current file
NB.   termLF
NB.   termdelLF
NB.   tdo
NB.   tolist       convert boxes to character list
NB.   LINE         line character
NB.
NB.   regex fns

cat=: ,&,.&.|:
deb=: #~ (+. 1: |. (> </\))@(' '&~:)
dtb=: #~ [: +./\. ' '&~:
info=: wdinfo @ ('Labs'&;)
getfontsize=: 13 : '{.1{._1 -.~ _1 ". y.'
pathname=: 3 : '(b#y.);(-.b=.+./\.y.=''\'')#y.'
a=. ''''
quote=: (a&,@(,&a))@ (#~ >:@(=&a))
plurals=: ] , (1: ~: [) # 's'"_
round=: ((%&) [.) (<.@+&0.5&.)
termLF=: , (0: < #) # LF"_ -. _1&{.    NB. ensure LF terminated
termdelLF=: }.~ [: - 0: i.~ LF&= @ |.  NB. ensure not LF terminated
tdo=: do__
tolist=: }. @ ; @: (LF&, each)
wdifopen=: boxopen e. <;._2 @ (wd bind 'qp')

NB. =========================================================
addjdir=: 3 : 0
if. IFMAC do. y. else.
  if. '\' ~: {.y.,'\' do. y.=. JDIR_j_,y. end.
end.
)

NB. =========================================================
NB. ??? not needed?
labdfx=: 3 : 0
if. IFWINCE do.
  if. '\' ~: {.y.,'\' do.
    y.=. (1!:42''),y.
  end.
end.
1!:0 y.
)

NB. =========================================================
NB. assert
assert=: ''&$: : (4 : 0)
if. -. 0 e. y. do. return. end.
if. 0=#x. do.
  j=. 'There is a problem with the lab.',LF,LF
  x.=. j,'Try re-loading J and starting it again.'
end.
info x.
laberror=. 13!:8@1:
laberror''
)

NB. =========================================================
NB. char sub
chsub=: 4 : 0
'f t'=. ((#x.)$0 1)<@,&a./.x.
t {~ f i. y.
)

NB. =========================================================
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

NB. =========================================================
playsound=: '' 1 : 0
select. 9!:12''
case. 2 do.
  'winmm.dll sndplaysound i *c i' & (15!:0) @ (;&1)
case. 6 do.
NB. 2=nodefault + 4=memory  +  16b20000 = file
  [: empty 'winmm.dll PlaySound i *c i i' & (15!:0) @ (;&(0;4))
end.
)

NB. =========================================================
playwav=: 3 : 0
if. IFSOUND*. 0<#y. do.
  s=. boxopen y.
  for_i. i.#s do.
    snd=. (deb i pick s) -. LF
    dat=. kread (LABPATH,SOUNDFILE);snd
    if. #dat do.
      playsound dat
    end.
  end.
end.
)

NB. =========================================================
NB. setfontsize
NB. size setfontsize fontdescription
setfontsize=: 4 : 0
b=. ~: /\ y.='"'
nam=. b#y.
txt=. ;:(-.b)#y.
ndx=. 1 i.~ ([: *./ e.&'0123456789.') &> txt
nam, ; ,&' ' &.> (<":x.) ndx } txt
)

NB. =========================================================
NB. wdmove
wdmove=: 4 : 0
'px py'=. y.
'sx sy'=. 2 {. 0 ". wd 'qm'
'x y w h'=. 0 ". wd 'psel ',x.,';qformx'
if. px < 0 do. px=. sx - w + 1 + px end.
if. py < 0 do. py=. sy - h + 1 + py end.
wd 'pmovex ',": px,py,w,h
)

NB. =========================================================
NB. wrapwin
NB. wrap text to jx window
NB. if. LABWRAP *. (IFRTF=0) *. (LABWINDOWED=0) do.
NB. if. LABWRAP *. LABWINDOWED=0 do.
NB.   if. LABWINDOWED do.
NB.     wid=. <. WINFONTSIZENOW %~ _50 + 2{".wd'psel labwin;qformx'
NB.   else.
NB. v    wid=. LABWIDTH
NB.   end.
NB.   wid foldtext y.
NB. else.
NB.   y.
NB. end.
NB. )

NB. =========================================================
NB. wraptext
NB. wrap text in jx window
wraptext=: 3 : 0
if. LABWIDTH > #y. do. y. return. end.
if. LABWRAP do.
  (LABWIDTH foldtext _2}. y.) , _2{.y.
else.
  y.
end.
)
