#!/bin/sh

# Copyright (C) 2000 Martin Neitzel, Gaertner Datensysteme,
# neitzel@gaertner.de
#
# Use for any and all purposes, commercial or non-commercial, is allowed
# as long as this copyright note remains intact & included
# and the authorship is duly acknowledged in derived products
# or software packages bundling it along.
#
# No warranty whatsoever, no fitness for any purpose, no liability
# for direct or indirect damages, be it expressed or implied.
# Yadda yadda yadda...  If it breaks, you keep both parts.

# Objectives:
# This program creates (or purges) a bunch of files with various funny
# names.  It is intended as a stress test for your shell scripts,
# CGI scripts, whatever.   A rock-solid script would neither
# bail out with an error when names like these get into its way,
# nor would it unduly trigger on any of the meta characters.

# The modus operandi is completely dependent on the action variables
# TOUCH_RM and LINK_RM.  All filenames are exactly specified to protect
# the innocent during removal.  (That is, no globbing is used.)

case "$1" in
-c)	TOUCH_RM=touch
	LINK_RM=ln
	;;
-n)	TOUCH_RM="echo touch"
	LINK_RM="echo ln"
	;;
-r)	TOUCH_RM="rm -f --"
	LINK_RM="rm -f --"
	;;
-v)	echo '$id:$'
	exit 0
	;;
*)	cat <<-. >&2
		usage: $0 [-x] -[crnv]
	.
	exit 1 ;;
esac

# Start with ordinary files.
# Boring boring boring, glorious glob fodder, though.
#
$TOUCH_RM normal normal2

# fake options
# (We are not using the posixly end-of-options "--" here ourselves
# because the touch used here may not support it.)
#
$TOUCH_RM ./- ./-- ./-n

# globbing characters.
# Some match existing files, some not:
# (Different shells and options react differently to the latter case,
# so we make sure to check both.)
#
$TOUCH_RM "norm*"  "??orm*"  "[i]-match-nothing"

# embedded white space.
# "Mind the tab!", as every London commuter knows.
#
$TOUCH_RM "  leadingspaces"   "inner space"  "inner	tab"   "trailingspace "
$TOUCH_RM 'two
lines'

# quoting characters
#
$TOUCH_RM 'embedded"dquote'  '"dq-word"'  '"3 d-quoted words"'
$TOUCH_RM "embedded'squote"  "'sq-word'"  "'3 s-quoted words'"
$TOUCH_RM back\\slash1  back\\\\slash2  back\\\\\\slash3

# var & command substitutions
# (Have an eye on security.)
#
$TOUCH_RM '$USER'  '`echo hi`'  '$(date)'

# history characters.
#
# csh scripters (ugh!) sometimes forget the -f in "#!/bin/csh -f",
# and any-shell coders sometimes even explicitly request a profile
# without knowing what that might imply.
#
# I is tempting to create a file "!!" here, but this might be just
# to dangerous for the person doing the checks.  Instead, we'll
# formulate a hopefully safe misreference.
#
# The comma is a favourite histchar around town here.  (We are
# too lazy for those Shift-! pinky exercises.)
#
$TOUCH_RM  hist1\!nonex:0  hist2\,nonex:0

# links of various persuasions.
#
$LINK_RM normal2 link-hard
$LINK_RM -s normal2 link-soft
$LINK_RM -s non-existing-file link-dangling
$LINK_RM -s link-self link-self

# A .dotfile incl. reminder:
#
$TOUCH_RM .dotfile   "there's a .dotfile"
