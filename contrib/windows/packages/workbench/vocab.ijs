NB. The J vocabulary
NB. A two-column boxed table of primitive literal and official names

NB. The vocabulary is compiled out of 3 sections (V1,V2,V3).
NB. LF, TAB, and ',' are used as formal field delimiters

NB. V1: each line has exactly 4 TAB-introduced fields.
NB. Empty entries are removed in the last step.

V1 =. 0 : 0
	=	Self-Classify,Equal	Is (Local)	Is (Global)
	<	Box,Less Than	Floor,Lesser Of	Decrem,Less Or Equal
	>	Open,Larger Than	Ceiling,Larger Of	Increm,Larg Or Equal
	_	Negative/Infinity	Indeterminate	Infinity
	+	Conjugate,Plus	Real/Imag,GCD (Or)	Double,Not-Or
	*	Signum,Times	Len/Ang,LCM (And)	Square,Not-And
	-	Negate,Minus	Not (1&-),Less	Halve,Match
	%	Recip,Divided By	Mat Inv,Mat Divide	Square Root,Root
	^	Exponential,Power	Natural Log,Log	Power
	$	Shape Of,Shape		Self-Reference
	~	Reflex,Pass,Evoke	Nub,	Nub Sieve,Not-Eq
	|	Magnitude,Residue	Reverse,Rotate	Transpose
	.	Det,Dot Product	Even	Odd
	:	Explicit,Monad/Dyad	Obverse	Adverse
	,	Ravel,Append	Ravel Items,Stitch	Itemize,Laminate
	;	Raze,Link	Cut	Word Formation,
	#	Tally,Copy	Base 2,Base	Antibase 2,Antib
	!	Factorial,Out Of	Fit (Customize)	Foreign
	/	Insert,Table,Insert	Oblique,Key,Append	Grade Up,Sort
	\	Prefix,Infix,Train	Suffix,Outfix	Grade Down,Sort
	[	Same,Left	Lev	Cap
	]	Same,Right	Dex	Identity
	{	Catalogue,From	Head,Take	Tail,
	}	Item Amend,Amend	Behead,Drop	Curtail,
	"	Rank,Constant	Do	Format
	`	Tie (Gerund)		Evoke Gerund
	@	Atop	Agenda	At
	&	Bond/Compose	Under (Dual)	Appose
	?	Roll,Deal	Roll,Deal (fixed seed)	UNUSED
)

reorder_line =. ({. ,&.> ('';'.';':')"_) ,. }.
V1 =. reorder_line@(<;._1) ;._2 V1
V1 =. (#~ a:"_ ~: {:"1) ,/ V1

V2 =: <;._1 ;._2 (0 : 0)
	a.	Alphabet
	a:	Ace (boxed empty)
	A.	Atomic Permute
	b.	Boolean/Basic
	c.	Characteristic Vals
	C.	Cycle-Dir,Perm
	D.	Derivative
	D:	Secant Slope
	e.	Raze In,Member
	E.	,Member of Interval
	f.	Fix
	H.	Hypergeometric
	i.	Integer,Index Of
	I.	Integral
	j.	Imaginary,Complex
	L.	Level
	L:	Level
	NB.	Comment
	o.	Pi Times,Circle Fn
	p.	Polynomial
	p:	Prime
	q:	Prime Factors
	r.	Angle,Polar
	S:	Spread
	t.	Taylor Coefficient
	t:	Wgtd Taylor Coef
	T.	Taylor Function
	x:	Extend,
	{::	Map,Fetch
)

V3=. ( ,&':' ; 'Constant '&, , ' Fn'"_)@":"0 ] _9 + i. 19

pnc =. 3 : 0 "0
	try.
		". 'name =. ',>y.
		(4!:0 <'name') {;:'noun adverb conjunction verb buggy_pnc'
	catch.
		<'special'
	end.
)

vocabulary =: (, pnc@{.) "1 (V1,V2,V3)

spell_word =: 3 : 0 "0
	idx =. ({."1 vocabulary) i. y.
	if. idx<#vocabulary do.
		's n t'=. idx{vocabulary
		< n, ' (', t, ')'
	else.
		y.
	end.
)
