
NB. built from project: source\api\mapped\mapped

require 'dll syscalls unixsyms files'

coclass 'jmf'

NB. init

".(_1=4!:0<'mappings')#'mappings=:i.0,7' NB. set mappings first time

SZI=: 4            NB. size of integer
HS=: SZI*7+64      NB. header size
AFRO=: 1           NB. header flag - readonly
AFNJA=: 2          NB. header flag - non-J allocation
NULLPTR=: <0

j=. (GENERIC_READ+GENERIC_WRITE),PAGE_READWRITE,FILE_MAP_WRITE
RW=: j,:GENERIC_READ,PAGE_READONLY,FILE_MAP_READ

CloseHandleR=: >@{.@('kernel32 CloseHandle i i'&(15!:0))
CreateFileMappingR=: >@{.@('kernel32 CreateFileMappingA i i * i i i *c'&(15!:0))
CreateFileR=: >@{.@('kernel32 CreateFileA i *c i i * i i i'&(15!:0))
FlushViewOfFileR=: >@{.@('kernel32 FlushViewOfFile i i i'&(15!:0))
GetFileSizeR=: >@{.@('kernel32 GetFileSize i i *i'&(15!:0))
MapViewOfFileR=: >@{.@('kernel32 MapViewOfFile i i i i i i'&(15!:0))
OpenFileMappingR=: >@{.@('kernel32 OpenFileMappingA i i i *c'&(15!:0))
SetEndOfFile=: >@{.@('kernel32 SetEndOfFile i i'&(15!:0))
SetFilePointerR=: >@{.@('kernel32 SetFilePointer i i i *i i'&(15!:0))
UnmapViewOfFileR=: >@{.@('kernel32 UnmapViewOfFile i *'&(15!:0))
WriteFile=: 'kernel32 WriteFile i i * i *i *'&(15!:0)

NB. util

symget=: 15!:6 NB. get address of locale entry for name
symset=: 15!:7 NB. set name to address header
allochdr=: 15!:8 NB. allocate header
freehdr=: 15!:9 NB. free header

NB. =========================================================
msize=: 3 : 'memr y.,8 1,JINT'
refcount=: 3 : 'memr y.,16 1,JINT'

NB. =========================================================
win32_free=: 3 : 0
'fh mh fad'=. y.
if. fad do. UnmapViewOfFileR <<fad end.
if. mh do. CloseHandleR mh end.
if. fh~:_1 do. CloseHandleR fh end.
)

free=: 3 : 0
'fh mh fad'=. y.
if. fad do. c_munmap (<fad);mh end.
if. fh~:_1 do. c_close fh end.
)

NB. =========================================================
fullname=: 3 : 0
y.=. y.-.' '
y.,('_'~:{:y.)#'_base_'
)

NB. =========================================================
mbxcheck=: 3 : 0
x=. 15!:12 y.                 NB. 3 col integer matrix
b=. 0={:"1 x                  NB. selects code 0
'a s c'=. |: (-.b)#x          NB. address (sorted), size, code
'u n z'=. ,b#x                NB. address 0, length, junk
z=. *./ c e. 1 2              NB. code must be 1 or 2
z=. z, (-:<.) 2^.s            NB. sizes are powers of 2
z=. z, (}.a)-:}:a+s           NB. blocks are contiguous
z=. z, u = {.a                NB. first block begins at address 0
z=. z, ({:a+s) <: u+n         NB. last block is within bounds
z=. z, (-: <.) 64 %~ +/s      NB. total block sizes is multiple of 64
z=. z, (+/s) = <.&.(%&64) n   NB. total block sizes matches rounded total size
z=. z, *./ 0 = 8|a            NB. addresses are doubleword aligned
)

NB. =========================================================
NB. set shape of mapped noun
settypeshape=: 3 : 0
'name type shape'=: y.
rank=. #shape
sad=. symget <fullname name
'bad name' assert sad
had=. 1{s=. memr sad,0 4,JINT
'flag msize'=. memr had,4 2,JINT
'not mapped and writeable' assert 2=flag
size=. (JTYPES i.type){JSIZES
ts=. size**/shape
'msize too small' assert ts<:msize
type memw had,12 1,JINT
((*/shape),rank,shape) memw had,20,(2+rank),JINT
i.0 0
)

NB. =========================================================
win32_share=: 3 : 0
'name sn'=. y.
name=. fullname name
c=. #mappings
assert c=({."1 mappings)i.<name['noun already mapped'
4!:55 <name
'bad noun name'assert ('_'={:name)*._1=nc<name
fh=. _1
fn=. ''
mh=. OpenFileMappingR FILE_MAP_WRITE;0;sn,{.a.
if. mh=0 do. assert 0[CloseHandleR fh['bad mapping' end.
fad=. MapViewOfFileR mh;FILE_MAP_WRITE;0;0;0
if. fad=0 do. assert 0[CloseHandleR mh[CloseHandleR fh['bad view' end.
had=. fad
hs=: 0
ts=. memr had,8,1,JINT
mappings=: mappings,name;fn;sn;fh;mh;fad;had;ts
(name)=: symset had  NB. set name to address header
i.0 0
)

NB. =========================================================
showmap=: 3 : 0
h=. 'name';'fn';'sn';'fh';'mh';'address';'header';'msize';'refs'
hads=. 6{"1 mappings
h,mappings,.(msize each hads),.refcount each hads
)

NB. =========================================================
NB. 1 if jmf header is: big enough, offset=HS, msize=ts-HS, valid JTYPE
validate=: 3 : 0
'ts had'=. y.
if. ts>:HS do.
  d=. memr had,0 4,JINT
  *./((HS,ts-HS)=0 2{d),1 2 4 8 16 32 e.~ 3{d
else. 0 end.
)

NB. jmf - main definitions
NB.
NB.  additem
NB.  createjmf
NB.  map
NB.  showle
NB.  ts
NB.  unmap
NB.  unmapall

NB. =========================================================
NB. add item to mapped noun
additem=: 3 : 0
sad=. symget <fullname y.
'bad name' assert sad
had=. 1{s=. memr sad,0 4,JINT
'flag msize type rank'=. 1 2 3 6{memr had,0 28,JINT
'not mapped and writeable' assert 2=flag
'scalar' assert 0~:rank
shape=. memr had,28,rank,JINT
shape=. shape+1,0#~rank-1
size=. (JTYPES i.type){JSIZES
ts=. size**/shape
'msize too small' assert ts<:msize
((*/shape),rank,shape) memw had,20,(2+rank),JINT
i.0 0
)

NB. =========================================================
NB. createjmf fn;msize
win32_createjmf=: 3 : 0
'fn msize'=. y.
ts=: HS+msize     NB. total file size
fh=. CreateFileR fn;(GENERIC_READ+GENERIC_WRITE);0;NULLPTR;CREATE_ALWAYS;0;0
SetFilePointerR fh;ts;NULLPTR;FILE_BEGIN
SetEndOfFile fh
SetFilePointerR fh;0;NULLPTR;FILE_BEGIN
d=. HS,AFNJA,msize,JINT,0,0,1,0 NB. integer empty list
WriteFile_jmf_ fh;d;(SZI*#d);(,0);<NULLPTR_jmf_
CloseHandleR fh
)

createjmf=: 3 : 0 NB. createjmf fn;msize
'fn msize'=.y.
ts=:HS+msize     NB. total file size
NB. fh=.CreateFileR fn;(GENERIC_READ+GENERIC_WRITE);0;NULLPTR;CREATE_ALWAYS;0;0
NB. SetFilePointerR fh;ts;NULLPTR;FILE_BEGIN
NB. SetEndOfFile fh
NB. SetFilePointerR fh;0;NULLPTR;FILE_BEGIN
fh=.0 pick c_open fn; (OR/ O_RDWR, O_CREAT, O_TRUNC); 8b666
c_lseek fh;(<:ts);SEEK_SET
c_write fh; (,0{a.); 0+1   NB. place a single byte at the end
c_lseek fh;0 ;SEEK_SET
d=.HS,AFNJA,msize,JINT,0,0,1,0 NB. integer empty list
NB. WriteFile_jmf_ fh;d;(SZI*#d);(,0);<NULLPTR_jmf_
c_write fh;d;(SZI*#d)
NB. CloseHandleR fh
c_close fh
)

NB. =========================================================
NB. [type [,trailing_shape]] map name;filename [;sharename;ro]
win32_map=: 3 : 0
0 map y.
:
if. 0=L.x. do. x=. <&> x. else. x=. x. end. 
'type tshape'=. 2 {. x, a:

'trailing shape may not be zero' assert -. 0 e. tshape

'name fn sn ro'=. 4{.y.,(#y.)}.'';'';'';0
name=. fullname name
c=. #mappings

'name already mapped'assert c=({."1 mappings)i.<name
'filename already mapped'assert c=(1{"1 mappings)i.<fn
'sharename already mapped'assert (''-:sn)+.c=(2{"1 mappings)i.<sn
4!:55 <name
'bad noun name'assert ('_'={:name)*._1=nc<name

ro=. 0~:ro
aa=. AFNJA+AFRO*ro     NB. readwrite/readonly array access
ro=. ro*type~:0        NB. jmf file must be mapped read/write
'fa ma va'=. ro{RW     NB. readwrite/readonly for file, map, view access
fh=. CreateFileR (fn,{.a.);fa;0;NULLPTR;OPEN_EXISTING;0;0
'bad file name/access'assert fh~:_1
ts=. GetFileSizeR fh;<NULLPTR
mh=: CreateFileMappingR fh;NULLPTR;ma;0;0;(0=#sn){(sn,{.a.);<NULLPTR
if. mh=0 do. 'bad mapping'assert 0[free fh,0,0 end.
fad=. MapViewOfFileR mh;va;0;0;0
if. fad=0 do. 'bad view'assert 0[free fh,mh,0 end.

if. 0=type do.
  had=. fad
  if. 0=validate ts,had do. 'bad jmf header' assert 0[free fh,mh,fad end.
  aa memw had,4,1,JINT
  1 memw had,16,1,JINT    NB. ref count is 1
else.
  had=. allochdr 127                   NB. allocate header
  bx=. JBOXED=type
  lshape=. bx}.<.ts%(*/tshape)*JSIZES {~ JTYPES i. type
d=. fad-had
  if. d < - 2^31 do. d=. <. d + 2^32
  elseif. d >: 2^31 do. d=. <. d -~ 2^32
  end.
  h=. d,aa,ts,type,1,(*/lshape,tshape),((-.bx)+#tshape),lshape,tshape
  h memw had,0,(#h),JINT  NB. set header
end.

mappings=: mappings,name;fn;sn;fh;mh;fad;had
(name)=: symset had  NB. set name to address header
i.0 0
)

map=: 3 : 0 
0 map y.
:
if. 0=L.x. do. x=. <&> x. else. x=. x. end. 
'type tshape'=. 2 {. x, a:

'trailing shape may not be zero' assert -. 0 e. tshape

'name fn sn ro'=. 4{.y.,(#y.)}.'';'';'';0
name=. fullname name
c=.#mappings

'name already mapped'assert c=({."1 mappings)i.<name
'filename already mapped'assert c=(1{"1 mappings)i.<fn
'sharename already mapped'assert (''-:sn)+.c=(2{"1 mappings)i.<sn
4!:55 <name
'bad noun name'assert ('_'={:name)*._1=nc<name

ro=.0~:ro
aa=.AFNJA+AFRO*ro     NB. readwrite/readonly array access
ro=.ro*type~:0        NB. jmf file must be mapped read/write

NB. 'fa ma va'=. ro{RW    NB. readwrite/readonly for file, map, view access
NB.  XXX correct these values

ts=. fsize fn
fh=. >0 { c_open fn;O_RDWR;0
'bad file name/access' assert fh~:_1

NB.  unix doesn't use a mapping handle; 
NB.  however, we need to keep the length in the mapping list.
mh =. ts  

NB.  hard wire some values : protection flags (3) == read & write
NB.     mapping flags (2) == private;  (1) == shared
fad =. >0{ c_mmap (<0);ts;(OR/ ro}. PROT_WRITE, PROT_READ);MAP_SHARED;fh;0
if. fad=0 do. 'bad view'assert 0[free fh,mh,0 end.

if. 0=type do.
 had=. fad
 if. 0=validate ts,had do. 'bad jmf header' assert 0[free fh,mh,fad end.
 aa memw had,4,1,JINT
 (,0+1) memw had,16,1,JINT    NB. ref count is 1
else.
  had=. allochdr 127                   NB. allocate header
  bx=. JBOXED=type
  lshape=. bx}.<.ts%(*/tshape)*JSIZES {~ JTYPES i. type
d=. fad-had
  if. d < - 2^31 do. d=. <. d + 2^32
  elseif. d >: 2^31 do. d=. <. d -~ 2^32
  end.
  h=. d,aa,ts,type,1,(*/lshape,tshape),((-.bx)+#tshape),lshape,tshape
  h memw had,0,(#h),JINT  NB. set header
end.

mappings=: mappings,name;fn;sn;fh;mh;fad;had
(name)=: symset had  NB. set name to address header
i.0 0
)


NB. =========================================================
showle=: 3 : 0
le=. memr (symget <fullname y.),0 4,JINT
had=. 1{le
h=. memr had,0 7,JINT
s=. memr had,28,(6{h),JINT
le;h;s
)

NB. =========================================================
NB. [force] unmap name - 0 ok, 1 not mapped, 2 refs
unmap=: 3 : 0
0 unmap y.
:
n=. <fullname y.
row=. ({."1 mappings)i.n NB. row in mappings

if. row=#mappings do. 1 return. end.  NB. not mapped

m=. row{mappings
4!:55 n NB. erase name

'fh mh fad had'=. 4{.3}.m

if. *./ 1 ~: x.,memr had,16 1,JINT do. 2 return. end.

if. fad~:had do. freehdr had end.
free fh,mh,fad
mappings=: (row~:i.#mappings)#mappings

0
)

NB. =========================================================
NB. [force] unmapall dummy  - unmap all
unmapall=: 3 : '>unmap each 0{"1 mappings'

