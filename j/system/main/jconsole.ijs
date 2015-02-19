NB. jconsole  

ARGV=: 2!:4 ''
exit=: 2!:55
getenv=: 2!:5
echo=: 1!:2&2
stdout=: 1!:2&4
stderr=: 1!:2&5
stdin=: 1!:1 bind 3 :. stdout
jhelp=: 3 : 0
NB. for example, jhelp 'netscape'
if. ''-:y. do. 'for example, jhelp ''netscape''' return. end.
2!:1 y.,' ',JDIR_j_,'system/extras/help/index.htm &'
)
