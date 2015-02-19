NB.  Phrases from Chapter 13, Section A of J Phrases.

a0=: each=: &.>                 NB.Apply  verb to each box
m1=: open=: -:> :: 1:           NB.Test if open (not boxed)
v2=: fmt=: ":                   NB.Format
m4=: L. = 0:                    NB.Test if open
m5=: < -: {:@;~                 NB.Test if open
m6=: 32&>@(3!:0)                NB.Test if open
m7=: <^:(L. = 0:)               NB.Box if open
