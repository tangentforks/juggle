NB. standard J profile
NB.
NB. To set up your own profile, first make a copy of this file,
NB. then change the J startup parameter to point to the new file.
NB.
NB. 1. CONFIGFILE_j_ points to the configuration file. You can
NB.    create your own file, and do not need to change the
NB.    original config file (system/extras/config/config.ijs).
NB.
NB.    The config file can be customized within J by running
NB.    menu item: Edit|Configure...
NB.
NB. 2. The script boot.ijs then loads and runs the config file.
NB.    You do not need to change this line.
NB.
NB. 3. After the boot, you can add your own commands to
NB.    further customize the start up. By default there is a
NB.    command to display the J version number.

NB. =========================================================
NB. set name of config file:

CONFIGFILE_j_=: (1!:42''),'system/extras/config/config.ijs'

NB. =========================================================
NB. boot up J:

0!:0 <(1!:42''),'system/extras/util/boot.ijs'

NB. =========================================================
NB. Users can provide a ~/.ijrc and add their own commands there
0!:0 :: 0: < (2!:5'HOME'), '/.ijrc'
