coclass 'solver'
testdb =: < (_3 ]\ 50 60 1  40 70 2)
testdb =: testdb , < (_3 ]\ 30 40 4  20 50 5  100 120 0)
testdb =: testdb , < (_3 ]\ 80 100 1  40 60 5  10 30 0 100 200 4)
testdb =: testdb , < (_3 ]\ 20 40 0  50 70  4  60 80 1)
testdb =: testdb , < (_3 ]\ 10 30 0  20 40 2  30 60 5)
testdb =: testdb , < (_3 ]\ 20 40 0  10 30 2  70 100 4)
NB. testdb_solver_ findbestroutes_solver_ 2;4;0
NB. require 'd:\trade\langexten d:\trade\utils'
require 'langexten utils'
NB. dbgput =: 0j0&putdata
dbgput =: 0:
NB. Schedule solver.  Dyad.
NB. x is a boxed list, with one box for each station, that box
NB.           containing a list; each list element to contain
NB.           a record for each bus ENTERING the station:
NB.           (arrival time),(departure time),(station number from
NB.             which the bus comes),(other stuff at the caller's
NB.             option - this module will ignore it)
NB.      the times are positive integers, representing the number
NB.        of minutes before the desired arrival time that the
NB.        bus departs or arrives.  I am doing it in this strange way
NB.        because the schedule depends on the day of the week,
NB.        so I am making it the caller's responsibility to create
NB.        a schedule based on the day.  This also pushes the problem
NB.        of midnight wraparound back on the caller.
NB.      the station number is an index into this very array x .
NB.
NB. NOTE! items within each box that have the same station number
NB.        must be in ascending order of departure time!
NB. 
NB. y is destination_station;departing_station;number_of_routes_desired
NB.   stations are indexes into x; number_of_routes_desired is 5
NB.   in this problem spec
NB. 
NB. Result will be a boxed list with up to number_of_routes_desired
NB.   elements (fewer if there are fewer solutions).  Each box will
NB.   contain a list of (departing_station,arriving_station,index)
NB.   such that for segment i the departing station is (<i;0){result,
NB.   the arriving station is (<i;1){result, and the bus used is
NB.   ((<i;2){result) { ((<i;1){result) {:: x  (the caller is
NB.   expected to hold enough information, or to tuck the information
NB.   into elements 3 and above of x, to be able to reconstruct
NB.   the line from this index).
findbestroutes =: 4 : 0
'dest origin numroutes' =. y.
NB. Find the scale of the problem: for each station, the average length of trip
avgtriplen =. (+/ % #)@:(-~/ @: (0 1&{)"1) S:0 x.
dbgput 'avgtriplen'
NB. Create the flattened database.  This is a list of
NB. (arrival time),(departure time),(departing station),(arriving station)
NB. for each route, and an index to it, giving the (start,len) for the
NB. entries of each arriving station
routedb =: (; x.) ,. (# S:0 # i.@#) x.
routendx =: (,.~ _1&(|.!.0)@:(+/\)) # S:0 x.
dbgput 'routedb'
dbgput 'routendx'
NB. Initialize the list of stations that have new times
unevald =. ,dest
NB. Initialize the vector giving, for each station, the latest admissible arrival time.
NB. Set all to a high value (not visited yet) except for the destination, which
NB. by our difinition has time 0
latestdeparture =: 0 dest} (#x.)$100000
NB. Initialize the vector giving, for each station, the station number of the best
NB. bus to get to this station.  Initial values are immaterial
bestprevstation =: (#x.)$_1
NB. Init list of output routes
result =: 0 $ a:
NB. Loop for each route we are looking for
while. numroutes > #result do.
  NB. Loop, evaluating stations, until either we get to the origin station or we
  NB. run out of things to evaluate
  while. *#unevald do.
  dbgput 'unevald'
    NB. decide which stations to evaluate.  Getting this right has a big effect
    NB. on performance.  We select, from among the unevaluated stations, those
    NB. whose times are 'close enough' to the best time.  For now, we take close
    NB. enough to mean, the best time plus the average trip time from the best station
    bestx =. (i. <./) unevald { latestdeparture
dbgput 'bestx'
    latesttime =. latestdeparture +&((bestx{unevald)&{) avgtriplen
dbgput 'latesttime'
    itemstoeval =. (evalmsk =. latesttime >: unevald { latestdeparture) # unevald
dbgput 'evalmsk'
dbgput 'itemstoeval'
    NB. Evaluate the selected items.  Select the routes for the items we are
    NB. processing.  Delete the segments that are not in time to get to the destination.
    NB.  Sort this list on time, and
    NB. then keep only the best time for each station; this gives the latest departure
    NB. from each station that we can get from (in this evaluation)
    NB. We go ahead and cull out earlier buses at each station, since that's probably
    NB. faster than waiting till we have all the routes together
    seldrcds =. (; <@(+ i.)/"1 itemstoeval { routendx) { routedb
dbgput 'seldrcds'
    allowedrcds =. (((<itemstoeval;1) { routendx) # itemstoeval { latestdeparture) ((<: 0&{"1) # ]) seldrcds
dbgput 'allowedrcds'
    bestdeparts =. (#~ ~:@:(2&{"1)) (/: 1&{"1) allowedrcds
NB. obsolete     bestdepartsbystation =. latestdeparture ((#~ ~:@:(0&{"1))@:(2 1&{"1)@:((<: 0&{"1) # ]))&.>&(itemstoeval&{) x.
NB. obsolete dbgput 'bestdepartsbystation'
NB. obsolete     bestdeparts =. (#~ ~:@:(0&{"1)) (/: 1&{"1) ; bestdepartsbystation ,"1 0 L:0"0 itemstoeval
dbgput 'bestdeparts'
    NB. Now see which new departures represent an improvement on the old ones.  We will install
    NB. their new times, and add them to the unevald list.  We also remove anything we just evaluated from
    NB. the unevald list (but do that first, because an item might get added right back in!)
    itemstoupdate =. 2 {"1 updatedeparts =. bestdeparts #~ newbestmsk =. (1 {"1 bestdeparts) < (2 {"1 bestdeparts) { latestdeparture
    latestdeparture =: (1 {"1 updatedeparts) itemstoupdate} latestdeparture
    bestprevstation =: (3 {"1 updatedeparts) itemstoupdate} bestprevstation
dbgput 'itemstoupdate'
dbgput 'latestdeparture'
dbgput 'bestprevstation'
    unevald =. ~. itemstoupdate , (-. evalmsk) # unevald
    NB. When we set the winning route, save it (this may happen more than once on the way to
    NB. getting a solution; we want the last)
    if. origin e. itemstoupdate do. unevaldatsuccess =. unevald end.
    NB. Delete from 'unevald' any node that are reached after we have reached the origin
    NB. node.  They can't possibly be of interest.
    unevald =. unevald #~ (unevald { latestdeparture) < (origin { latestdeparture)
  end.
  NB. The problem is solved (if a solution is possible).  Now reconstruct the path by
  NB. following the chain starting at the origin point, till we get to a node with
  NB. chain field _1 (this will normally be the destination station, but if no solution
  NB. was possible this will create a 1-element list)
  stationlist =. bestprevstation ( ] , (#~ 0&<:)@:({~ {:) )^:_ ,origin
dbgput 'stationlist'
  NB. That's the best route.  Now convert it to the form given in the program spec:
  NB. list of (departing_station,arriving_station,index).  We can be sure that the
  NB. departure time matches a route, since it is the departure time that sets the
  NB. limit on how late we can arrive at a station; not so the arrival time
  if. 1 < #stationlist do.
    departtime =. (orgs =. }: stationlist) { latestdeparture
dbgput 'arrivetime'
    departrcds =. routedb <@({~ (+ i.)/)"_ 1 (dests =. }. stationlist) { routendx
    segmentindex =. (departtime ,. orgs) (i.~  1 2&{"1@:>)"_1 departrcds
    result =. result , < orgs ,. dests ,. segmentindex
  else. break. end.
  NB. Now we have to set up for finding the next-best route.  To do this, delete the
  NB. first segment from the database, and restart the search.  We have to be careful
  NB. where we restart.  We must reevaluate all the nodes that were evaluable at the
  NB. time the last assignment was made to the origin node.  We must also reevaluate
  NB. the node that led to the origin node, since its database has been modified.
  NB. Modify the database by zapping the departure time, since we must keep the
  NB. indexes into the database consistent.
  NB. Make sure this is in-place:
  zappedroute =. < 1 ;~ ({. segmentindex) + (<({. dests);0) { routendx
dbgput 'zappedroute'
  routedb =: 100000 zappedroute} routedb
dbgput 'routedb'
  unevald =. ~. ({. segmentindex) , unevaldatsuccess -. origin
  NB. Remove the time-found at the origin node:
  latestdeparture =: 100000 origin} latestdeparture
  NB. Remove the chain from the origin node.  This is so that, if there is no further
  NB. solution, we detect it
  bestprevstation =: _1 origin} bestprevstation
end.
result
)
