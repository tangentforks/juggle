NB.Maintainer: Brian M. Schott <dscbms@panther.Gsu.EDU>
NB.Maintainer: Keith Smillie <smillie@cs.ualberta.ca>
NB.
NB.  [Brian Schott:]
NB.
NB.          I have worked on the stem&leaf a little more to
NB.  generalize it somewhat. It is now able to have stems with
NB.  intervals of 5, 10, or 20 and most reasonable powers-of-10
NB.  multiples of these numbers (though I have not experimented
NB.  with the range of powers of tens allowable). So for example,
NB.  alternatives to the interval width of 5 might be 0.005 and
NB.  50. Another feature of this version is that any sample
NB.  values exactly equal to 0 are alternately "distributed" to
NB.  the +0 and -0 stem by artificially adding or subtracting a
NB.  small constant from each exact zero. (But the distrib0 verb
NB.  was implemented in such a way that the data had to be sorted
NB.  twice, once before and once after distrib0.) Also all of the
NB.  final stems and leaves are character values, not numeric, so
NB.  that the negative 0 can be more explicit. 
NB.  
NB.          I apparently did not explicitly use Keith's verb
NB.  ADJzeros, probably because I forgot he sent it to me, but it
NB.  seems to work quite like my distrib0.
NB.   
NB.  ADJzeros=: (0&~: # ]) , [: 0.01 _0.01&($~) [: +/ 0:=] 
NB.  
NB.          The code is extremely inefficient and I can already
NB.  see ways to increase the processing speed somewhat. But
NB.  there is an aspect to my approach that makes my algorithm
NB.  very complex. As Keith suggested, I thought a simple way to
NB.  manage the possibility of both a +0 and -0 stem was to work
NB.  on the negative and positive sample numbers separately. But
NB.  this strategy complicates the "expansion" routines which
NB.  place missing stems between nonempty stems, especially when
NB.  the expansion of positive stems must take account of
NB.  negative values in the sample, and vice versa. 
NB.  
NB.          To exercise this draft of the verbs involved, a stem
NB.  interval is the left argument and the sample list is the
NB.  right argument. An example of running the program group is
NB.  shown NB.ed at the bottom of the definitions.

sort=: /:~
expand =: # ^:_1
each=: &.>
trunc =: * * <.@:|
odd =: (1&=)@:(2&|)
notempty =: 0:~:*/@$
posadjif5=: SLpos`Sp5@.(5:=split@:[)
negadjif5=: SLneg`Sn5@.(5:=split@:[)
preproc =: sort @: ((distrib0^:neg0pos) @: sort)@]
distrib0 =: ] + [: 0.1&*@([ * _1&^@])/"1 [: (- ,. +/\) 0&=

SL=: [: (~.@{. ;&>  <&(|@:trunc)/./) Stem ,: Leaf
SL=: [: (~.@{. ;&>  <&(lastdigit@:|@:trunc)/./) Stem ,: Leaf*[%~split@[
SL=: [: (~.@{. ;&>  <&(lastdigit@:|@:trunc)/./) Stem ,: (dblif5 Leaf ])*[%~split@[
Stem=: [*trunc@:%~
Leaf=: ([**@])|]
split =: ([: ".&, (3 2$'1020 5')"_#~ '125'"_ e. 0j20&": )"0
lastdigit =: {:&.(0&":)"0
dblif5=: [`+:@[@.(5:=split@:[)

SLneg5 =: ([: >[:{."1@:]SLneg )+[ *[: odd [ %~ [: >[:{."1@:]SLneg 
SLpos5 =: ([: >[:{."1@:]SLpos )-[ *[: odd [ %~ [: >[:{."1@:]SLpos
Sn5 =: SLneg5 ;&>{:"1@:SLneg
Sp5 =: SLpos5 ;&>{:"1@:SLpos

negmakechar =: ([: ":@]`('_0'"_)@.(0&=)each ({."1@:] )),.([: ":@]each ({:"1@:] ))
posmakechar =:  ":@]each 

posSLtab =: [ SL 0&<:@] # ]
negSLtab =: [ SL 0&>@] # ]
SLtab=: ([SL (0&>@]#])),([SL (0&<:@]#]))

baseneg =: [:+[*[:(({:-[: i.[: <:{.-{:)@:])([ st negSLtab),(i.@:anypos@:])
basepos =: [:+[*[:(({.+[: i.[: >:{.-~{:)@:])([ st posSLtab),~(i.@:anyneg@:])
st =: >@{."1@]%[

SLneg =: <"0@baseneg,.(baseneg e.>@{."1@SLtab)expand {:"1@:SLtab
SLpos =: <"0@basepos,.(basepos e.>@{."1@SLtab)expand {:"1@:SLtab
SLneg =: <"0@baseneg,.(baseneg e.>@{."1@negSLtab)expand {:"1@:negSLtab
SLpos =: <"0@basepos,.(basepos e.>@{."1@posSLtab)expand {:"1@:posSLtab
SLpos =: (i. 0 2)"_`(<"0@basepos,.(basepos e.>@{."1@posSLtab)expand {:"1@:posSLtab)@.(notempty@:posSLtab)
SLneg =: (i. 0 2)"_`(<"0@baseneg,.(baseneg e.>@{."1@negSLtab)expand {:"1@:negSLtab)@.(notempty@:negSLtab)

anypos =: {:>:0: 
anyneg =: {.<:0:
neg0pos =: tg0*.hl0
tg0 =: {:>0:
hl0 =: {.<0:

a =:_5.7 1.2 4.1 3.2 7.3 7.5 18.6 3.7 _1.8 2.4 _6.5 6.7 9.4 _2
a =:a,_2.8 _3.4 19.2 _4.8 0.5 _0.6 2.8 _0.5 _4.5 8.7 2.7 4.1 _10.3
a =:a,4.8 _2.3 _3.1 _10.2 _3.7 _26.6 7.2 _2.9 _2.3 3.5 _4.6 17.2
a =:a,4.2 0.5 8.3 _7.1 _8.4 7.7 _9.6 6 6.8 10.9 1.6 0.2 _2.4 _2.4
a =:a,3.9 1.7 9 3.6 7.6 3.2 _3.7 4.2 13.2 0.9 4.2 4 2.8 6.7 _10.4
a =:a,2.7 10.3 5.7 0.6 _14.2 1.3 2.9 11.8 10.6 5.2 13.8 _14.7 3.5
a =:a,11.7 1.3

NB. 50 (([: negmakechar [ negadjif5 ]),[: posmakechar [ posadjif5 ]) preproc a, _65

