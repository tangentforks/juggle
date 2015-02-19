NB. example class: baggage check

coclass'pbc'

create=:verb define
data=:keys=:''
)

destroy=:codestroy

put=:verb define
k=.#data
keys=:keys,k
data=:data,<y.
k
)

get=:verb define
>(keys i. y.){data
)

del=:verb define
b=.keys~:y.
data=:b#data
empty keys=:b#keys
)