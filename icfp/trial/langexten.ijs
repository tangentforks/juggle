coclass 'z'
NB. language extensions

NB. Type y. on the terminal
display =: 13 : '(i. 0 0)"_ y. 1!:2 (2)'

NB. Conjunction: u. unless y. is empty; then v.
butifnull =: ((]."_)`[.) @. (*@#@])
NB. Alternative form without gerund.  This turns out to be slower
NB. butifnull =: [. ^: ((] *@#) ` ((]."_) ^: ((] 0&=@#)`])))

NB. Conjunction: u. unless x. is empty; then v.
butifxnull =: ((]."_)`[.) @. (*@#@[)

NB. Empties: select one according to context
NIL =: ''   NB. required argument to niladic function
NILRET =: ''   NB. return from function with no explicit result
NILRETQUIET =: i. 0 0  NB. return to J, without printing
NB. verb to return empty list, to discard the actual returned value
null =: ''"_

NB. Adverb.  Do u., but skip it if y. is null
onlyifnonnull =: ^: (*@#@])
NB. Same if x. is nonnull
onlyifxnonnull =: ^: (*@#@[)

NB. bivalent =: [. ^: (1:`(].@]))  NB. u. v. y. if monad, x. u. (v. y.) if dyad
NB. u. v. y. if monad, x. u. (v. y.) if dyad
bivalent =: [. ^: (1:`((]`].)`:6))

NB. x. is string, result is that verb but forced to be monadic
impmonad =: (13 : ]:) : [:

NB. x. is string, result is that verb but forced to be dyadic
impdyad =: [: : (13 : ]:)

NB. Like /. dyadic, but using intolerant comparison.  Faster on lists with identical first elements
key0 =: ((]:@#~) =!.0)~

NB. Like e. dyadic, but using tolerant comparison.  Faster on lists with identical first elements
in0 =: e.!.0

NB. Like i. dyadic, but using tolerant comparison.  Faster on lists with identical first elements
index0 =: i.!.0

NB. Conjunctions to use for readability
xuvy =: ([.`].) `:6  NB. x u v y
yuvx =: xuvy~  NB. y u v x
uy_vx =: ((].~)`[.) `:6   NB. (u y) v x
ux_vy =: uy_vx~  NB. (u x) v y
vy_ux =: ]. uy_vx [.  NB. (v y) u x
vx_uy =: ]. ux_vy [.  NB. (v x) u y

NB. y. is anything; result is a ist of 0 y.s
noneof =: ($0)&(]"0 _)

NB. Adverb.  Monad, converts y. to rank u. by adding axes
enrank =: ,: ^: ((0&>.)@(]:&-)@#@$)

NB. y. is character string list of entry-point names
NB. x. is the level number at which we should publish the entry points (default _1, 'z')
NB. we publish these names in the z locale
publishentrypoints =: 3 : 0
_1 publishentrypoints y.
:
NB. The rhs of the assigment below interprets the names as gerunds
path =. '_' (,,[) x. {:: (<,'z') ,~^:(-.@#@]) 18!:2 current =. 18!:5 ''
l =. ,&path^:('_'&~:@{:)&.> ;: y.
r =. ,&('_' (,,[) > current)@(({.~ i:&'_')@}:^:('_'&=@{:))&.> ;: y.
NB. The gerund assignment requires more than one name, so duplicate the last:
('`' , ;:^:_1 (, {:) l) =: (, {:) r
)

NB. Cuts
onpiecesbetweenm =: 12 : '(x. ;._1)@:(y.&,)'
onpiecesbetweend =: (([.`> `: 6 "_1)`((< ;. _1)@(]. & ,)) `: 6)
onpiecesbetween =: onpiecesbetweenm : onpiecesbetweend
onpiecesusingtail =: 11 : 'x. ;._2'

NB. Conjunction.  u. is verb, n. (or [x.] v. y.) is arg to { to select s = desired portion of y.
NB. The result of x. u. s (if dyad) or u. s (if monad) replaces s
applytoselection =: ([. bivalent (].&{)) (]: ]: ]) (].})
applytoselectionm =: ([. @ (].&{)) (]: ]: ]) (].})
applytoselectiond =: ([. xuvy (].&{)) (]: ]: ]) (].})

NB. Debugging support
NB. conjunction: execute u. after displaying n.
afterdisplaying =: [. [ (display @ (]."_))

NB. Memory management
NB. adverb: purge memory, then do u.
afterpurging =: ]: [ (7!:4 @ (($0)"_))
NB. debug afterpurging =: ]: [ (7!:4 @ display @ ('purging free list'"_))

NB. Conditionally purge memory.
NB. y. is (machine memory available),(amount we think we need);
NB.   defaults are MACH_MEMSIZETOUSE and 0.75*0{y.
NB. If x. message to type when we purge (default=1)
condpurge =: 3 : 0
'purging memory free list' condpurge y.
:
if. 0=#y. do. y. =. MACH_MEMSIZETOUSE end.
if. 1=#y. do. y. =. 1 0.75 * y. end.
if. (-/ 2 {. y.) < +/ */"1 (1024) ((< 0&{"1) # ]) 7!:3 NIL do.
  7!:4 NIL
  display onlyifnonnull x.
end.
NILRET
)

NB. conjunction: execute u. after conditionally purging, with parameters n.
aftercondpurge =: [. [ (condpurge @ (]."_))

NB. conjunction: execute u., counting time.  n. is a descriptive string
showtime =: 2 : 0
display 'Starting ' , n.
starttime =. 6!:0 NIL
u. y.
if. 0: display 'Exiting ' , n. , ' time=' , ": 0 12 30 24 60 60 #. (6!:0 NIL) - starttime do. end.
:
display 'Starting ' , n.
starttime =. 6!:0 NIL
x. u. y.
if. 0: display 'Exiting  ' , n. , ' time=' , ": 0 12 30 24 60 60 #. (6!:0 NIL) - starttime do. end.
)

NB. Conjunction: we use this for things that may need to be 'rank' if J
NB. starts reexecuting frequently, but are " till then.  The nature of these things
NB. must be that they perform I/O, so we inhibit them if they are null
rnk =: " onlyifnonnull

NB. Conjunction: like ", but guarantees no reevaluation of cells
rank =: 2 : 0
ru =. 0 { v.
if. ru < 0 do. ru =. 0 >. (# $ y.) + ru end.
r =. ru <. # $ y.
f =. (-r) }. $ y.
fi =. 0
if. fl =. */ f do.
  r =. 0 $ a:
  while. fi < fl do.
    x =. ,/ <"0 f #: fi   NB. index to frame
    r =. r , < u. ( (< x) { y.)
    fi =. >: fi
  end.
  > f $ r
else.
  f $ ,: u. ((-r) {. $y.) $ 1 {. , y.
end.
:
'lru rru' =. 1 2 { 3 $&.|. v.
if. lru < 0 do. lru =. 0 >. (# $ x.) + lru end.
if. rru < 0 do. rru =. 0 >. (# $ y.) + rru end.
lr =. lru <. # $ x.  NB. ranks to use
rr =. rru <. # $ y.
lfs =. (-lr) }. $ x. NB. frames
rfs =. (-rr) }. $ y.
fr =. lfs <.&# rfs  NB. rank of common part of frame
if. -. lfs -:&(fr&{.) rfs do. 13!:8 (8) end.
f =. (fr {. lfs) , lfs ,&(fr&}.) rfs  NB. the longer of the frames
fi =. 0
if. fl =. */ f do.
  r =. 0 $ a:
  while. fi < fl do.
    x =. ,/ <"0 f #: fi   NB. index to frame
    r =. r , < ( (< ($lfs) {. x) { x.) u. ( (< ($rfs) {. x) { y.)
    fi =. >: fi
  end.
  > f $ r
else.
  if. -. */ lfs do. x. =. ((-lr) {. $x.) $ 1 {. , x. end.
  if. -. */ rfs do. y. =. ((-rr) {. $y.) $ 1 {. , y. end.
  f $ ,: x. u. y.
end.
)

NB. Conjunction: x. if y. is nonzero, otherwise nullverb
butonlyif =: 2 : 0
if. y. do. x. else. ($0)"_ end.
:
if. y. do. x. else. ($0)"_ end.
)

FormalLevel =: 2 : 0
 m=. 0{ 3&$&.|. n.
 ly=. L. y.  if. 0>m do. m=.0>.m+ly end.
 if. m>:ly do. u. y. else. u. FormalLevel m&.> y. end.
   :
 'l r'=. 1 2{ 3&$&.|. n.
 lx=. L. x.  if. 0>l do. l=.0>.l+lx end.
 ly=. L. y.  if. 0>r do. r=.0>.r+ly end.
 b=. (l,r)>:lx,ly
 if.     b-: 0 0 do. x.    u. FormalLevel(l,r)&.> y.
 elseif. b-: 0 1 do. x.    u. FormalLevel(l,r)&.><y.
 elseif. b-: 1 0 do. (<x.) u. FormalLevel(l,r)&.> y.
 elseif. 1       do. x. u. y.
 end.
)

FormalFetch =: >@({&>/)@(<"0@|.@[ , <@]) " 1 _
