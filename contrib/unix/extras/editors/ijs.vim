set ai
set tags=TAGS,tags,$JLIB/TAGS,/usr/local/lib/j/TAGS

set iskeyword=N,B,a-z,.
syntax clear
syntax case match
" syntax keyword Comment NB.
syntax keyword Statement break. continue. for. do. end. if. elseif. else.
syntax keyword Statement return. select. case. fcase. try. catch.
syntax keyword Statement while. whilst.

syntax match string		/'[^']*'/
syntax match constant		/[0-9]\+/
syntax match function		/[a-zA-Z][a-zA-Z0-9_]*[ 	]*=[.:]/ " s+0,e-2
syntax match identifier		/[a-zA-Z][a-zA-Z0-9_]*/
" short tokens first because later matches will have precedence:
syntax match verb		/[][{=!#$%^*+[|;,<>?-]/
syntax match adverb		/[/\~}]/
syntax match conjunction	/[.:"@&`]/
syntax match copula		/=[.:]/
syntax match conjunction	/[!@^&_`DLS]:/
syntax match conjunction	/[;!@&dDHT]\./
syntax match adverb		/[/\~bft]\./
syntax match verb		/[-~#$%^*+|,{}<>?]\./
syntax match verb		/[AcCeEijLopr]\./
syntax match verb		/[ipq]:/
syntax match verb		/[-~#$%^*+[|;,{}<>?\/]:/
syntax match verb		/_\{0,1}[0-9]:/
syntax match placeholder	/[mnuvxy]\./
syntax match comment		/NB\..*/
syntax match strongcomment	/NB\.\*.*/

hi copula		guifg=black
hi conjunction		guifg=red gui=bold
hi adverb		guifg=orange gui=bold
hi verb			guifg=green gui=bold
hi placeholder		guifg=grey gui=bold
hi strongcomment	guifg=red
