NB.  Phrases from Chapter 2, Section F of J Phrases.

m0=: >: @ +: @ i.               NB.First odd integers
m1=: 1: + 2: * i.               NB.Same as m0
m2=: +/ @ (1: + 2: * i.)            NB.Sum of odd integers
m3=: [: +/ 1: + 2: * i.           NB.Same as m2 using cap
v4=: m=: [:                     NB.Mnemonic for this use of cap (monad)
m5=: m +/ 1: + 2: * i.           NB.Same as m3
m6=: m2 -: *:                   NB.Sum of odds is square (Tautology)
m7=: %:@(+/@(*:@(]-+/%#)))      NB.Standard deviation
m8=: m%: m+/ m*: ] - +/ % #         NB.Same as m7
