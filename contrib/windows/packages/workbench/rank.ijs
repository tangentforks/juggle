NB. Roger Hui's rank functions,
NB. from "Rank & Uniformity",
NB. APL95 Proc., pp 83-90

rk		=: #@$
er		=: (0:>.(+rk))`(<.rk) @. (0:<:[)
fr		=: -@er }. $@]
cs		=: -@er {. $@]
boxr	=: ]`(<@$ , [ $: */@[}.])@.(*@#@])  NB. boxr
cells	=: fr $ cs boxr ,@]

pfx		=: <.&rk
agree	=: (pfx {. $@[) -: (pfx {. $@])
frame	=: [:`($@([^:(>&rk))) @. agree
rag		=: frame $ ([: */ rk@] }. $@[) # ,@]
lag		=: rag~

mrk		=: >./@:(rk&>)@,
crank	=: mrk ,:@]^:(-rk)&.> ]
msh		=: >./@:( $&>)@,
cshape	=: <@msh {.&.> ]
asm		=: > @ cshape @ crank

rank	=: 2 : 0
	'mlr'=:3&$&.|.y.
	([: asm [: x.&.> m&cells) : ([: asm l&cells@[ (lag x.&.> rag) r&cells@])
)
