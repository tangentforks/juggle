NB. built from project: source\api\regex\regex

require 'dll unixsyms'

coclass 'jregex'

NB. Regular expression pattern matching
NB.
NB. =========================================================
NB. main definitions:
NB.   rxmatch          single match
NB.   rxmatches        all matches
NB.
NB.   rxcomp           compile pattern
NB.   rxfree           free pattern handles
NB.   rxhandles        list pattern handles
NB.   rxinfo           info on pattern handles
NB.
NB. regex utilities:
NB.   rxeq             -:
NB.   rxin             e.
NB.   rxindex          i.
NB.   rxE              E.
NB.   rxfirst          {.@{    (first match)
NB.   rxall            {       (all matches)
NB.   rxrplc           search and replace
NB.   rxapply          apply verb to pattern
NB.
NB.   rxerror          last regex error message
NB.
NB. other utilities:
NB.   rxcut            cut string into nomatch/match list
NB.   rxfrom           matches from string
NB.   rxmerge          replace matches in string
NB.
NB. =========================================================
NB. Form:
NB.   here:  pat      = pattern, or pattern handle
NB.          phnd     = pattern handle
NB.          patndx   = pattern;index  or  phnd;index
NB.          str      = character string
NB.          bstr     = boxed list of str
NB.          mat      = result of regex search
NB.          nsub     = #subexpressions in pattern
NB.
NB.  mat=.  pat or patndx   rxmatch   str
NB.  mat=.  pat or patndx   rxmatches str
NB.
NB.  phnd=.                 rxcomp    pat
NB.  empty=.                rxfree    phnd
NB.  phnds=.                rxhandles ''
NB.  'nsub pat'=.           rxinfo    phnd
NB.
NB.  boolean=.        pat   rxeq      str
NB.  index=.          pat   rxindex   str
NB.  mask=.           pat   rxE       str
NB.  bstr=.           pat   rxfirst   str
NB.  bstr=.           pat   rxall     str
NB.  str=.     (patndx;new) rxrplc    str
NB.  str=.     patndx (verb rxapply)  str
NB.
NB.  errormsg=.             rxerror   ''
NB.
NB.  bstr             mat   rxcut     str
NB.  bstr=.           mat   rxfrom    str
NB.  str=.         new (mat rxmerge)  str

NB. =========================================================
NB. following defined in z:
NB.*rxmatch v single match
NB.*rxmatches v all matches
NB.*rxcomp v compile pattern
NB.*rxfree v free pattern handles
NB.*rxhandles v list pattern handles
NB.*rxinfo v info on pattern handles
NB.*rxeq v regex equivalent of -:
NB.*rxin v regex equivalent of e.
NB.*rxindex v regex equivalent of i.
NB.*rxE v regex equivalent of E.
NB.*rxfirst v regex equivalent of {.@{ (first match)
NB.*rxall v regex equivalent of { (all matches)
NB.*rxrplc v search and replace
NB.*rxapply v apply verb to pattern
NB.*rxerror v last regex error message
NB.*rxcut v cut string into nomatch/match list
NB.*rxfrom v matches from string
NB.*rxmerge v replace matches in string

NB. =========================================================
NB. J DLL interface.

NB. Locate file name for libc shared library:
NB. XXX use find_dll
rxdll=: '"/lib/',(>{:'cannot_find_libc'; /:~ 0{"1 ]1!:0 '/lib/libc.so.*'),'" '
rxcdm=: 1 : '(rxdll,x.)&(15!:0)'

NB. =========================================================
NB. J DLL calls corresponding to the four extended regular expression
NB. functions defined in The Single Unix Specification, Version 2

jregcomp=: 'regcomp i * *c i' rxcdm
jregexec=: 'regexec i * *c i * i' rxcdm
jregerror=:'regerror i i * *c i' rxcdm
jregfree=: 'regfree n *' rxcdm

NB. Global definitions used by the regex script functions

rxmp =: 50			NB. Maximum number of compiled patterns.
rxms =: 50          NB. Maximum number of sub-expressions per pattern.
rxlastrc =: 0
rxlastxrp =: 0		NB. memory address (JINT) (stored unboxed in rxpatterns):
rxpatterns =: |:(rxmp$<_1),.(rxmp$<0),.rxmp$<'' 
rxerrtxt =: 80$' '

NB. rxmatch=: 17!:0
rxmatch=: 4 : 0 
	if. lb=. 32 = 3!:0 x. do. ph =. >0{x. else. ph =. x. end.
	if. cx=. 2 = 3!:0 ph do. hx =. rxcomp ph
	else. rxlastxrp =: > 1{((hx =. ph) - 1) ({"1) rxpatterns end.
	nsub =. rxnsub rxlastxrp
	cols=. 2 NB. Number of columns in regexec() result extract.
	pmatch =. mema regmatch_t_sz*1+rxms
    rxlastrc =: >0{rv =. jregexec (<rxlastxrp) ; y. ; (>:rxms) ; (<pmatch) ; 0
    if. cx do. rxfree hx end.
	nr_match_pairs =. >: rxms <. nsub
	m =. (nr_match_pairs, cols) $ _1 0		NB. initialize with "no match here"
    if. 0=rxlastrc do. for_i. i. nr_match_pairs do.
		rm_so=. memr pmatch, (rm_so_off+i*regmatch_t_sz), 1, JINT
		if. rm_so ~: _1 do.
			rm_eo=. memr pmatch, (rm_eo_off+i*regmatch_t_sz), 1, JINT
			m =. (rm_so, rm_eo-rm_so) i} m
		end.
	end. end.
	memf pmatch
	if. lb do. (>1{x.){ m else. m end.
)
	
NB. rxmatches=: 17!:1
rxmatches=: 4 : 0
	if. lb=. 32 = 3!:0 x. do.
		ph =. >0{x. else. ph =. x. end.
	if. cx=. 2 = 3!:0 ph do.
		hx =. rxcomp ph else.	NB. rxcomp sets rxlastxrp
	    rxlastxrp =: > 1{((hx =. ph) - 1) ({"1) rxpatterns end.
	nsub =. rxnsub rxlastxrp
	o=. 0
	rxm =. (0, (>:nsub<.rxms), 2)$0
	while. 1 do.	
		if. _1 = 0{0{m =. hx rxmatch o}.y. do. break. end.
		m =. m +"1 o,0
		NB. XXX no padding should be necessary:
		NB. m =. (nsub, 2){. m,(nsub,2)$ _1 0
		rxm =. rxm , m
		NB. Advance the offset o beyond this match.
		NB. The match length can be zero (with the *? operators),
		NB. so take special care to advance at least to the next
		NB. position.  If that reaches beyond the end, exit the loop.
		o =. (>:o) >. +/0{m
		if. o >: #y. do. break. end.
	end.
	if. cx do. rxfree hx end.
	if. lb do. (>1{x.){"2 rxm else. rxm end.
)

NB. rxcomp=: 17!:2
rxcomp=: 3 : 0
	hx =. _1 i.~ >0 { rxpatterns
	NB. XXX check if  hx<rxmp
    compiled_rx =: mema regex_t_sz    NB. mema asserts worst-case alignment
	rxlastrc =: >0{rv =. jregcomp (<compiled_rx); y.; REG_EXTENDED+REG_NEWLINE
	rxpatterns =: ((<hx+1),(<compiled_rx),<y.) (<(<$0);hx)} rxpatterns 
	rxlastxrp =: compiled_rx
	hx + 1
)

rxnsub=: 3 : '{. memr y.,re_nsub_off,1,JINT'    NB. Number of subexpressions

NB. rxfree=: 17!:3
rxfree=: 3 : 0
	hx =. ,y. - 1
	while. 0<#hx do.
		ix =. 0{hx
		compiled_rx =. >1{ix ({"_1) rxpatterns
		if. 0 ~: compiled_rx do.
			jregfree ,<<compiled_rx
			memf compiled_rx
		end.
		rxpatterns =: ((<_1),(<0),<'') (<(<$0);ix)} rxpatterns
		hx =. }.hx
	end.
	i.0 0
)

NB. rxhandles=: 17!:4
rxhandles=: 3 : 0
	h=. >0{rxpatterns
	(h~:_1)#h
)

NB. rxinfo=: 17!:5
rxinfo=: 3 : 0
	i=. (y.-1){"1 rxpatterns
	|:(<"_1 >:rxnsub >1{i) ,: 2{i
)

NB. rxerror=: 17!:6
rxerror =: 3 : 0
({.~ i.&(0{a.)) >3{jregerror rxlastrc; (<rxlastxrp); rxerrtxt; #rxerrtxt
)


NB. =========================================================
rxfrom=: (<@:{~ {. + i.@{:)~"1
rxeq=: {.@rxmatch -: 0: , #@]
rxin=: _1: ~: {.@{.@rxmatch
rxindex=: #@] [^:(<&0@]) {.@{.@rxmatch
rxE=: i.@#@] e. {.@{."2 @ rxmatches
rxfirst=: {.@rxmatch >@rxfrom ]
rxall=: {."2@rxmatches rxfrom ]

NB. =========================================================
rxapply=: 1 : 0
:
if. L. x. do. 'pat ndx'=. x. else. pat=. x. [ ndx=. ,0 end.
if. 1 ~: #$ ndx do. 13!:8[3 end.
mat=. ({.ndx) {"2 pat rxmatches y.
r=. u.&.> mat rxfrom y.
r mat rxmerge y.
)

NB. =========================================================
rxcut=: 4 : 0
if. 0 e. #x. do. <y. return. end.
'beg len'=. |: ,. x.
if. 1<#beg do.
  whilst. 0 e. d do.
    d=. 1,<:/\ (}:len) <: 2 -~/\ beg
    beg=. d#beg
    len=. d#len
  end.
end.
a=. 0, , beg ,. beg+len
b=. 2 -~/\ a, #y.
f=. < @ (({. + i.@{:)@[ { ] )
(}: , {: -. a:"_) (a,.b) f"1 y.
)

NB. =========================================================
rxmerge=: 1 : 0
:
p=. _2 ]\ m. rxcut y.
;, ({."1 p),.(#p){.(#m.)$x.
)

NB. =========================================================
rxrplc=: 4 : 0
pat=. >{.x.
new=. {:x.
if. L. pat do. 'pat ndx'=. pat else. ndx=. ,0 end.
if. 1 ~: #$ ndx do. 13!:8[3 end.
mat=. ({.ndx) {"2 pat rxmatches y.
new mat rxmerge y.
)

NB. =========================================================
NB. define z locale names:
nms=. 0 : 0
rxmatch rxmatches rxcomp rxfree rxhandles rxinfo rxeq
rxin rxindex rxE rxfirst rxall rxrplc rxapply rxerror
rxcut rxfrom rxmerge
)

nms=. (nms e.' ',LF) <;._2 nms
". > nms ,each (<'_z_=:') ,each nms ,each <'_jregex_'

