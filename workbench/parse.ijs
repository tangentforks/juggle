NB. adverb which derives a verb which interprets the trailing
NB. character of a string as a delimiter.
split=: ;._2

NB. porting notes: In J7 (0 :4) gathers the following lines as a newline
NB. terminated string (up to a terminating line which is a right parenthesis
NB. alone on a line.  Also note that each of the following lines should
NB. contain five tab characters (and no space characters, the last
NB. character of each line should be a tab).
NB.
NB. parsetable is a 15 by 5 array where the first column is actions
NB. and the remaining four columns represent the pattern which
NB. triggers the action.

parsetable=:  <split split (0 : 0)
Monad1	$=(	v	n	?	
Monad2	$=(avn	v	v	n	
Dyad	$=(avn	n	v	n	
Adverb	$=(avn	nv	a	?	
Conj	$=(avn	nv	c	nv	
Forkv	$=(avn	v	v	v	
Hookv	$=(	v	v	?	
Forkc	$=(	ac	ac	ac	
Hookc	$=(	ac	ac	?	
Curry	$=(	c	nv	?	
Curry	$=(	nv	c	?	
Is	np	=	cavn	?	
Punct	(	cavn	)	?	
Deref	p	?	?	?	
GetNext	?	?	?	?	
)

NB. verb derived by syntax takes a single argument which is a triple:
NB. left side is region to be substituted, middle is substitution (or
NB. empty), right side is stack before substitution.  Verb is derived
NB. from a specification of allowable object types (if multipe types
NB. are possible, the first listed is the default).
syntax=: 4 : 0 &
   ('region';'sub';'stack')=: x.
   ('offset';'len')=: region
   sub=: sub [^:(*#sub) {.y.
   ". (-. ({.sub) e. y.) # 'error=:''domain error'''
   (offset{.stack), (<sub), (offset+len)}.stack
)

NB. verb derived by subst generates argument for verb derived by
NB. syntax.  Verb is derived from a specification of pre-set
NB. substitutions (arranged as a table where first column is "before"
NB. and second column is "after") and the substitution region.
subst=: 4 : 0 &
   ('table';'region')=: y.
   ('keys';'members')=:|:table
   pat=: x. {~ (+ i.)/region
   new=:(keys i.<pat){members,<''
   ". (new-:<0) #'error=:''domain error'''
   (<region),new,<x.
)

NB. handlers for actions

NB. verb to convert a name to its gerund
verb=: ,@".@(,&'`''''')@,@>

monads=: 0 2$''
Monad1=: 'n' syntax @ ((monads; 1 2) subst)
Monad2=: 'n' syntax @ ((monads; 2 2) subst)

dyads=:  0 2$''
Dyad=:   'n' syntax @ ((dyads; 1 3) subst)

adverbs=: 0 2$''
Adverb=: 'vnca' syntax @ ((adverbs; 1 2) subst)

conjs=:  0 2$''
Conj=:   'vnca' syntax @ ((conjs; 1 3) subst)

forkvs=: 0 2$''
Forkv=:  'v' syntax @ ((forkvs; 1 3) subst)

hookvs=: 0 2$''
Hookv=:  'v' syntax @ ((hookvs; 1 2) subst)

forkcs=: <@,"0&.>('aac';0),('cac';0),:'aaa';'a'
Forkc=:  'ca' syntax @ ((forkcs; 1 3) subst)

hookcs=: <@,"0&.>('ca';'a'),:'aa';'a'
Hookc=:  'ca' syntax @ ((hookcs; 1 2) subst)

currys=: 0 2$''
Curry=:  'a' syntax @ ((currys; 1 2) subst)

Is =:    2&}.

Punct =: 1&{ , 3&}.

GetNext =: 3 : 0 , ]
   ". (0 = # queue)#'error=:''syntax error'''
   t=:     {: queue
   queue=: }: queue
   t
)


NB. take a list of boxes which represents a flat list and return that list

print =: 1!:2&2
widths=: 20 _20 5 20 10
reform=: >@:(,&.>/)
form=: reform@:(,&' '&.>)^:(*@#)
format=: reform@:({.&.>) (,&' '&.>)


NB. top level function.  Right arg is text to be executed.
parse=: 3 : 0
   queue=: ;:'$ ',y.
   error=:''

   stack=: ''
   patterns=: }."1 parsetable
   t=: ":patterns,&.>' '
   patdisplay=: ((t{~<1 0)={."1 t)#((t{~<0 1)={.t)#"1 t
   actions=: {."1 parsetable
   handlers=: verb actions
   print widths format 'queue';'stack';'';'pattern';'action'

	i=.0
   whilst.
		((10>i=.>:i)) *. -. * (0=#queue)*('$'={.>{.stack)*2=#stack
   do.
		ind=: patterns match 4{.stack
		print widths format (form queue); (}:form stack); ''; (ind{patdisplay); >ind{actions
		stack=: (ind{handlers)\ stack
		if. #error do.
			print widths format (form queue); error; ''; ''; 'error'
			empty'' return.
		end.
   end.
   print widths format (form queue); (}:form stack); ''; ''; 'Accept'
	empty''
)

match =: i.&1 1 1 1 @:(([ = (<,'?')"_) +. {.&.>@] e.&>"1 [)
