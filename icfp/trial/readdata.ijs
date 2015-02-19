NB. read raw data into J arrays.

require 'files strings'

NB. stop_lines
NB. a boxed two-column table:
NB. left column is a stop number,
NB. right column the list of passing lines.
NB. Ignore lines of the form "123 0" in the input, i.e. unvisited stops.

purge =. #~ ((<,0)"_ ~: {:)"1
stop_lines =: purge ({. ; }.)@".;._2  freads <'bus/stopline.dat'

NB. stops
NB. For the assignment, we only need the stop number, long name, short name.
NB. We don't need to differentiate the detailed stop point (which identifies
NB. inbound vs. outbound sides of the road or multiple stop point. at an
NB. intersection)

NB. A sample line with a ruler:
NB. +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NB. 0    5   10   15   20   25   30   35   40   45   50   55   60   65   70
NB. +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NB. 000001 00000 00000 1 Abbenrode                      ABBE 000 11 0011 001 ...

triplet =. ".@((0+i.6)&{) ; deb@((21+i.30)&{) ; (52+i.4)&{
stops =: ~. triplet;._2  freads <'bus/stops.dat'
