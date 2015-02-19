NB.  Phrases from Chapter 5, Section B of J Phrases.

c0=: cut=: 2 : ';@(<@x.;.y.)'   
a1=: c1=: cut 1                 NB.Case 1 of cut
a2=: c2=: cut 2                 NB.Case 2 of cut
d3=: pmax=: >./ c1              NB.Partitioned max over (case 1)
d4=: pmax2=: >./c2              NB.Partitioned max over (case 2)
d5=: pmaxs=: >./\ c1            NB.Partitioned max scan
d6=: pnub=: ~. c1               NB.Partitioned nub
d7=: psort=: /:~ c1             NB.Partitioned sort
d8=: prev=: |. c1               NB.Partitioned reverse
