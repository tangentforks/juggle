#include <stdio.h>
#include <local/menu3.h>

static MENU MM1 = {
	0x40,
	7424,
	"Remove",
	100,
	-1,
	-1,
	82,
	40,
	-30584,
	8738,
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
	30829,
	"Source",
	101,
	82,
	-1,
	170,
	40,
	29295,
	30062,
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
	0x40,
	29812,
	"Save",
	115,
	170,
	-1,
	248,
	40,
	2313,
	2402,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM4 = {
	0x8,
	170,
	NULL,
	101,
	82,
	-1,
	248,
	40,
	2353,
	12298,
	0,
	0,
	0,
	NULL,
	&MM2,
	&MM3,
	NULL,
	NULL,
};
static MENU MM5 = {
	0x8,
	82,
	NULL,
	100,
	-1,
	-1,
	248,
	40,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM1,
	&MM4,
	NULL,
	NULL,
};
static MENU MM6 = {
	0x40,
	30053,
	"Activate",
	120,
	248,
	-1,
	350,
	40,
	28530,
	25959,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM7 = {
	0x40,
	26988,
	"Inactivate",
	121,
	350,
	-1,
	467,
	40,
	28533,
	28260,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM8 = {
	0x40,
	2387,
	"Execute",
	122,
	467,
	-1,
	557,
	40,
	26988,
	10866,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM9 = {
	0x8,
	467,
	NULL,
	121,
	350,
	-1,
	557,
	40,
	13066,
	8312,
	0,
	0,
	0,
	NULL,
	&MM7,
	&MM8,
	NULL,
	NULL,
};
static MENU MM10 = {
	0x8,
	350,
	NULL,
	120,
	248,
	-1,
	557,
	40,
	2313,
	2402,
	0,
	0,
	0,
	NULL,
	&MM6,
	&MM9,
	NULL,
	NULL,
};
MENU bpt_men = {
	0x408,
	248,
	NULL,
	30062,
	-1,
	-1,
	557,
	40,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM5,
	&MM10,
	NULL,
	NULL,
};
