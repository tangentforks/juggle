NB. Roger's Boxed Display Representation
oarg    =. >@(1&{)

root    =. (<1 0)&C.@,`] @. (e.&(,&.>'0123456789')@[)

dpx             =. {.root dp&.>@oarg

f =. ,.@(] ; stype ; 0 0"_ ;0 0"_) '+'
f
(NDname , NDclass){f

dpgl    =. {.root (dpx&.>@{. , dp &.>@}.)@oarg
dpgr    =. {.root (dp &.>@{. , dpx&.>@}.)@oarg
dpg             =. dpgr`dpgl`dpx @. (i.&(<,'`')@oarg)
dptil   =. dpx`(oarg@>@{.@oarg) @. ((<,'0')&=@{.@>@{.@oarg)
dpcase  =. oarg`dpgl`dpgl`dpg`dptil`dpx @. ((;:'0@.`:4~')&i.@{.)
dp              =. ]`dpcase @. boxed

display =. ,@<`[@.boxed @ dp @ > @ mr