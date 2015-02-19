#include <stdio.h>
#include <local/menu3.h>

static MENU MM1 = {
	0x40,
	0,
	"Expand",
	115,
	-1,
	-1,
	125,
	100,
	0,
	0,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM2 = {
	0x40,
	0,
	"Collapse",
	104,
	125,
	-1,
	252,
	100,
	0,
	0,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM3 = {
	0x8,
	125,
	NULL,
	115,
	-1,
	-1,
	252,
	100,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM1,
	&MM2,
	NULL,
	NULL,
};
static MENU MM4 = {
	0x40,
	0,
	"Add entry",
	97,
	252,
	-1,
	379,
	100,
	0,
	0,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM5 = {
	0x40,
	0,
	"Reset env",
	114,
	379,
	-1,
	506,
	100,
	0,
	0,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM6 = {
	0x8,
	379,
	NULL,
	97,
	252,
	-1,
	506,
	100,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM4,
	&MM5,
	NULL,
	NULL,
};
MENU envhead_men = {
	0x408,
	252,
	NULL,
	0,
	-1,
	-1,
	506,
	100,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM3,
	&MM6,
	NULL,
	NULL,
};