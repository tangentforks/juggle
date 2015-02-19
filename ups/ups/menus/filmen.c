#include <stdio.h>
#include <local/menu3.h>

static MENU MM1 = {
	0x40,
	0,
	"Like before",
	66,
	109,
	27,
	254,
	71,
	-22824,
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
	"Completely",
	69,
	109,
	71,
	254,
	115,
	-22824,
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
	0x404,
	71,
	NULL,
	0,
	109,
	27,
	254,
	115,
	-7,
	-14,
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
	0x2260,
	0,
	"Expand",
	63,
	-1,
	-1,
	116,
	41,
	-22824,
	5,
	0,
	0,
	0,
	NULL,
	&MM3,
	NULL,
	NULL,
	NULL,
};
static MENU MM5 = {
	0x40,
	0,
	"Collapse",
	99,
	116,
	-1,
	263,
	41,
	-22824,
	5,
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
	116,
	NULL,
	63,
	-1,
	-1,
	263,
	41,
	-22824,
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
static MENU MM7 = {
	0x40,
	0,
	"Add expr",
	120,
	263,
	-1,
	394,
	41,
	-22824,
	5,
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
	0,
	"Source",
	101,
	394,
	-1,
	521,
	41,
	-22824,
	5,
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
	0x40,
	0,
	"Used",
	115,
	551,
	23,
	660,
	68,
	0,
	31034,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM10 = {
	0x40,
	0,
	"Assumed",
	112,
	551,
	68,
	660,
	114,
	0,
	12298,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM11 = {
	0x4,
	68,
	NULL,
	115,
	551,
	23,
	660,
	114,
	0,
	25716,
	0,
	0,
	0,
	NULL,
	&MM9,
	&MM10,
	NULL,
	NULL,
};
static MENU MM12 = {
	0x40,
	0,
	"Rematch",
	114,
	551,
	114,
	660,
	160,
	0,
	12320,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM13 = {
	0x40,
	0,
	"Reload",
	108,
	551,
	160,
	660,
	206,
	0,
	12331,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM14 = {
	0x40,
	0,
	"Dates",
	109,
	551,
	206,
	660,
	254,
	0,
	21872,
	0,
	0,
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};
static MENU MM15 = {
	0x4,
	206,
	NULL,
	108,
	551,
	160,
	660,
	254,
	0,
	30057,
	0,
	0,
	0,
	NULL,
	&MM13,
	&MM14,
	NULL,
	NULL,
};
static MENU MM16 = {
	0x4,
	160,
	NULL,
	114,
	551,
	114,
	660,
	254,
	0,
	28260,
	0,
	0,
	0,
	NULL,
	&MM12,
	&MM15,
	NULL,
	NULL,
};
static MENU MM17 = {
	0x404,
	114,
	NULL,
	0,
	551,
	23,
	660,
	254,
	-59,
	-18,
	0,
	0,
	0,
	NULL,
	&MM11,
	&MM16,
	NULL,
	NULL,
};
static MENU MM18 = {
	0x2260,
	0,
	"Path",
	97,
	521,
	-1,
	610,
	41,
	0,
	22604,
	0,
	0,
	0,
	NULL,
	&MM17,
	NULL,
	NULL,
	NULL,
};
static MENU MM19 = {
	0x8,
	521,
	NULL,
	101,
	394,
	-1,
	610,
	41,
	-22824,
	5,
	0,
	0,
	0,
	NULL,
	&MM8,
	&MM18,
	NULL,
	NULL,
};
static MENU MM20 = {
	0x8,
	394,
	NULL,
	120,
	263,
	-1,
	610,
	41,
	-22824,
	5,
	0,
	0,
	0,
	NULL,
	&MM7,
	&MM19,
	NULL,
	NULL,
};
MENU fil_men = {
	0x408,
	263,
	NULL,
	0,
	-1,
	-1,
	610,
	41,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM6,
	&MM20,
	NULL,
	NULL,
};