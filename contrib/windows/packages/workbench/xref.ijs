NB. xref -- cross referencing tools for J programs.
NB. Most tools take namelists as argument, i.e. lists of boxed
NB. identifiers as returned by 4!:1 aka "nl".
NB.
NB. Historical background:
NB.   These utilities were written at the time of J3.04.
NB.   J had locales back then but neither the 18!: "cowhatever" foreigns,
NB.   in particular not the path feature, nor indirect locale references.
NB.   This code is therefore quite obscure/funny/naive in terms of both
NB.   its usage and treatment of locales.
NB    Also, this code was written in the context of the J WorkBench,
NB.   a development for primarily tacit J code.  The cross referencer
NB.   is currently too dump to deal with explicit definitions. :-o
NB. Improvements and fixes are welcome.
NB. BUGS:
NB. Cluster analysis is broken:  all "isolated" functions (functions
NB. which are selfstanding) are lumped into one common cluster.
NB. On "cnl" output, this is actually nice, but it is not correct.
NB. (A fix would be to fake self-calling.)

coclass 'xref'

NB. Our verbification adnoun (used to embed nouns in trains):
v=:"_

NB.  A few hooks which can be redefined if necessary.
NB.  (The WorkBench as an integrated development environment
NB.  does that, for example.  WRITE goes into a window there.)

xref_lrep_z_ =: 5!:5
xref_nl_z_ =: nl
xref_nc_z_ =: 4!:0
WRITE =: 1!:2&2

NB.  Our local lrep ("literal representation") forces
NB.  a name resolution from the perspective of the base
NB.  locale.
NB.  The no_ verb/adverbs implement filters to weed out
NB.  unwanted defintions.

no_expl =: ]`('[..explicit_def..]'v)@.(LF&e.)
no_undef =:  ('[..undefd..]'v`) @. (xref_nc__ e. 1 2 3 v)
no_extern =: ('[..extern..]'v`) @. (e. (xref_nl__@(''v)))
lrep =: xref_lrep__ no_extern no_undef

NB. Code for the caller/callee matrix.
NB. This matrix is first established with a direct "calls"
NB. relationship.  Each "imfam" iteration merges another
NB. "immediately familiar" calling level into the matrix.
NB. The closure will eventually stabilize, so we can use
NB. imfam^:_ for this process.

xref   =: > annotated callmat
xrefed =: > annotated |:@callmat

annotated =: (''v ; (4: {. |:)@[) ,: (; call_blobs)

calls =: (e. ;:@lrep)~"0
callmat =: calls/~

imfam =: [ +. +./ . *.
closure =: imfam^:_ ~
dir_indir =:  + closure@(0&<)
call_blobs =: dir_indir   { ' +*r'v
both_blobs =: ([: closure [: >: ] + 2: * |:) { ' C*+r'v
bool_blobs =: {&' *'


NB. The following functions run on top of the fundamental
NB. call graph analysis:

NB.*mains v identify top-level functions (those which are uncalled)
NB.form:	mains namelist
mains  =: #~ 0: = +/@callmat

NB.*leaves v identify leaf functions
NB. form:	leaves  namelist
leaves =: #~ 0: = +/"1@callmat

NB. "clusters" are sets of names which have internal calls.
NB. There are no "cross-calls" between clusters.
NB. We can eliminate much sparseness from the calling matrix
NB. by presenting just the cluster quads.  xrefclusters does this.
NB. The "callseq" sorting imposes mains-to-leaves order;  it not
NB. only helps to provide a better overview over the calling hierarchy,
NB. it is also used to emit J code with proper def-before-use order
NB. in "calltree" dumps.
clusters =: closure @ (+. |:) @ callmat
callseq =: (\: closure@callmat)
xrefclusters =: ,/ @: (clusters xref@callseq/. ])
cnl =: (clusters <@:>@callseq/. ]) @ xref_nl__


NB. A few tools to locate used names (callees) within an lrep.
NB. These are utterly naive.
abc =: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'v
NB. isname =: ({. e. abc) > {: e. '.:'v
isname =: (nc ~: _2:) " 0
subs =: ~. @ (#~ 0:`(e.&1 2 3 @ xref_nc__)@.isname) @ ;: @ lrep

NB. The internal dyad
NB. calltree v  expand calling names by adding their callees recursively.
NB. form:   nms calltree opts;lvl;stoplist
NB.	nms:		calling functions (problably the "subs" in our caller)
NB.     opts:		a string of options letters
NB.			'd': show tacit defintions
NB.			'D': show explicit and tacit definitions
NB.			'r': analyze/output in reversed order (bottom-up)
NB.			'l': extra line spacing between "level 0" functions
NB.	lvl:		traces the calling depth / indent level
NB.	stoplist:	traces analyzed names in order to cope with both
NB.			reuse (nice) and  recursion (important).
NB. The basic actions are:
NB. - show our nms
NB. - recurse through the subs of our nms.
NB. - add dealt-with nms to the stoplist; return that
NB. The order of these events depends on the 'r' option.
NB.
NB. An external calltree_z_ serves as the official entry point, see below.

calltree =: 4 : 0
	nms =. x.
	'opts lvl' =. 2 {. y.
	pfx =. (#&'  ') lvl
	stoplist =. 2}.y.
	opts =. opts , ('D' e.opts)#'d'
	opt =. e.&opts
	showrep =. no_expl ^:(-. opt 'D') @ lrep
	if. opt 'd' do.
		markalrdy =. 'NB.[^] '&,
	else.
		markalrdy =. ,&' [^]'
	end.
	markalrdy =. ,&' [^]'  NB. XXX why stopped the version above working???

	alrdy =. nms (e. # [) stoplist
	nms =. nms -. alrdy
	if. #alrdy do.
		WRITE pfx,  markalrdy (,;:^:_1 alrdy)
	end.

	while. #nms do.
		name =. {.nms
		if. -. name e. stoplist do.
			if. opt 'r' do.
				NB. reverse (bottom up) order, recurse
				NB. through leaves first
				stoplist =. stoplist,name
				callees =. subs name
				stoplist =. (callees) calltree (<opts),(<>:lvl),stoplist
			end.

			line =. (lvl#'  '), (>name)
			if. (opt 'd') do.
				line =. line , ' =: ', showrep name
			end.
			NB. line =. line, (name e. stoplist)#' [^]'
			WRITE line
			WRITE ^: ((lvl=0) *. opt 'l') ''

			if. -. opt 'r' do.
				NB. usually (non-reversed, top-down),
				NB. consider callees now:
				stoplist =. stoplist,name
				callees =. subs name
				stoplist =. (callees) calltree (<opts),(<>:lvl),stoplist
			end.
		end.
		nms =. (}.nms) -. stoplist
	end.
	stoplist
)

NB. set up the recursion and void its final stoplist result:
ctstart =: empty @ (cutopen@] calltree [ ; 0:)

NB. Exports

NB.*calltree v compute and dump the callees of one or more functions.
NB. form:	[option letters]  calltree  name(s)
NB.     optional option letters:
NB.		'd': show tacit definitions
NB.		'D': show tacit and explicit definitions
NB.		'r': analyze/output in reversed order (def-before-use)
NB.		'l': extra line spacing between "level 0" functions
NB.	names can be open ('fee foo fum') or a boxed namelist
NB.
NB. calltree returns EMPTY.  It uses the internal function WRITE_xref_
NB. to dump lines to the screen.
calltree_z_ =: ''&$: : ctstart_xref_

NB.*xref v compute the cross referencing matrix for the names
NB. form:	xref namelist
NB.
NB. In the output matrix, the names are repeated in the left column
NB. as callers and, abbreviated in the heading, as callees.
NB. A '*' indicates a direct call, a '+' an indirect one.
NB. An 'r' marks a recursive call.
xref_z_ =: xref_xref_

NB.*xrefclusters v	identify independent function clusters and
NB. 			give their ordered call matrixes.
NB. form: xrefclusters namelist
xrefclusters_z_ =: xrefclusters_xref_

NB.*cnl v function clusters for adverbs/conjunctions/verbs/nouns
NB. example:
NB.	cnl ''
NB.	cnl 1 2 3
cnl_z_ =: cnl_xref_

NB.*mains v identify top level functions
NB. form: mains namelist
mains_z_ =: mains_xref_

NB.*leaves v identify leaf functions
NB. form: leaves namelist
leaves_z_ =: leaves_xref_
