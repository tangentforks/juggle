NB.  Phrases from Chapter 10, Section B of J Phrases.

m0=: >./                        NB.List maximum or column maxima
d1=: >./ .*                     NB.Maximum of x weighted by y
d2=: <./ .*                     NB.Minimum of x weighted by y
d3=: +/ .= ,                    NB.How many x in y?
m4=: +/"1                       NB.Sum rows of y
m5=: >./-<./                    NB.1 less than range of y
m6=: [: >./ 0: , ]              NB.Maximum of y, but at least 0
m7=: <./                        NB.List minimum or column minima
