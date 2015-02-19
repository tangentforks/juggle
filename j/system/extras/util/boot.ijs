NB. standard j boot script
NB.

boot_z_=: 3 : '0!:0 <(1!:42 , ])y.'

boot_z_ 'system/main/stdlib.ijs'
boot_z_ 'system/main/colib.ijs'
boot_z_ 'system/main/jconsole.ijs'
boot_j_ 'system/main/loadlib.ijs'
boot_j_ 'system/main/jadelib.ijs'
boot_j_ 'system/extras/util/unix.ijs'

NB. Set prokey where the version supports it and the user has one
NB. defined:
(9!:31 :: 0:)  LF-.~": (1!:1) :: 0: <(getenv'HOME'),'/.j_prokey'

4!:55 <'boot_z_'
