#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <local/wn.h>
#include <local/menu3.h>
#include "bmenu.h"
#include "layout.h"
#include "med3.h"
#ifndef lint
static char sccsid[] = "%W% (UKC) %G%";
#endif  /* lint */

static int coordy;
static int coordleftx;		/* x position of the coordinate string */
static int coordlefty;		/* y position of the coordinate string */
extern int wn;
extern font_t *boldfont, *plainfont;
static int lastx, lasty;

static struct wrectst cwr;

/*  Initialize the coordinate display structures. Should be called after
 *  a window size change. wwidth should be the window width.
 */
void
coordset(wwidth)
int wwidth;
{
	coordy = MHEIGHT + 7;
	cwr.wr_x = wwidth - MHWIDTH - COWIDTH + 1;
	cwr.wr_y = MHEIGHT + 1;
	cwr.wr_width = COWIDTH - 1;
	cwr.wr_height = MHHEIGHT - MHEIGHT - 3;
	coordleftx = wwidth - MHWIDTH - COWIDTH + 5;
	coordlefty = coordleftx + cwr.wr_width/2;
	clearcoords();
}

/*  display the x, y coordinates.
 */
void
showcoords(x,y)
int x, y;
{
	char str[20];

	if (x < 0)
		x = 0;
	if (y < 0)
		y = 0;
	if ((x == lastx) && (y == lasty))
		return;
	lastx = x;
	lasty = y;
	Mpushsu(wn);
	wn_set_area(wn,cwr.wr_x,cwr.wr_y,cwr.wr_width,cwr.wr_height,WN_BG(wn));
	sprintf(str,"X=%-4d",x);
	wn_text(wn,boldfont,str,coordleftx,coordy,WN_FG(wn),WN_BG(wn),WN_USE_TOP);
	sprintf(str,"Y=%-4d",y);
	wn_text(wn,boldfont,str,coordlefty,coordy,WN_FG(wn),WN_BG(wn),WN_USE_TOP);
	Mpopsu(wn);
}

/*  Clear away any displayed coordinates.
 */
void
clearcoords()
{
	char str[20];

	if (lastx < 0 && lasty < 0)
		return;
	Mpushsu(wn);
	wn_set_area(wn,cwr.wr_x,cwr.wr_y,cwr.wr_width,cwr.wr_height,WN_BG(wn));
	sprintf(str,"X=");
	wn_text(wn,boldfont,str,coordleftx,coordy,WN_FG(wn),WN_BG(wn),WN_USE_TOP);
	sprintf(str,"Y=");
	wn_text(wn,boldfont,str,coordlefty,coordy,WN_FG(wn),WN_BG(wn),WN_USE_TOP);
	Mpopsu(wn);
	lastx = -1;
	lasty = -1;
}
