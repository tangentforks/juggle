NB. typedef struct tagMIDIOUTCAPSA {
NB.     WORD    wMid;                  /* manufacturer ID */
NB.     WORD    wPid;                  /* product ID */
NB.     MMVERSION vDriverVersion;      /* version of the driver */
NB.     CHAR    szPname[MAXPNAMELEN];  /* product name (NULL terminated string) */
NB.     WORD    wTechnology;           /* type of device */
NB.     WORD    wVoices;               /* # of voices (internal synth only) */
NB.     WORD    wNotes;                /* max # of notes (internal synth only) */
NB.     WORD    wChannelMask;          /* channels used (internal synth only) */
NB.     DWORD   dwSupport;             /* functionality supported by driver */
NB. } MIDIOUTCAPSA

ctoi =: 3 : '256 #. a. i. |. y.'
NUL=.0{a.
zerocut =: {.~ i.&NUL

middlenum =. ".&.>@(1&{)@]`1:`]}~ "1

TC =: middlenum <;._1 ;._2 noun define
	w	2	ctoi
	W	4	ctoi
	c	1	[
	s	1	zerocut
	v	4	ctoi
)

SD =: middlenum <;._1 ;._2 noun define
	w	1	wMid
	w	1	wPid
	v	1	vDriverVersion
	s	32	szPname
	w	1	wTechnology
	w	1	wVoices
	w	1	wNotes
	w	1	wChannelMask
	W	1	dwSupport
)

expand_field =: monad define "1
	i=.({."1 TC) i. {. y.
	y. , }. i { TC
)

expand_record =: monad define
	y. =. expand_field y.
	sizes =. */"1 > 1 3 { "1 y.
	offsets =. 0, }: +/\ sizes
	y. ,. <"0 sizes ,. offsets
)
esd =. expand_record SD

cutter =: dyad define "1 1
	'basetype arraycnt name typelen conv length offset' =. x.
	datachars =. (offset + i. length) { y.
	name ; conv~ datachars
)
