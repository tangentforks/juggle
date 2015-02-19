coclass 'music'

C=:60

NB. Some scales, derived from individual intervals.
NB. +/\scale yields cumulative intervals, up to 12 (an octave)
NB. base ([ , (+ +/\)) scale

major	=:  2 2 1 2 2 2 1
minor	=:  2 1 2 2 2 1 2
pent	=:  3 2 1 1 3 2

sue =: scale_up_extend =: [ , (+ +/\)
sde =: scale_down_extend =: [ , (- |.@(+/\.))

triad =: 0 2 4
quad  =: 0 2 4 6

maj =: 0 4 7
min =: 0 3 7

C=:60
c=:C-12


NB. offsets of the standard 12 bar blues scheme:
bl =: 0 0 0 0  5 5 0 0	7 5 0 7

NB. safe scale for a bass player:
bass	=: 7 3 2
