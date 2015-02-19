NB. Set up environment and run a #!jrun or #!jconsole script.

NB. Useful nouns, defined in z locale:
18!:4 <'z'

ARGC=:$ARGV=: 2!:4 ''
LF=:NL=: 10{a.
JDIR=:1!:42''
SCRIPT=:SCRIPT}.~('#!'-:2{.SCRIPT)*>:0{#;._2 SCRIPT=:1!:1]0{ARGV

NB. Useful verbs:
exit=: 2!:55
getenv=: 2!:5
echo=: 1!:2&2
stdout=: 1!:2&4
stderr=: 1!:2&5
stdin=: 1!:1 bind 3 :. stdout

NB. return to base:
18!:4 <'base'

NB. Define script as verb (to allow use of control structures) and run:
(0 0$0)[3 : SCRIPT]0
exit 0
