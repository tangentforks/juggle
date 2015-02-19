NB.  Phrases from Chapter 11, Section C of J Phrases.

m0=: ] i."1&.|: 1 _1"_          NB.Column node table from connection table columns (inverse to m3)
m1=: ] (i."1) 1 _1"_            NB.Node table from connection table rows (inverse to m4)
m2=: [:-/ ] =/ [:i. [:>: [:>./ ,  NB.Row connection table from node table columns
m3=: [: |: m2                   NB.Column connection table from node table columns (inverse to m0)
m4=: [:-/"2 ] =/ [:i. [:>: [:>./ ,  NB.Row connection table from node table rows (inverse to m1)
