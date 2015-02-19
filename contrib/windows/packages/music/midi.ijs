
require 'dll format'
coclass 'midi'

NB. The winapi declarations have moved around a bit historically,
NB. and its not always possible just to say 'require winapi'.  So:
winapi_path =. monad define
	select. ({.~  i.&'/') 9!:14''
	case. '4.01';'4.02'	do. 'system/examples/winapi/winapi'
	case.			do. 'system/packages/winapi/winapi'
	end.
)

'z' load winapi_path''


midiOutGetNumDevs =:'midiOutGetNumDevs' win32api
NB. Two are buggy in the J system distribution:
midiOutGetDevCapsA  =: 'winmm midiOutGetDevCapsA i i *c i'&cd
midiOutOpen =: 'winmm midiOutOpen i *i i i i i'&cd
midiOutShortMsg =: 'midiOutShortMsg' win32api
midiOutReset =: 'midiOutReset' win32api
midiOutClose =: 'midiOutClose' win32api


NB. A wrapper to return the device name given a device number:

midiOutGetDevName =: monad define "0
	caps=. midiOutGetDevCapsA  y. ; (100#' ') ; 100
	NB. The following relies on some "magic knowledge"
	NB. about the layout of the "capabilities" C structure:
	name=. ({.~ i.&(0{a.)) (8+i.32) { > 2{caps
)


sm=: midiOutShortMsg @ (".@('moh'"_) ; 256&#.@|.)

chprg	=: sm @ (192&,)				NB. cmd192  instr-nr(y.)
noteon	=: sm @ ((1})& 144 0 125) " 0		NB. cmd144  note(y.)  loudness
noteoff =: sm @ ((1})& 128 0 125) " 0		NB. cmd128  note(y.)  loudness


dp =: verb define "0 0
	2 dp y.
:
	noteon y. =. >y.
	6!:3  x. * 0.1
	empty noteoff y.
)


ndev =. > midiOutGetNumDevs ''
devlist=. midiOutGetDevName each i. ndev
mo_dev_idx=: 1 pick (<:ndev) wdselect 'Select the MIDI device' ; <devlist

NB. parameters are:
NB. *device_handle (will be set) ; device_index;
NB. callback_function; instance; flags (int!)
] r =: midiOutOpen (,9) ; mo_dev_idx ; 0 ; 0; 9-9
] moh =: 0{1 pick r

chprg 0		NB. acoustic grand piano

NB. Announce that we are up & running:
2 2 2 8 dp 51 51 51 48		NB. yaddadda-dah!


NB. export major tools:
export =: monad define
	dp_z_		=:dp_midi_
	chprg_z_	=:chprg_midi_
	midireset_z_	=:midiOutReset_midi_ bind moh
	midiclose_z_	=:midiOutClose_midi_ bind moh
	empty ''
)
export ''


