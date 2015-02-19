VERSION =: 0 : 0

Version 0.3,  1996 12 16

(xxx.0 releases are supposed to contain stable features only.
They don't have feature previews enabled.)

Recent changes:
	- port to Freeware/Windows3.x versions of J

Stable in this release:
	- tacit verb definitions
	- reading/writing of script files
	- crossreferencing
	- tracing facilities for tacit defs
	- locales

Unstable previews for upcoming features:
	- Code for explicit definitions is there, but not really
	  enabled.  You'll stumble over it when you load a script
	  containing explicitly defined functions.

Short-term plans:
	- more documentation
	- support for explicit definitions
	- integration of 13!:xx primitives (requires ISI changes)
	- adverbs & conjunctions can be defined, but could be nicer
	- still not self-supporting

Long-term plans:
	- self-resizing x/v/y controls (requires ISI changes)
	- parse trace (sync with Raul Miller)

Send bug reports, feature requests, etc. to:  bugs@gaertner.de
)

ABOUT =: 0 : 0

			The J Workbench

Motivation:
	- The J Workbench supports tacit programming in J.

Basic Idea:
	- "stable" edit fields for phrases and their test arguments
	- definition and testing of a phrase at the same time
	- test arguments are not just thrown away, but remembered for re-testing

Additional Goodies:
	- built-in execution tracing within tacit definitions
	- built-in cross-referencer, easy navigation between verbs
	- support for standard script files

General Guidelines:
	- aimed at J the *beginners*, not the wizards
	- get the GUI out of the way, don't waste screen real estate on screen
	- do standard chores impicitly, eg. the management of temporaries
	- no-thrills implementation in J, just uses standard WD tools
)

TRYIT1 =: 0 : 0

			Try the Workbench, Lesson 1

- The 3 edit fields on the top are for

                5 9                + *            i. 2 6
             optional x.          phrase             y.

  Where- and whenever you hit RETURN, the expression is evaluated.
  You can tweak the arguments or phrase and re-test easily.
  "Ctrl-A" cycles between those fields.

- Check out the tacit debugger:  with the example above, mark the '+' as for a cut'n'paste.
  (You can use the mouse or use SHIFT+cursor.)  Then hit RETURN again.

- Now mark the entire hook "+*".  Next to the "run" button, there are two buttons adjusting
  the trace resolution - try combinations.

- Enter a the phrase   + / @ *:  and trace any verb involved.

- You like your phrase?  Use the "=:" button to make a definition.
)


TRYIT2 =: 0 : 0

			Try the Workbench, Lesson 2

Setup:
- In menue "Definitions", use the broom and clear the mess.  STOMP!
- In menue "Scripts", select something (it gets loaded).

The fun part:

- Exercise the cross-referencer and ask for toplevel functions, function clusters,
  or the calltrees.

- Select a toplevel name with the mouse.  Hit Ctrl-G (for "goto")
  or use the "-->" button.

- Inside the phrase field, select another name and do the same.

  You don't have to be very exact when doing the marking.  All is fine as long as the
  beginning of the selection is within a name.  Any single letter would be enough,
  and you may under- or overshoot with the end.

- The other arrow buttons navigate around, too.
)
