require 'fields'
require 'strings'
wdnums =. ('_-'&charsub) @ ":
NB. wdnums =. ":

dbg =. 1!:2&2


ar =. 5!:1
mr =. ar @ <

boxed=. 32"_ = 3!:0

stype =. 3 : 0
        ". 'dummy =.' ,  y.
        > type <'dummy'
)

ntype =. 3 : 0
        ". 'dummy =.' ,  y.
        4!:0 <'dummy'
)

NB.  Nodes "N" will substitute
NB.  the simple strings in an
NB.  Atomic Representation.

'N' mkfields 'name nc wh'
newN =. ((#,#) sNwh stype sNnc sNname&emptyN)
treewalk =. (`($:&.>)) @. boxed
mknodes =. newN treewalk
nodesrep =. mknodes &. > @ ar

NB. for example:  nodesrep <'mr'

NB. === node geometries:
NB.
NB.             For each node, we compute its space requirements
NB.             in abstract units.  Convention:  a simple kernel
NB.             verb occupies 100 x 100 units.  Composed nodes
NB.             will require in most cases the space for their
NB.             component nodes (whatever that may be) and for any
NB.             further embellishments.  Width,Height are stored in
NB.             in the Nwh field of each node.
NB.
NB.             The overall size of the node structure is used to
NB.             compute a scaling factor that will transform all
NB.             coordinates or lengths nicely into the 1000 x 1000
NB.             coordinate space of the isigraph window control.
NB.
NB.             The left arg of each drawing verb specifies
NB.             (scalefactor, x, y) where the corner x,y is
NB.             still unscaled.

vcstack =. >./&{. , +/&{:
cons    =. ,&<
car             =. >@(0&{)
cdr             =. >@(1&{)
isN             =. -.@boxed@car
nodewalk =. ($:&.>`)@.isN

rootsize =. $:@car`gNwh@.isN
topsizes =. rootsize@>
argssized =. sized&.>@cdr

verbsized =. 100 100&sNwh
unsized =. 9 9 &sNwh
splitsized =. cons~ 'split'&sNname@('split'&sNnc)@(sNwh&emptyN)@(+&500 200)@rootsize
atargssized =.  (sized@car cons splitsized@sized@cdr) @ cdr
atsized =. car (] ,&<~ vcstack/@:topsizes@] sNwh [) atargssized
nodesized =. atsized`unsized@.('c'&i.@{.@gNnc@car)
sized           =. nodesized`verbsized@.(isN)
sizedrep        =. sized@mknodes &.> @ar

NB.     for example:  repsized <'mr'

NB. =================== drawing nodes:


GW=:0 : 0
        pc abc closeok; cc g isigraph rightmove bottommove; pas 0 0;
        pshow;
)
GS      =. '; gshow;'

NB. =================== color stack:

colorstack =: 1 3 $ 0 0 0
pushcolor =. 3 : 0
        co =. (?&#~ { ]) 0 0 150 + ? 100 100 100
        colorstack =: colorstack , co
        wde 'grgb ', (":co), '; gpen 1;'
        y.
)

popcolor =. 3 : 0
        colorstack =: }: colorstack
        wde 'grgb ',(": {: colorstack), '; gpen 1;'
        y.
)

colored =. pushcolor :. (popcolor^:2)

drverb =. 3 : 0
:
        sf =. {.x. [ xy =. }. x.
        (fieldsN) =. y.
        NB. wd 'groundr ', (":  xy , sf* wh, -: wh), GS
        NB.             pushcolor ''
        NB.             x. acellbox wh
        NB.             popcolor ''
        wd 'gtext ', (": xy + sf* 0.2 0.8 * wh), ' ',EAV, name, EAV, GS
)

acellbox =. 3 : 0
:
        sf =. {.x. [ xy =. }. x.
        wh =. y.
        NB. unscaled cell diameter:
        diam =. 20
        cc =. {:colorstack
        lighted =. 255"_ <. +:
        NB. x. draw cdr y.
        wd 'gpen 1 ps_dash; groundr ', (":  xy , sf* wh, diam,diam), GS
        t=.             'gpen 1 ps_solid; grgb ', (":lighted cc), '; gbrush;'
        t=.t,   'gellipse ', (wdnums xy, sf* (,-) diam), ';'
        t=.t,   'grgb ', (": cc), '; gbrush;'
        t=.t,   'gellipse ', (wdnums (xy + (sf,0)*wh), sf* (-,-) diam), ';'
        t=.t,   'gellipse ', (wdnums (xy + sf* 0.5 1*wh-diam,0),sf*(7-?15 15)+diam), ';'
        wd t,'gbrushnull;',GS
)

drat    =. 3 : 0
:
        sf =. {.x. [ xy =. }. x.
        (fieldsN)=.car y.
        w =. 0{wh
        h =. 1{wh
        szs =. topsizes cdr y.
        NB. let's assume u@v
        u =. car cdr y.
        v =. cdr cdr y.
        (sf, xy + sf* (-: w - (<1 0) {szs) ,0         ) draw v
        (sf, xy + sf* (-: w - (<0 0) {szs) ,(<1 1){szs) acellbox&.colored {.szs
        (sf, xy + sf* (-: w - (<0 0) {szs) ,(<1 1){szs) draw u
)

drambisplit =. 3 : 0
:
        sf =. {.x. [ xy =. }. x.
        (fieldsN) =. car y.
        ('w';'h') =. wh
        matepos =. ": xy + sf * (-:w),50
        szs =. ,rootsize cdr y.
        pushcolor ''

        t=.             'gmove ', (": xy), ';'
        t=.t,   'gline ', matepos, ';'
        t=.t,   'gline ', (": xy + sf* w,0), ';'
        t=.t,   'gmove ', matepos, ';'
        t=.t,   'gline ', (": xy + sf* (-: {. szs),100), ';'
        t=.t,   'gmove ', matepos, ';'
        t=.t,   'gline ', (": xy + sf* (w-350),100), ';'
        t=.t,   'gmove ', matepos, ';'
        t=.t,   'gline ', (": xy + sf* (w-50), 100), ';'
        wd t,'gshow;'
        t=.             'gpen 1 ps_solid;'
        NB. t=.t,       'grect ', (": (xy+ sf* 0,100), sf* szs), ';'
        t=.t,   'gpen 1 ps_dash;'
        NB. t=.t,       'grect ', (": (xy+ sf* (w-400),100), sf* 100, h-200), ';'
        t=.t,   'gtext ', (": (xy+ sf* (w-250),-:h)), ' "..." ;'
        NB. t=.t,       'grect ', (": (xy+ sf* (w-100),100), sf* 100, h-200), ';'
        t=.t,   'gpen 1 ps_solid;'
        wd t, 'gshow;'
        (sf, xy+ sf* 0 100) acellbox szs
        (sf, xy+ sf* (w-400),100) acellbox 100, h-200
        (sf, xy+ sf* (w-100), 100) acellbox 100, h-200
        (sf, xy + sf* 0 100) draw cdr y.
        t=.             'gmove ', (": xy + sf* (-:{.szs),h-100),';'
        t=.t,   toexit =. 'gline ',(": xy + sf* (-:w),h), ';'
        t=.t,   'gmove ', (": xy + sf* (w-350),h-100),';'
        t=.t,   toexit
        t=.t,   'gmove ', (": xy + sf* (w-50),h-100),';'
        t=.t,   toexit
        wd t,'gshow;'
        popcolor ''
)

drcons  =. drat`drambisplit@.(((;:'@ split')&i.)@(Nname&{)@car@])
draw    =. (1 100 100 & $:) : (drcons`drverb@.(isN@]))

showverb =. 3 : 0
        NB.             y. is a sized node tree.
        NB.             Compute the scaling factor, the lower left hand corner,
        NB.             if invoked monadically.
        NB.             Otherwise, x. is (sf,x,y) explicitly
        NB.             Create the isigraph and call 'draw'.
        rs =. rootsize y.
        sf =. <./ 950 % rs
        corner =. -: 1000 - sf * rs
        wdreset ''
        wd GW
        (sf,corner) showverb y.
:
        x. draw y.
)
showrep =. showverb@(>@sizedrep)
sr =. 3 : 0
        showrep y.
        wd 'pn ',EAV,(>y.),EAV,';'
)

ignore =. 0 : 0
        wd 'gclear;'
        wd 'reset;'
)

sr <'showrep'
