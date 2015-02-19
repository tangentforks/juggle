NB. Somebody asked:
NB.      Why is nobody talking english?
NB.
NB. We are.  However, this public CVS teaching module was one used
NB. by an entire German class studying CVS, and they contributed
NB. a lot of German verses.  So be it, it's better than nothing.
NB.
NB. ******* Modified at Dec.18 ***************  [<-- what a lie]
NB.
NB. The line above was introduced by somebody unknown on, surprise,
NB. December the 18th.  In general one would rather not put such a
NB. time stamp into the file.  "cvs log" and "cvs stat" provide
NB. this information  just fine.  If you absolutely insist on
NB. having a timestamp in a file, use the magic keywords such as
NB.
NB. $Date: 2006/02/15 23:45:10 $ <- hate this during diffs? read the comment.
NB.
NB. Note that, depending on the way you check things out (see "-k"),
NB. such keywords may be expanded or left as they are.  Usually,
NB. developers will not expand keywords upon "checkout" in order not
NB. to mess up "cvs diff"s.  Expansion is the default for "cvs export",
NB. where sources go to non-developers.


stanzas =: noun define
*
Ihr seht nach Oben, wenn ihr nach Erhebung verlangt. Und ich sehe hinab,
weil ich erhoben bin. Wer von euch kann zugleich lachen und erhoben sein?
Wer auf den höchsten Bergen steigt, der lacht über alle Trauer-Spiele
und trauer-Ernste.

Also sprach Zarathustra (Nietzsche)
*
Es war einmal und ist nicht mehr,
ein großer dicker Teddybär,
der hatte einen sitzen
und fing an zu schwitzen
End von der Geschichd küße keine Teddy nicht
*
Wir leben wie die Russen, einfach und schlicht,
des morgens keine Kohlen des abends kein Licht,
die Kohlen haben die Polen, die Tschechen das Licht,
- uns bleibt die Freundschaft mehr brauchen wir nicht.
*
The limerick's an art form complex
Whose contents run chiefly to sex;
It's famous for virgins
And masculine urgin's
And vulgar erotic effects.
*
Er sprach zu ihr aus seinem Bette:
Wann kommst du denn endlich, Anette?
Sie sagte: Hör zu,
lass mich doch in Ruh,
ich sitz vorm Computer und chatte!
*
Hier kann ich texten, ohne daß man mich kennt,
da auf dem Server sich jeder gleich nennt.
Also schreib ich zwei Zeilen und schick sie weg,
doch seh ich weder Sinn noch einen Zweck.
Aber tippen muss ich halt etwas.
*
Unter der Annahme linearer und stetiger Übertragungseigenschaften
ohne Rückwirkungen kann das Übertragungsverhalten von Meßeinrichtungen
zwischender Eingangsgröße Xe und der Ausgangsgröße Xa durch eine
lineare Differentialgleichung n-ter Ordnung beschrieben werden:
...
viel Spaß bei der Messtechnik-Klausur
*
Mit der Zeit wird jeder spitzer felsen zum runden
Flusskieselstein
*
Wer so was liest hat nichts zu tun
stattdessen sollte er lieber ruhn.
Doch wer pennt hat ein Problem
und muß am nächsten ersten gehn.
Ja jetzt bereut er sein tun.
*
Es schlief der kleine Klaus
in der Hängematte hinterm Haus
ein laut es plötzlich machte
die Matte plötzlich krachte
200 Kilo, die hielt sie nicht aus.
*
Yo this is me from the land of DOWNTOWN OTTAWA..
Even though it took me a while,
I have modified this file.
Thanks for the tutorial.
YOUR Program is cool but laborial :)
*
Let's ride, said the guys from Toronto,
to our next upcomin show.
Let's all go to J2001
if you've got the money it'll be loads of fun.
If not, we won't even provide a video.
*
Big Joe Mufferaw
paddled up the Ottawa
Downed a tree
in just three
back in Mattawa
*
There was a big piggy named Clyde
Who ate an apple and died
The apple fermented
Inside the demented
Making cider inside his insides
*
There was once a dude name Beavis
Who really like to use CVS
He had a dumb friend
And a right annoying show
So we asked him to please leave us.
*
There was a CVStanza
Who lived in deanza
Who when commited to CVSranza
Cried who are all these cranzas
*
There was once a Jogger in Hampton
who was thinking in spaces with handson
to commit his changes
he added some ranges
to the other lines of plankton
*
There was once a Jogger in Scranton
whose vocabulary was rather wanton.
To restrain his language,
they denied him all beverage
and put him on a diet of plankton.
*
There was once a Poet in Scranton
whose vocabulary was rather wanton.
To restrain his language,
they denied him all beverage
and put him on a diet of plankton.
*
A J programmer's output will shrink
for each minute you give him to think.
A model for fission
with perfect precision?
That's nice - but TWO LINES!? - don't waste ink!
*
There once was a lady called Mable
Who's cycle was remarkably stable
Every full moon
She took out a spoon
And at 10:36 ....
*
There once was a hacker named Matt
Who thought Linux was where its all at
He was made to use Windows
And said By Golly how this Blows
But the powers that be said that's that
*
There once was a lady called Simone
who tried to use WinCVS quite alone
till she found this great page
who helped her out of her cage
Hope this time it will work
*
There's a fuzzy little kitten called 'sean'
He searched for the Cho, who was gone
He looked in the kitchen, he tilted his head,
he then munched some kibbles instead
*
Es geschah einem Fall namens Genitiv
daß Dativ der Große ihn zu sich rief.
Jetzt heißt es 'dem seins' statt 'dessen'.
Der Genitiv wurde vergessen.
*
Es pflegte eine Dame beim Essen
absonderslichste Interessen.
Sie öffnet den Schnabel
und pult mit der Gabel
nach Resten, die wurden vergessen.
*
Mir fällt nicht´s ein, drum schreib 
ich mal irgendetwas hinein!
*
Es schien ein Baum in Nordhessen
vom Borkenkäfer besessen.
Doch schuld war allein
der Hund von Herrn Klein;
der hatte das Gießen vergessen.
*
Wir leben zwar
alle unter demselben Himmel,
aber wir haben
nicht alle einen eigenen Horizont.

Konrad Adenauer
*
Zeit haben nur diejenigen, 
die es zu nichts gebracht haben, 
und damit haben sie
es weiter gebracht, 
als all die anderen. 
Oh man i hope i don't screw up
making mistakes gets me all choked up 
Hark! Hark! The dogs do bark!
)



NB. like 2 show stanzas
show =: verb define
  8 show y.
:
  delay =. x.
  stanzas=.y.

  for_stanza. <;._1 stanzas do.
    (>stanza) (1!:2) 2
    6!:3 delay
  end.
  0 0$0
)

NB.  Just my little addition...
NB.  Sorry for messing this up...

show stanzas
2!:55 ] 0

NB. This file is executable program source in the "J" language.
NB. People can run it through a J interpreter to get all limericks
NB. displayed in sequence.
NB.
NB. Please add another fine limerick of yours, but don't wreck
NB. the code above following the stanzas.

This line should be retracted again a few minutes later.
