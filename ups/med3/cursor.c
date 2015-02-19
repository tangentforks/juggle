#include <stdio.h>
#include <local/wn.h>
#include "cursors.h"
#ifndef lint
static char sccsid[] = "%W% (UKC) %G%";
#endif  /* lint */

extern int wn;				/* window number */
bitmap_t *cursor[CP_NUM];
extern short *cpats[];
extern short cp_xhot[];
extern short cp_yhot[];

/*  Initialise the cursors. Should be called just once.
 */
void
initcps()
{
	int i;

	for (i = 0; i < CP_NUM; i++) {
		cursor[i] = wn_make_bitmap_from_data
		  (16,16,1, (unsigned short *)cpats[i],BM_BIT0_RIGHT,
		   BM_XY_PIXELS,2);
		cursor[i]->bm_xhot = cp_xhot[i];
		cursor[i]->bm_yhot = cp_yhot[i];
	}
}

/* set cursor number cnum
 */
int
setcp(int cnum)
{
	static int lastcnum = -1;
	int temp;

	if (cnum == lastcnum)
		return 0;
	(void)wn_set_cursor(wn,cursor[cnum]);
	temp = lastcnum;
	lastcnum = cnum;
	return(temp);
}
