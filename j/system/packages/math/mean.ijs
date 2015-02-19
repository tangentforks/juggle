NB. various means
NB.
NB. arithmean   arithmetic mean
NB. geomean     geometric mean
NB. harmean     harmonic mean
NB. commonmean  common mean

arithmean=: +/ % #
geomean=: # %: */
harmean=: arithmean &. (%"_)
commonmean=: {. @ ((geomean,arithmean) ^: _)
