NB. Netscape primary colors (256 color table)
NB. recommended for Web pages
NB.
NB. COLORNS216   no dithering
NB. COLORNS40    other primaries
NB.
NB. to view:
NB.   load 'system/packages/color/ntcolor.ijs'
NB.   showcolor NS216
NB.
NB. hex values:
NB.   load 'convert'
NB.   ,"2 hfd COLORNS216

COLORNS216=: >,{(;;~)0 51 102 153 204 255

j=. 16 #. (i.16) */ 1 1
COLORNS40=: /:~ COLORNS216 -.~ ~. ,/j */ 1,=i.3