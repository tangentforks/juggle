NB. shrink

isboxed =. 32"_ = 3!:0

ellipsis =.[: > (_;'...';_;_;_;<<'...')"_ {~ 2: ^. 3!:0

shrinkhead =. (0: >. [: <: [ <. #@]) {. ]
NB. shrinkmid  =. (([ <  #@]) , }.@$@]) $ ellipsis@]
shrinkmid  =.  ''"_`(ellipsis@]) @. (< #)
shrinktail =. -@*@#@] {. ]

shrink =. shrinkhead , shrinkmid , shrinktail

3 shrink  <"0 i. 6 10
4 shrink <'arf'

3&shrink @ (0&|:) ^: (3) i. 12 10 4

array_shrink =. (shrink 0&|:) ^: (#@$@])
box_shrink =. [&shrink&.> ^: (isboxed@])