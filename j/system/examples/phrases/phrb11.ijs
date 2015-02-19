NB.  Phrases from Chapter 11, Section B of J Phrases.

m0=: A=: +/ % #                 NB. Arithmetic mean
m1=: H=: A &. (%"_)                   NB. Harmonic mean
m2=: M=: A &. (^&p)               NB. Generalized mean
a3=: N=: (^&) (A&.)              NB. L-x norm; 3-norm is 3 N y
m4=: +/ &. (*:"_) @ +.              NB. Magnitude | e.g. m4 3j4
a5=: each=: &.>                  NB. Each (f each applies f to each box)
m6=: ^    .: -&.j.                   NB. Sine
m7=: sin  -: sinh&.j.           NB. Tautology
m8=: tan  -: tanh&.j.           NB.    "
m9=: sinh -: sin&.j.            NB.    "
m10=: cosh -: cos& j.            NB.    "
m11=: tanh -: tan&.j.            NB.    "
v12=: <.   -: >.&.-              NB. Tautologies
v13=: >.   -: <.&.-              NB. Tautologies
d14=: *    -: +&.^.              NB. Tautology
d15=: *    -: +&.(10&^.)         NB. Tautology
v16=: %    -: -&.^.              NB. Tautologies
d17=: +    -: *&.^               NB. Tautology
d18=: +    -: *&.(10&^)          NB. Tautology
v19=: -    -: %&.^               NB. Tautologies
v20=: %.   -: %.&.|:             NB. Tautologies
v21=: %.   -: %.&.(+@|:)         NB. Tautologies
m22=: +/\  -: +/\.&.|.           NB. Tautology
m23=: +/\. -: +/\ &.|.           NB. Tautology
a24=: BW=: /&.#:                 NB. Bitwise adverb
m25=: *. BW                      NB. Bitwise AND.  e.g. m25 _1 100 200
m26=: +. BW                      NB. Bitwise OR    e.g. m26 100 200
m27=: ~: BW                      NB.Bitwise XOR   e.g. m27 100 200
m28=: i.&.(p:^:_1)               NB. The primes less than n
m29=: totient=: * -.@%@~.&.q:    NB.Euler's totient function
m30=: |.&.;:                    NB.Reverse the words;  e.g. m30 'three score and ten years'
n31=: a=: ' abcdefghijklmnopqrstuvwxyz'  NB. Space and alphabet
m32=: encrypt=: (#a)&|@>: &. (a&i.)  NB.Julius Caesar's cypher. e.g.
m33=: decrypt=: (#a)&|@<: &. (a&i.)  NB.decrypt encrypt x=:'from sea to sea'
m34=: J=: 1&|.&.#:              NB.Survivor number in the Josephus problem of order n
m35=: ar=: >:@]                 NB.Increment right argument
m36=: dr=: <:@[                 NB.Decrement right argument
m37=: dl=: <:@[                 NB.Decrement left argument
m38=: test =: #.@(,&*)          NB.Ackermann test
m35=: ack=: ar`ar`(dl ack 1:)`(dl       ack[ack dr)@.test  NB.Ackermann fn
m36=: 0&ack -:  >:&.(3&+)       NB.Ackermann 0
m37=: 1&ack -: 2&+&.(3&+)       NB.Ackermann 1
m38=: 2&ack -: 2&*&.(3&+)       NB.Ackermann 2
m39=: 3&ack -: 2&^&.(3&+)       NB.Ackermann 3
m40=: 4&ack -: )                NB.Ackermann 4
m41=: 5&ack -: 3 :       '^/@#&2^:(1+y.)&.(3&+) 1'   NB.Ackermann 5
