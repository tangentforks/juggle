unused =. 0 : 0
menupop "&Trouble";
menu dbrst0 "reset &0" "" "reset, disabling debugging" "rst 0";
menu dbrst1 "reset &1" "" "reset, ensabling debugging" "rst 1";
menu dbrun "&continue" "" "execute up to the next stop" "cont";
menu dbstk "&show stack" "" "show current point and variables" "dbstk";
menu wdq "last &wd event" "" "show last wd event info (for Martin)" "wdqshow";
menupopz;
xywh 198 10 84 10;cc symbols edit leftmove rightmove;
xywh 96 10 34 10;cc run button;cn "&Run";
xywh 130 10 34 10;cc load button leftmove rightmove;cn "&Load";
xywh 0 10 45 10;cc detailed checkbox;cn "&Detailed";
xywh 45 10 51 10;cc everywhere checkbox;cn "&Everywhere";
)

WORKBENCH =: 0 : 0
pc workbench;
xywh 1 1 180 67;cc jx editm ws_hscroll ws_vscroll es_autohscroll es_autovscroll leftscale rightmove bottommove;
xywh 2 71 42 7;cc olabel static topmove bottommove;cn "on result:";
xywh 45 70 135 9;cc onres edit ws_border es_autohscroll topmove rightmove bottommove;
pas 0 0;
rem form end;
)

XREF =: 0 : 0
pc xref;
xywh 2 2 180 80 ;cc xref editm ws_hscroll ws_vscroll es_autohscroll es_autovscroll leftscale rightmove bottommove;
pas 0 0;
rem form end;
)

COMMENT =: 0 : 0
pc comment;
xywh 2 2 180 80 ;
cc notes editm ws_hscroll ws_vscroll es_autohscroll es_autovscroll leftscale rightmove bottommove;
pas 0 0;
rem form end;
)

ED=: 0 : 0
pc ed closeok;
xywh 0 0 90 67;cc ev editm ws_hscroll ws_vscroll es_autohscroll es_autovscroll rightscale bottommove;
xywh 90 0 90 67;cc ejx editm ws_hscroll ws_vscroll es_autohscroll es_autovscroll leftscale rightmove bottommove;
pas 0 0;
rem form end;
)

LAB=: 0 : 0
pc wb closeok;
menupop "&File";
menu close "&Close" "" "close the wb (unsaved)" "close";
menupopz;
menupop "&Script";
menu scrsel "&select script" "" "Choose the script file to work with" "select and read";
menu scrread "&read script" "" "read the script file again" "reread";
menu scrmerge "&merge script" "" "write the definitions into the selected script" "merge";
menusep ;
menu locale "set &locale" "" "select the locale to work in" "set locale";
menupopz;
menupop "&Definitions";
menu lruback "&backward" "Ctrl-B" "go back to previous definition" "previous";
menu lruforw "&forward" "Ctrl-F" "go forward to next definition" "next";
menu lruswap "&swap" "Ctrl-S" "switch forth and back between 2 defs" "swap";
menu load "&goto" "Ctrl-G" "go to any definition" "goto";
menu dfnew "&new" "Ctrl-N" "clear space for new definition" "new";
menu dfsave "&define" "Ctrl-D" "assign this phrase to a name" "assign to a new name";
menusep ;
menu rename "&rename" "" "rename the entry for the current definition" "rename";
menu drop "&erase" "" "retract this definition" "erase";
menu dfclear "&CLEAR" "" "clear ALL definitions and locale" "raze the wb";
menupopz;
menupop "&Xref";
menu xrffull "all call&trees" "" "calltree for entire locale" "xref locale";
menu xrfchildren "calltree for &verb" "" "calltree of current verb" "Indirect Callees";
menu xrfbottomup "Bottom-&up Trees" "" "show definitions before their uses in calls" "";
menusep ;
menu xrfmains "&main routines" "" "toplevel functions in the locale" "main routines";
menu xrfclusters "&clusters" "" "show call groups" "xref clusters";
menu xrfdirect "matri&x for calls" "" "show direct and indirect calls" "xref matrix";
menusep ;
menu locale "set &locale" "" "select the locale to work in" "set locale";
menupopz;
menupop "&Windows";
menu wdw2wb "&Lab pane" "" "switch over to the results pane" "Workbench pane";
menu wdw2comment "&comment pane" "" "edit/show the documentation on current verb etc." "Comments";
menu wdw2xref "&xref pane" "" "switch over to the cross-referencer output" "cross references";
menusep ;
menu wdwtop "&keep on top" "Ctrl-T" "keep workbench always on top of the screen" "top";
menu wdwtool "show &toolbar" "" "show toolbar even while Ctrl-combis would do a perfect job" "tools";
menu wdwstatus "show &statusbar" "" "show the statusbar with the shape info" "statusbar";
menupopz;
menupop "&Help";
menu parse "&syntax" "" "show how the phrase is parsed" "show groupings (and rank)";
menu rank "ran&k" "" "show how the rank of the phrase" "show rank (and parsing)";
menu spell "&vocabulary" "" "show the names of the primitives" "vocabulary";
menusep ;
menu about "&About" "" "some notes on this workbench" "";
menu tryit1 "&Tracer Intro" "" "Give the wb a try - see the tracer" "";
menu tryit2 "&Jumps Intro" "" "Give the wb a try - hyperjumps" "";
menusep ;
menu hlpjsm "&User Manual" "" "" "the official User Manual, online version";
menu hlpjsmid "Introduction and &Dictionary" "" "" "the official Introduction and Dictionary of J";
menu hlpjphr "&Phrases" "" "" "the ever amazing Phrases collection";
menusep ;
menu version "&Release Info" "" "version number, contact info, feature list" "";
menupopz;
tbar "contrib\windows\packages\workbench\workbench.bmp";
tbarset close 0 10  "get outta here (unsaved)" "close";
tbarset "" 1 20;
tbarset load 2 0  "goto another definition (selection or prompted)" "goto some definition";
tbarset lruswap 3 1  "swap between current and previous definition" "the other definition";
tbarset lruback 4 2  "go back in the chain" "backward";
tbarset lruforw 5 3  "...and forward again" "forward";
tbarset "" 6 10;
tbarset run 7 4  "run definitions with x/y arguments" "run";
tbarset detailed 8 5  "show detailed comments for selection" "Full Orchestration";
tbarset everywhere 9 6  "apply debugging to all parts of a larger selection" "debug subparts";
tbarset "" 10 10;
tbarset dfsave 11 7  "assign this phrase to a name" "define under name";
tbarset dfnew 12 11  "clear the fields" "clear";
tbarset "" 13 10;
tbarset parse 14 8  "show how the phrase is parsed" "syntax";
tbarset rank 15 9  "show the ranks of the phrase" "rank";
tbarset spell 16 12  "Names of primitives in the phrase" "vocabulary";
tbarshow;
rem disabled the "Full Orchestration" button until we fixed the rank problem;
rem explained further down below;
setenable detailed 0;
sbar 5 ;
sbarset sbhlp 60 "last result:";
sbarset sbshape 30 "shape";
sbarset sbcount 60 "count";
sbarset sbtype 30 "type";
sbarset sbrank 30 "rank";
sbarshow;
xywh 2 2 45 10;cc x edit ws_border es_autohscroll;
xywh 139 2 45 10;cc y edit ws_border group es_autohscroll leftmove rightmove;
xywh 48 2 90 10;cc v edit ws_border group es_autohscroll rightmove;
xywh 2 14 184 83;cc panespace staticbox ss_blackframe rightmove bottommove;
pas 0 0;
rem form end;
)

test_or_production =: ]			NB. select [ or ]
ww=: setjx

NB. It's a dirty job but someone's got to do it:
OUTPUT =: ''
WRITE =: 3 : 0
	if. # y. do.
		OUTPUT_wb_ =: OUTPUT_wb_, (flatten y.), CRLF
	end.
	y.
)
require 'trc'
WRITE_trc_ =: WRITE_wb_

'DF' mkfields 'name comment uses def'

init_globals =: 3 : 0
	Current_dir =: 'projects\lab\' test_or_production JDIR_j_
	Current_script =: (Current_dir, 'foo.ijs') test_or_production ''
	Locale =: ''  NB. i.e., the base locale

	deflist =: (0,(#fieldsDF)) $ ''
	lru_list =: 0#a:
	symbols=: 'scratch_wb_'
	edmode=:0
	notes =: ''
	wd 'pn "The J Workbench"'
)

dolocalized =: 3 : 0
	Locale dolocalized y.
:
	tbd =. 'do_',x.,'_ ', quote y.
	NB. 'about to be done for locale _',x.,'_:',LF,tbd
	". tbd
)

def_by_name =: 3 : 0
	idx =. (DFname {"1 deflist) i. y.
	if. idx<#deflist do.
		idx { deflist
	else.
		y. sDFname emptyDF
	end.
)


purgedefs =: #~ ({. ~: (<'scratch_wb_')"_)"1

merge_def =: 3 : 0
	idx =. (DFname&{"1 deflist) i. DFname{y.
	if. idx<#deflist do.
		deflist =: y. idx} deflist
	else.
		deflist =: deflist, y.
	end.
)

require 'xref'
xref_lrep_z_ =: gDFdef_wb_ @ def_by_name_wb_
xref_nl_z_ =: xref_nl_wb_
xref_nc_z_ =: xref_nc_wb_

xref_nl =: 3 : 0
	NB. I'm not very sure what would be the best way.
	NB. While 4!:1 would be closer to the truth,
	NB. the deflist-based answer is closer to the
	NB. workspace view and doesn't irritate the
	NB. xref computations based on xref_lrep_wb_.
	if. 1 do.
		z =. ({."1 deflist) -. (a:,<'scratch_wb_')
	else.
		if. y. -:'' do. y. =. 1 2 3 end.
		z =. Locale dolocalized '4!:1 ]', ": y.
	end.
	NB. 1!:2&2 y.;z
	z
)

xref_nc =: 3 : 0
	z =. Locale dolocalized '4!:0 <', quote >y.
	NB. 1!:2&2 y.;z
	z
)
WRITE_xref_ =: WRITE_wb_

wb_run=: 3 : 0
	NB. reentrance check
	if. (<'wb') e. <;._2 wd 'qp' do.
		wd 'psel wb; pshow sw_showmaximized'
		return.
	end.
	wd 'fontdef "Terminal" 9 oem'
	wd LAB
	PANES =: ;:'ed workbench xref comment'
	NB. wd 'set panes ', ;:^:_1 PANES
	wd 'creategroup panespace; '
	wd ED
	wd WORKBENCH
	wd XREF
	wd COMMENT
	wd 'creategroup'

	NB. initialize form here
	wd 'set detailed 0; set everywhere 0;'
	wd 'set xrfbottomup 0;'
	wd 'set wdwtool 1; set wdwstatus 1;'
	wd 'set wdwtop 0; ptop 0;'
	wd 'setfocus v; pshow sw_showmaximized;'

	NB. wd 'setselect panes 1'
	wd 'setshow workbench 1'
	Current_pane =: 'workbench'
	init_globals''
	NB. 13!:15 'wb_dbstk_button_wb_ 0'
)

to_edmode =: 3 : 0
	t=.   'set v "3 : ev_wb_";'
	t=.t, 'setenable v 0; setenable parse 0;'
	t=.t, 'setshow onres 1; setshow olabel 1;'
	wd t, 'setenable ev 1; setfocus ev;'
	edmode=:1
)

from_edmode =: 3 : 0
	t=.'setenable v 1; setenable parse 1;'
	wd t, 'setenable ev 0;'
	edmode=:0
)

setjx =: 3 : 0
	if. edmode do.
		wd 'set ejx *',y.
	else.
		wd 'set jx *',y.
	end.
)

to_pane =: 3 : 0
	if. Current_pane -: y. do. '' return. end.
	wd 'setshow ', Current_pane, ' 0;'
	wd 'setshow ', y., ' 1;'
	NB. wd 'setselect panes ', ": PANES i. <y.
	if.           y. -: 'ed' do.   to_edmode'' end.
	if. Current_pane -: 'ed' do. from_edmode'' end.
	Current_pane =: y.
)

wb_panes_button =: 3 : 0
	to_pane panes
)

wdoldfocus =: 3 : 0
	if. -. sysfocus e. 'xyvuv' do.
		NB. wd 'setfocus *', syslastfocus
		wd 'setfocus v'
	end.
	empty ''
)

cycle_focus=: 3 : 0
	cyccon =. ;: 'x ev y' [^:edmode 'x v y'
	new =. (#cyccon) | >: cyccon i. <sysfocus
	wd 'setfocus ', >new{cyccon
)

wb_close_button=: 3 : 0
	wd 'pclose;'
	NB. 13!:15 ''
)

para =:  '()'&$:  :  ({.@[ , ] , {:@[)

trc_splice =: 3 : 0
:
	(;:'start end') =. x.
	str =. y.
	if. start = end do.
		str return.
	end.
	hd =. start{.str
	tl =. end  }.str
	verb =. (end-start) {. start }. str
	
	NB. topts =. 'tc''', '''' ,~ > ('Lo';'LarsARp'){~ ". detailed
	NB. In the next line, we used to have "trc" for both cases
	NB. (undetailed and detailed).  However, the detailed variant
	NB. with "trc" generates verbs with unbounded rank which propagates
	NB. to higher levels, messing up the overall rank structure.
	NB. As long as don't know anything better to do, we use the
	NB. rank restricted variant "rtrc" in bith cases.
	topts =. > (' rtrc_trc_ ';' rtrc_trc_'){~ ". detailed
	if. ". everywhere do.
		trcdv =. topts gtc_trc_ verb
	else.
		trcdv =. '(', verb, ')', topts
	end.
	NB. level_prefix_trc_ =: ,(<0 _2) { 9!:6 ''  NB. vertical bar
	level_prefix_trc_ =: ,'|'
	hd , '( ', trcdv, ')' , tl
)

current_def =: 3 : 0
	d =. (x;y) sDFuses  symbols sDFname  notes sDFcomment  emptyDF
	if. edmode do.
		d =. ('3 : 0', LF, ev, LF, ')') sDFdef d
	else.
		d =. v sDFdef d
	end.
	d
)

dotest=: 3 : 0
	if. -.*#v do.
		t=.'put a phrase here!'
		wd 'set v *',t
		wd 'setselect v ', ":0, #t
		wd 'setfocus v'
		return.
	end.

	if. -. Current_pane-:'workbench' do.
		to_pane 'workbench'
	end.

	merge_def current_def ''
	dolocalized symbols, '=:', v
	wd 'psel wb'

	if. (#;:x) >: 2 do.
		x =. '(',x,')'
	end.
	
	v =. (". v_select) trc_splice v
	script =. ']rr_wb_=:r_wb_=: ', x,' ( ',v,' ) ',y
	OUTPUT =: ''
	try.
		dolocalized script
		wd 'psel wb'
	catch.
		wd 'psel wb'
		r =: 13!:12 ''
	end.
	NB. do__ script
	
	if. 0 ~: nc <'r' do. return. end.

	setjx OUTPUT, flatten r

	shape =. >(3 <. #$r) { 'atom ';'list ';'table '; 'rank-',":#$r
	shape =. ((+./ 0 1 e. $r) # '!!! '), shape
	wd 'set sbcount *', (":#r), ' items, ', (":*/$r), ' atoms'
	wd 'set sbrank *', shape
	wd 'set sbshape *', ":$r
	wd 'set sbtype *', >datatype r
	if. #onres do. workbench_onres_button '' end.
)

datatype =: 3 : 0
	if. 0 e. $y. do. 'whatever'
	elseif. (sc=.3!:0 y.)=2 do. 'literal'
	elseif. sc=32 do. 'boxed'
	elseif. 1 do. 'numeric'
	end.
)

wb_v_button=: 3 : 0
	if. edmode do.
		ed_run_button''
		return.
	elseif. sysfocus -: 'onres' do.
		workbench_onres_button''
		wd 'setfocus onres;'
		return.
	end.

	dotest ''
	wdoldfocus y.
)

wb_x_button =: wb_y_button=: wb_v_button
wb_run_button =: wb_v_button
wb_rctrl_fkey=: wb_v_button

ed_run_button=:	3 : 0
	ev =: ([ ww) (". ev_select) trc_splice ev

	v =: '3 : ev_wb_'
	dolocalized symbols, ' =: 3 : ev_wb_'
	merge_def current_def ''

	script =. ']rr_wb_=:r_wb_=: ', x,' ( ',v,' ) ',y
	OUTPUT =: ''
	try.
		dolocalized script
		wd 'psel wb'
	catch.
		wd 'psel wb'
		r =: 13!:12 ''
	end.
	NB. do__ script
	
	if. 0 ~: nc <'r' do. return. end.

	setjx OUTPUT, flatten r

	shape =. >(3 <. #$r) { 'atom ';'list ';'table '; 'rank-',":#$r
	shape =. ((+./ 0 1 e. $r) # '!!! '), shape
	wd 'set sbcount *', (":#r), ' items, ', (":*/$r), ' atoms'
	wd 'set sbrank *', shape
	wd 'set sbshape *', ":$r
	wd 'set sbtype *', >datatype r
	if. #onres do. workbench_onres_button '' end.

	wd 'setfocus ev'
)

wb_symbols_button=: 3 : 0
	NB. wdinfo '0'			NB. debug

	x =. y =. comment =. def =. ''
	if. (idx=. (DFname&{"1 deflist) i. <symbols) < #deflist do.
		(fieldsDF) =. idx{deflist
		if. 2=#uses do.
			x=. 0 pick uses
			y=. 1 pick uses
		end.
	else. try.
			def =. Locale dolocalized '5!:5 <''',symbols,''''
		catch.
			def =. 'Uh-oh.  Cannot find that one.'
			return.
		end.
	end.

	NB. wdinfo '1'			NB. debug

	wd 'psel wb'
	wd 'pn *', symbols, ('_'para Locale), '  ', '[]'para Current_script
	lru_list =: a: -.~ ~. symbols ; lru_list

	wd 'set x *', x
	wd 'set y *', y
	wd 'set notes *', comment

	if. LF e. def do.
		firstlf =. def i. LF
		clopar =. - >: (|.def) i. ')'
		NB. wd 'set v *', firstlf {. def
		wd 'set v "3 : ev_wb_";'
		wd 'set ev *', (>:firstlf) }. clopar }.def
		to_pane 'ed'
	else.
		wd 'set v *', def
		v =: def
		Locale dolocalized symbols, '=:', v
		to_pane 'workbench'
		setjx (wb_parse_button''), LF, LF, comment
	end.

	NB. empty wdinfo '2'		NB. debug
	NB. wd 'psel wb'			NB. debug
)

selected_name =: 3 : 0
	1 selected_name y.
:
	windowlist =. ;:'v ev jx ejx xref notes'
	while. *#windowlist do.
		w =. >{. windowlist
		's e' =. ". ". w,'_select'
		if. s~:e do.
			if. x. do.
				nm =. s id_stretch ".w
			else.
				nm =. (s+i.e-s){ ".w
			end.
			NB. Ignore non-identifiers:
			if. *#nm do.
				NB. Reset the selection once it is taken.
				NB. Otherwise users would have explicitly
				NB. to unselect names after use.
				wd 'setselect ', w, ' ', ":s,s
				nm return.
			end.
		end.
		windowlist =. }. windowlist
	end.
	''
)

selected_whatever =: 0&selected_name

wb_load_button=: 3 : 0
	nm =. selected_name''
	if. -.*#nm do.
		wd 'ptop 0;'
		n =. (DFname {"1 deflist) -.a:
		ix=. > (0 0"_`wdselect @.(*@#)) n
		nm =. ({.ix) # > ({:ix){n,<'arf'
		wd 'psel wb; ptop ',wdwtop
	end.

	if. #nm do.
		symbols =: nm
		wb_symbols_button ''
	end.
	wdoldfocus ''
)

wb_xrfmains_button =: 3 : 0
	to_pane 'xref'
	wd 'set xref "[computing main verbs, please be patient]"'
	m =. mains xref_nl 3
	wd 'set xref *', flatten >m
	wdoldfocus''
	m
)

wb_xrfclusters_button =: 3 : 0
	to_pane 'xref'
	wd 'set xref "[computing main verbs, please be patient]";'
	m =. cnl_xref_ 3
	wd 'set xref *', flatten m
	wdoldfocus''
)

wb_xrfdirect_button =: 3 : 0
	to_pane 'xref'
	wd 'set xref "[computing clusters, please be patient]"'
	m =. xrefclusters xref_nl 3
	wd 'set xref *', ; _2 <@(flatten@": , LF"_)\ m
	wdoldfocus''
	m
)

wb_xrffull_button =: 3 : 0
	mains =. wb_xrfmains_button ''
	OUTPUT =: ''
	((".xrfbottomup)#'r') calltree mains
	wd 'set xref *', OUTPUT
	wdoldfocus''
)

wb_xrfchildren_button =: 3 : 0
	to_pane 'xref'
	OUTPUT =: ''
	(((".xrfbottomup)#'r'),'d') calltree <symbols
	wd 'set xref *', OUTPUT
	wdoldfocus''
)

wb_parse_button=: 3 : 0
	if. -. *#v do. '' return. end.

	NB. use a local name here.
	dolocalized 'justaname_wb_ =: ',v
	out =. ''
	out =. out, '     linear:    ', (5!:5 <'justaname_wb_'), LF
	out =. out, 'full parens:    ', (5!:6 <'justaname_wb_'), LF
	out =. out, (flatten 5!:2 <'justaname_wb_'), LF		NB. boxed repr.
	setjx out
	wdoldfocus y.
	out
)

wb_rank_button=: 3 : 0
	if. -. *#v do. '' return. end.

	NB. use a local name here.
	dolocalized 'justaname_wb_ =: ',v
	if. 3 = 4!:0 <'justaname' do.
		ich_auch_wrxlwrx =. 'Ranks: ', ": justaname b. 0
	else.
		ich_auch_wrxlwrx =. 'This is not a verb, so it has no rank'
	end.
	out =. ich_auch_wrxlwrx
	setjx out
	wdoldfocus y.
	out
)

wb_spell_button=: 3 : 0
	sel =. selected_whatever''
	if. -.*#sel do.
		sel =. v
	end.
	if. -.*#sel do.
		sel =. wdprompt 'lookup primitives in vocabulary'
	end.
	if. -. *#sel do. '' return. end.
	NB. to_pane 'workbench'
	t=.flatten ;"1 (4&{.&.> , (<' ')"_ , spell_word)"0 ~. ;: sel
	setjx t
)


NB. optional x. decides on explicit(o) or tacit(1, default) mode.

workbench_onres_button=: 3 : 0
	1 workbench_onres_button y.
:
	if. -.*#onres do.
		to_pane 'workbench'
		wd 'setfocus onres'
		return.
	end.
	if. x. do.
		onres =. (para onres) , ' r_wb_'
	end.
	script =. 'rr_wb_ =: ',onres
	try.
		Locale dolocalized script
		wd 'psel wb'
		setjx flatten rr
	catch.
		wd 'psel wb'
		setjx (13!:12''),LF,'(result unchanged)',LF,flatten r
	end.
)

workbench_ressave_button=: 3 : 0
	name =. wdprompt :: (''"_) 'Name for result'

	if. -. *#name do. return. end.
	Locale dolocalized name,'=:rr_wb_'
	''
)

wb_ictrl_fkey =: 0&workbench_onres_button

wb_z_ =: wb_run_wb_

wb_wdq_button=: wdoldfocus@wdqshow

wb_everywhere_button =: wb_detailed_button=: wdoldfocus

wb_scrsel_button=: 3 : 0
	wd 'ptop 0'
	t=.'mbopen "select a J script file" '
	t=.t, Current_dir, ' "" "J(*.ijs)|*.ijs"'
	NB. wdinfo t
	s =. wd t
	wd 'psel wb; ptop ', wdwtop
	if. -.*#s do. '' return. end.

	Current_script =: s
	Current_dir =: 0 pick pathname Current_script
	wb_scrread_button''
)

wb_scrread_button=: 3 : 0
	txt =. toJ 1!:1 <Current_script
	Locale dolocalized '(0!:010) <''',Current_script, ''''
	dl =. read_script_ana_ txt
	deflist =: 1 1j1 1 #"1 dl
	lru_list =: 0#a:
	to_pane 'comment'
	NB. XXX actually, this should be a comment.
	NB. XXX but for the conference demo, redirect it:
	setjx gDFcomment {. deflist
)

wb_scrmerge_button =: 3 : 0
	if. 0 * #Current_script do.
		txt =. toJ 1!:1 <Current_script
	else.
		txt =. ,LF
	end.
	newscript =. (1 1 0 1#"1 purgedefs deflist) merge_script_ana_ txt
	if. #Current_script do.
		txt =. (toHOST newscript) 1!:2 <Current_script
	end.
	ww newscript
)


wb_locale_button=: 3 : 0
	Locale =: wdprompt 'Locale to load scripts and work in'
)

wb_wdwtop_button=: 3 : 0
	wd 'ptop ', wdwtop
)
wb_tctrl_fkey =: wb_wdwtop_button

wb_wdwtool_button=: 3 : 0
	wd 'tbarshow ',wdwtool
)
wb_wdwstatus_button=: 3 : 0
	wd 'sbarshow ', wdwstatus
)


wb_lruback_button=: lru_shift bind 1
wb_lruforw_button=: lru_shift bind _1
wb_actrl_fkey =: cycle_focus
wb_octrl_fkey =: wd@('setfocus onres'"_)

wb_fctrl_fkey =: wb_lruforw_button
wb_bctrl_fkey =: wb_lruback_button
wb_sctrl_fkey =: wb_lruswap_button
wb_gctrl_fkey =: wb_load_button
wb_dctrl_fkey =: wb_dfsave_button
wb_nctrl_fkey =: wb_dfnew_button

lru_shift =: 3 : 0
	if. 2>#lru_list do. 0 return. end.
	lru_list=: y. |. lru_list
	symbols =: >{.lru_list
	wb_symbols_button ''
)

wb_lruswap_button =: 3 : 0
	if. 2>#lru_list do. 0 return. end.
	lru_list=: (<0 1) C. lru_list
	symbols =: >{.lru_list
	wb_symbols_button ''
)

wb_dfsave_button=: 3 : 0
	if. sysfocus-:'onres' do.
		workbench_ressave_button''
		return.
	end.
	name =. wdprompt :: (''"_) 'Name for ', 'explicit definition'[^:edmode v

	if. -. *#name do. return. end.
	symbols =: name
	if. *#symbols do.
		lru_list =: ~. symbols ; lru_list
	end.
	merge_def name sDFname current_def ''
	wd 'pn *', symbols, ('  ', '_'para Locale), '  ', '[]'para Current_script
	if. edmode do.
		dolocalized symbols, '=: 3 : ev_wb_'
	else.
		dolocalized symbols, '=:', v
	end.
	''
)

workbench_nctrl_fkey =: 3 : 0
	wd 'set onres "";'
	onres=:''
)

NB. (allflag) wb_dfnew_button ''
NB. This flag indicates if just "v" (0) or "x/v/y/onres" (1) is to be cleared.
NB. Bound to Ctrl-N and a tool button.  One single or two successive strokes
NB. will give you what you want.  The right arg is never used.

wb_dfnew_button=: 3 : 0
	(-.*#".sysfocus) wb_dfnew_button y.
:
	symbols =: 'scratch_wb_'
	wd 'pn *The J WorkBench ', ('_' para Locale), ' ','[]'para Current_script
	wd 'set ev ""; set v "";'
	wd 'set notes "";'
	v=:ev=:notes=:''
	if. x. do.
		wd 'set x ""; set y "";'
		wd 'set ev ""; set onres "";'
		x=:y=:onres=:''
	end.
	wd 'setfocus v'
)

wb_dfclear_button=: 3 : 0
	clear l=.Locale
	init_globals
	Locale =: l
	1 wb_dfnew_button ''
)

wb_about_button =: 3 : 0
	to_pane 'comment'
	wd 'set notes *', ABOUT
)

wb_version_button =: 3 : 0
	wdinfo VERSION
)

wb_tryit1_button =: 3 : 0
	to_pane 'comment'
	wb_dfnew_button ''
	wd 'set x "5 9"; set v "+ *"; set y "i. 2 6";'
	wd 'set notes *', TRYIT1
)

wb_tryit2_button =: 3 : 0
	to_pane 'comment'
	wd 'set notes *', TRYIT2
)

wb_dbrst0_button=: 3 : 0
	13!:0 (0)
)

wb_dbrst1_button=: 3 : 0
	13!:0 (1)
)

wb_dbrun_button=: 3 : 0
	13!:4 ''
)

wb_dbstk_button=: 3 : 0
	wd 'set xref *', flatten ": 13!:13 ''
	to_pane 'xref'
)

helpwin=:wd@(('winexec *winhelp ',(1!:40''),'extras\help\')&,)

wb_hlpjsm_button=: helpwin bind 'jsm.hlp'
wb_hlpjsmid_button=: helpwin bind 'jsmid.hlp'
wb_hlpjphr_button=: helpwin bind 'jphr.hlp'

wb_wdw2wb_button=: to_pane bind 'workbench'
wb_wdw2comment_button=: 3 : 0
	to_pane 'comment'
	wd 'setfocus notes'
)

wb_wdw2xref_button=:to_pane bind 'xref'
