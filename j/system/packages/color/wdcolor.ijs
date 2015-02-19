NB. color table for wd 'qcolor'
NB.
NB. for a list of colors:
NB.   wdshowcolors''     
NB.
NB. for example, the windows menu color is:
NB.    ". wd 'qcolor 4'

WDCOLORS=: <;._2 (0 : 0)
COLOR_SCROLLBAR=:           0
COLOR_BACKGROUND=:          1
COLOR_ACTIVECAPTION=:       2
COLOR_INACTIVECAPTION=:     3
COLOR_MENU=:                4
COLOR_WINDOW=:              5
COLOR_WINDOWFRAME=:         6
COLOR_MENUTEXT=:            7
COLOR_WINDOWTEXT=:          8
COLOR_CAPTIONTEXT=:         9
COLOR_ACTIVEBORDER=:        10
COLOR_INACTIVEBORDER=:      11
COLOR_APPWORKSPACE=:        12
COLOR_HIGHLIGHT=:           13
COLOR_HIGHLIGHTTEXT=:       14
COLOR_BTNFACE=:             15
COLOR_BTNSHADOW=:           16
COLOR_GRAYTEXT=:            17
COLOR_BTNTEXT=:             18
COLOR_INACTIVECAPTIONTEXT=: 19
COLOR_BTNHIGHLIGHT=:        20
)

WD95COLORS=: <;._2 (0 : 0)
COLOR_3DDKSHADOW=:          21
COLOR_3DLIGHT=:             22
COLOR_INFOTEXT=:            23
COLOR_INFOBK=:              24
)

3 : 0''
w95=. 6=9!:12''
if. w95 do. WDCOLORS=: WDCOLORS,WD95COLORS end.
".each WDCOLORS
if. w95 do.
COLOR_DESKTOP=:             COLOR_BACKGROUND
COLOR_3DFACE=:              COLOR_BTNFACE
COLOR_3DSHADOW=:            COLOR_BTNSHADOW
COLOR_3DHIGHLIGHT=:         COLOR_BTNHIGHLIGHT
COLOR_3DHILIGHT=:           COLOR_BTNHIGHLIGHT
COLOR_BTNHILIGHT=:          COLOR_BTNHIGHLIGHT
end.
)

wdshowcolors=: 3 : 0
ndx=. WDCOLORS i.&> '='
nms=. ndx {. each WDCOLORS
inms=. i.#nms
(":,.inms),.' ',.(>nms) ,.' ',. ": ". wd @ ('qcolor '&,) @ ": &> inms
)