coclass 'base'
require 'strings'
testdata =: _2 ]\ 0;1 ; 3;'/x' ; 2;(,'x')
testdata2 =: _2 ]\ 6;'' ; 3;'/x' ; 3;'/y' ; 2;(,'x') ; 2;(,'y') ; 7;'' ; 3;'/swap' ; 0;5 ; 0;10 ; 2;'swap' ; 2;'apply'
testdata3 =: _2 ]\ 4;'' ; 0;0 ; 1;'abc' ; 5;''
testdata4 =: _2 ]\ 4;'' ; 0;0 ; 1;'abc' ; 6;''
NB. parser for the ICFP 2000

NB. Stack type codes
STACK_TYPE_INTEGER =: 0
STACK_TYPE_FLOAT =: 1
STACK_TYPE_STRING =: 2
STACK_TYPE_BOOLEAN =: 3
STACK_TYPE_FUNCTION =: 4
STACK_TYPE_ARRAY =: 5
STACK_TYPE_OBJECT =: 6
STACK_TYPE_LIGHT =: 7

NB. Input y. is a list of pairs type;value
NB. where
NB. type  value
NB. 0     integer number
NB. 1     string
NB. 2     identifier
NB. 3     /identifier
NB. 4     [ character
NB. 5     ] character
NB. 6     { character
NB. 7     } character
NB. 8     boolean (0 for true, 1 for false)
NB. 9     float number

NB. This routine parses the file, producing the verb
NB. 'mainverb'.  Then it executes mainverb.  Errors
NB. are signaled by 13!:8 (x)

parser =: 3 : 0
currindex =: 0
tokens =: y.
stack =: 0 2$a:

NB. The whole file is a function without the { }, so we
NB. treat it as such
3 : (readfn '') ''  NB. stack the function definition
NB. Verify we hit end of file on input
if. currindex <: #tokens do. 13!:8 (3) end.
apply 0  NB. run the verb
''
)

NB. Read a token and process it.  Nilad (currindex points
NB. to the next token).  
NB. Processing a token returns a list of executable lines
NB. (usually just 1, but more if the token is a function
NB. or an array)
readtok =: 3 : 0
NB. Get next token.  Insert exactly one } at end-of-file
NB. to match the { we assumed at the beginning.
if. currindex = #tokens do. 'type value' =. 7;''
else. 'type value' =. currindex { tokens
end.
currindex =: >: currindex
NB. debug 0: display 'readtok: type=' , (5!:5 <'type') , ' value=' , 5!:5 <'value'
NB. Dispatch the handler for the token-type read
select. type
  NB. Constant: push onto the stack
  case. 0 do.
NB. debug 0: display 'readtok: type 0 returning ' , 'push <' , 5!:5<'value'
    ,<'STACK_TYPE_INTEGER push <' , 5!:5<'value'
  case. 9 do.
NB. debug 0: display 'readtok: type 0 returning ' , 'push <' , 5!:5<'value'
    ,<'STACK_TYPE_FLOAT push <' , 5!:5<'value'
  case. 1 do.
NB. debug 0: display 'readtok: type 0 returning ' , 'push <' , 5!:5<'value'
    ,<'STACK_TYPE_STRING push <' , 5!:5<'value'
  case. 8 do.
NB. debug 0: display 'readtok: type 0 returning ' , 'push <' , 5!:5<'value'
    ,<'STACK_TYPE_BOOLEAN push <' , 5!:5<'value'
  NB. Identifier: if operator, emit 'operator 0'; else
  NB. emit the special string '+identifier' which will be
  NB. replaced with a global or local reference as appropriate
  case. 2 do.
    if. (#operatorlist) > ox =. operatorlist i. (<value) do.
      ,ox { operatorstrings
    else. ,<'+',value
    end.
  NB. /identifier: error if name is special; otherwise return
  NB. '-name' which will be replaced with a pop (if legal)
  case. 3 do.
    if. (<value) e. operatorlist do. 13!:8 (3) else. ,<'-',}.value end.
  NB. [, start of array: go read the array, and return what it
  NB. returns
  case. 4 do.
    readarray ''
  NB. ], end of array.  Return '13!:8 (2)' which is a signal
  NB. for end-of-array; if the ] is unexpected this will crash
  NB. when executed
  case. 5 do.
    ,<'13!:8 (2)'
  NB. {, start of function.  Go look for end-of-function
  case. 6 do.
    readfn ''
  NB. }, end of function.  Return the special tag '13!:8 (4)'
  case. 7 do.
    ,<'13!:8 (4)'
end.
)

NB. Routine to read a function.  We read lines and accumulate them
NB. until we hit the end-of-function marker '13!:8 (4)'.  We have
NB. to take some care to handle the local/global variables properly.
NB.
NB. A function definition is EXECUTABLE, at the time the {} is
NB. encountered.  In particular, nested definitions do not know
NB. their globals until the outer definition is executed.  So,
NB. the return from readfn is a string which, when executed,
NB. returns a string that defines the desired verb.
NB.
NB. To get this string right, we keep track of the names of
NB. variables that are bound during the definition of this
NB. function.  If a name has been bound, we just emit a
NB. 'push name' to push it.  If not bound, we emit '''push''' , ":name'
NB. which will cause the name to be replaced by its value.
NB. The stored variable is a list of type;data so we take the
NB. type as the type argument to push
NB.
NB. In any case, the overall result is that after the function
NB. definition has been EXECUTED, a character string defining
NB. the function will have been put onto the stack.
readfn =: 3 : 0
result =. 0$a:  NB. Init null result
localvbls =. 0$a:  NB. Init the list of local variables encountered
NB. verbs used below
  localstg =. '(push~ >)~/'&, @: }. L:0 @: ]
  gblstg =. '''(push~ >)~/'' , ":' &, @: }. L:0 @: ]
  isvblname =. (] '+'&=@{.@>)
  selectvblstg =. (]`((gblstg`localstg)@.(e.~ }.L:0)))@.isvblname
while. 1 do.
  token =. readtok ''
NB. debug 0: display 'readtok: token=' , 5!:5 <'token'
  NB. stop when we hit the end
  if. token -: ,<'13!:8 (4)' do. break. end.
  NB. If we are encountering a binding of a local variable (it can occur
  NB. only singly, not in a list), remember the name being bound, and
  NB. replace it with an assignment
  if. '-' = ch0 =. (0;0) {:: token do.
    localvbls =. localvbls , }.L:0 {. token
    token =. (,&' =: ,/ pop <i.8')@}. L:0 token
  end.
  NB. Convert variable references ('+name') to the
  NB. correct form: 'push name' for locals, '''push''' , ":name'
  NB. for (presumed) globals
NB. debug 0: display 'readtok: localvbls=' , 5!:5 <'localvbls'
  token =. localvbls selectvblstg"_ 0 token
  result =. result , token
end.
NB. We now have a list of boxes holding the lines.  Make that
NB. the executable return string
NB. debug 0: display 'result of readfn is ' , 'push <definefunc ' , 5!:5 <'result'
,<'STACK_TYPE_FUNCTION push <definefunc ' , 5!:5 <'result'
)

NB. The routine that is executed to resolve the variable in a function
NB. Returns a boxed list which is the actual executable verb
definefunc =: 3 : 0
NB. Replace the strings starting with '''' with their executed equivalents.
NB. This resolves the globals.
(]`(". L:0)) @. (] ''''&=@{.@>) "0 y.
)

NB. Routine to read an array.  We just read tokens till we hit
NB. the '13!:8 (2)' end marker.  We return all the elements, followed
NB. by a request to group them on the stack by taking them off
NB. and putting them back as a boxed list (which is how we
NB. represent arrays).
NB.
NB. /identifiers are not allowed in arrays.  {} are ok.
readarray =: 3 : 0
result =. 0$a:
while. 1 do.
  token =. readtok ''
  NB. stop when we hit the end
  if. token -: ,<'13!:8 (2)' do. break. end.
  NB. If we are encountering a binding of a local variable,
  NB. that's an error
  if. '-' = ch0 =. (0;0) {:: token do. 13!:8 (3) end.
  result =. result , token
end.
NB. We now have a list of boxes holding the items. Return it,
NB. followed by the stack fixup.  When we pop items from the stack, any type
NB. is allowed
result , <'STACK_TYPE_ARRAY push < pop ' , (": # result) , '$<i.8'
)

NB. Stack management

NB. pop stack.  y. is list of allowed types (may be boxed, to allow multiple
NB. valid types.  #y. elements are popped,
NB. and their types are checked.  Result is list of type;value
NB. list
pop =: 3 : 0
result =. (-#y.) {. stack_base_
stack_base_ =: (-#y.) }. stack_base_
NB. debug 0: display 'pop: result=' , 5!:5 <'result'
if. -. *./ ({."1 result) e.&> ,y. do. 13!:8 (5) end.
result
)

NB. push stack.  x. is list of type to push,
NB. y. is the list of elements to push (boxed)
push =: 4 : 0
NB. debug 0: display 'push: newitems=' , 5!:5 <'newitems' [ newitems =. x. ;"_1&, y.
stack_base_ =: stack_base_ , x. ;"_1&, y.
''
)

NB. 'apply' function
NB. The top of the stack must be a function definition.  We
NB. pop it and run it.  There is no result.
apply =: 3 : 0
NB. Save current locale
currlc =. 18!:5 ''
NB. create new locale, move to it, and make its path go through the current
((, 18!:2) currlc) (18!:2 [ 18!:4@]) 18!:3 ''
3 : ((<0 1) {:: pop STACK_TYPE_FUNCTION) ''
NB. restore original locale
18!:4 currlc
''
)

NB. 'if' function
NB. The top of the stack must be a boolean and 2 function
NB. definitions.  We pick one and execute it (stack: bool T F)
if =: 3 : 0
NB. Save current locale
currlc =. 18!:5 ''
NB. create new locale, move to it, and make its path go through the current
((, 18!:2) currlc) (18!:2 [ 18!:4@]) 18!:3 ''
3 : (({::~ >:@-.@(0&{::)) {:"1 pop STACK_TYPE_BOOLEAN,2#STACK_TYPE_FUNCTION) ''
NB. restore original locale
18!:4 currlc
''
)

operatorlist =: ' '&taketo&.> operatorstrings =: <;._2 (0 : 0)
acos STACK_TYPE_FLOAT
addi STACK_TYPE_INTEGER,STACK_TYPE_INTEGER
addf STACK_TYPE_FLOAT,STACK_TYPE_FLOAT
apply 0
asin STACK_TYPE_FLOAT
clampf STACK_TYPE_FLOAT
cone
cos STACK_TYPE_FLOAT
cube
cylinder
difference
divi STACK_TYPE_INTEGER,STACK_TYPE_INTEGER
divf STACK_TYPE_FLOAT,STACK_TYPE_FLOAT
eqi STACK_TYPE_INTEGER,STACK_TYPE_INTEGER
eqf  STACK_TYPE_FLOAT,STACK_TYPE_FLOAT
false
floor STACK_TYPE_FLOAT
frac STACK_TYPE_FLOAT
get STACK_TYPE_ARRAY,STACK_TYPE_INTEGER
getx STACK_TYPE_LIGHT
gety STACK_TYPE_LIGHT
getz STACK_TYPE_LIGHT
if
intersect
length STACK_TYPE_ARRAY
lessi STACK_TYPE_INTEGER,STACK_TYPE_INTEGER
lessf STACK_TYPE_FLOAT,STACK_TYPE_FLOAT
light
modi STACK_TYPE_INTEGER,STACK_TYPE_INTEGER
muli STACK_TYPE_INTEGER,STACK_TYPE_INTEGER
mulf STACK_TYPE_FLOAT,STACK_TYPE_FLOAT
negi STACK_TYPE_INTEGER
negf STACK_TYPE_FLOAT
plane
point STACK_TYPE_FLOAT,STACK_TYPE_FLOAT,STACK_TYPE_FLOAT
pointlight
real STACK_TYPE_INTEGER
render
rotatex
rotatey
rotatez
scale
sin STACK_TYPE_FLOAT
sphere
spotlight
sqrt STACK_TYPE_FLOAT
subi STACK_TYPE_INTEGER,STACK_TYPE_INTEGER
subf STACK_TYPE_FLOAT,STACK_TYPE_FLOAT
translate
true
union
uscale
)
