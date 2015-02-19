NB. THIS IS A TEST SCRIPT!
NB. NO PRODUCTION SOURCE HERE!

NB. jar - J ARchive generator

NB.                  jar 'some file names'
NB. 'export/foo.jar' jar 'some file names'
NB.
NB. create a script acting as self-extracting J archive.
NB. The monad returns the script as a LF-delimited string,
NB. the dyad uses "fwrites" to deposit the script into
NB. a file with system dependent line delimiters.

NB. For now, any directory information is deliberately
NB. discarded in the resulting jar.
NB. There should be some way to throw just a part of it
NB. away.

NB. The jar contains the files as (0 : 0) scripts.
NB. Every line is prefixed by a dot in order to be
NB. able to embed ')' lines.

NB. All components of the jar are first collected into
NB. boxed lines without any line delimiter at all.
NB. This applies also to embedded comments and code.
NB. "jarstring" converts them into a J script string
NB. (ie., with LF delimiters), and a fwrites would save
NB. the jar with system-dependent delimiters.
NB. During extraction, the lines are read in fret form,
NB. ie. a LF-delimited string.  Each line is boxed,
NB. individually toHOSTed and the raze is written to
NB. a file on the target system in the naive format there.
NB. Character counts may differ.

require 'files misc dates'

appinbox =: ,&.>
commented =: (<'NB. ') & appinbox
quoted =: (<'.') & appinbox
line_ended =: appinbox & (<LF)

v=:"_
at =: ,&":

prologue =: <;._2  (0 : 0)

To extract the files from this jar, just strip off
any mail headers and signatures etc. and run the
script in your J system.

With untrusted jars you should first check that
- all pathnames are OK,
- no harmful code is hidden in the jar, and
- that any code contained cannot do any harm.

The variable DESTINATION should help you to tweak the
directory where this jar gets spilled.
)

NB. The extraction code uses "toHOST" from the stdlib.

code =: <;._2 (0 : 0) 

DESTINATION_jar_ =: ''   NB. eg., 'packages\foo\', if applicable
destpath_jar_    =: <@(DESTINATION_jar_&,)
extract_jar_     =: ; @ (}.&.> @ (<;.2))
spill_jar_       =: toHOST@extract_jar_@] 1!:2 destpath@[

)

timestamp =: [: < 'This JAR was created on 'v , [: tstamp time

filename =: >@{:@pathname
sizes_and_names =: (10&":@fsize , ' 'v , filename) &.>
toc =: 'Contents:'v ; sizes_and_names
hdr =: [: commented timestamp , toc , prologue v

spill_cmd =: ''''v , filename@> , ''' spill_jar_ (0 : 0)'v
qbody =:  quoted @ ('b'&fread)
pickel =: ''v ; spill_cmd ; qbody ,  <@(')'v)
pickels =: ]`(pickel@{. , $:@}.) @. (*@#)

jarstring =: ; @: line_ended @ (hdr , code"_ , pickels) @cutopen
jar =: jarstring : (fwrites~ jarstring)

efn =: 3 : 0
	'debug me!'
	foo =. 12
	foo =. >:foo
	foo =. spill_cmd 'brutzel'
	{: foo
:
	NB. it's a catch
	22
)