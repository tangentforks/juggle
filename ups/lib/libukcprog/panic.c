/*  panic.c -- Call a user user-defined panic handling routine and abort()  */

/*  Copyright 1992  Godfrey Paul, University of Kent at Canterbury.
 *
 *  You can do what you like with this source code as long as
 *  you don't try to make money out of it and you include an
 *  unaltered copy of this message (including the copyright).
 */

char ukcprog_panic_sccsid[] = "@(#)panic.c	1.9 30/5/93 UKC";

#include <stdio.h>
#include <stdlib.h>

#include "ukcprog.h"


static panic_handler_t User_panic_handler = NULL;


/*
 *  install_panic_handler()
 *  Installs a new panic handler, returns the old one.
 */
panic_handler_t
install_panic_handler(handler)
panic_handler_t handler;
{
	panic_handler_t old;

	old = User_panic_handler;
	User_panic_handler = handler;

	return old;
}


/*
 *  panic()
 *  Called when the world has ended.  If a user-defined routine exists,
 *  call it with the given message as an argument.  If not, or if it
 *  returns, print a suitable message and abort.
 */
void
panic(message)
const char *message;
{
	if (User_panic_handler != NULL)
		(*User_panic_handler)(message);

	fprintf(stderr, "Fatal internal error: %s (aborting) ...\n", message);
	fflush(stderr);
	abort();
}
