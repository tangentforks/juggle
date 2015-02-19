#include <stdio.h>
#include <local/menu3.h>

static MENU MM1 = {
	0x40,
	8738,
	"cancel",
	63,
	88,
	208,
	168,
	231,
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
	"confirm",
	113,
	88,
	231,
	168,
	254,
	-30584,
	-30584,
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
	0xC04,
	231,
	NULL,
	0,
	88,
	208,
	168,
	254,
	-17,
	-12,
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
	0x3A60,
	8738,
	"quit",
	63,
	21,
	186,
	105,
	220,
	0,
	0,
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
	"new",
	110,
	105,
	186,
	190,
	220,
	0,
	1024,
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
	0x40,
	0,
	"cut",
	67,
	190,
	186,
	275,
	220,
	8738,
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
static MENU MM7 = {
	0x8,
	190,
	NULL,
	110,
	105,
	186,
	275,
	220,
	3148,
	2314,
	0,
	0,
	0,
	NULL,
	&MM5,
	&MM6,
	NULL,
	NULL,
};
static MENU MM8 = {
	0x8,
	105,
	NULL,
	63,
	21,
	186,
	275,
	220,
	-30584,
	-30584,
	0,
	0,
	0,
	NULL,
	&MM4,
	&MM7,
	NULL,
	NULL,
};
static MENU MM9 = {
	0x40,
	0,
	"equal",
	101,
	275,
	186,
	362,
	220,
	8738,
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
static MENU MM10 = {
	0x40,
	0,
	"cover",
	99,
	362,
	186,
	446,
	220,
	8738,
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
static MENU MM11 = {
	0x40,
	0,
	"divide",
	100,
	446,
	186,
	534,
	220,
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
static MENU MM12 = {
	0x8,
	446,
	NULL,
	99,
	362,
	186,
	534,
	220,
	8738,
	8738,
	0,
	0,
	0,
	NULL,
	&MM10,
	&MM11,
	NULL,
	NULL,
};
static MENU MM13 = {
	0x8,
	362,
	NULL,
	101,
	275,
	186,
	534,
	220,
	8738,
	8738,
	0,
	0,
	0,
	NULL,
	&MM9,
	&MM12,
	NULL,
	NULL,
};
static MENU MM14 = {
	0x8,
	275,
	NULL,
	0,
	21,
	186,
	534,
	220,
	-30584,
	-30584,
	0,
	0,
	0,
	NULL,
	&MM8,
	&MM13,
	NULL,
	NULL,
};
static MENU MM15 = {
	0x40,
	0,
	"write",
	119,
	21,
	220,
	105,
	257,
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
static MENU MM16 = {
	0x40,
	0,
	"read",
	114,
	105,
	220,
	190,
	257,
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
static MENU MM17 = {
	0x40,
	0,
	"paste",
	112,
	190,
	220,
	275,
	257,
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
static MENU MM18 = {
	0x8,
	190,
	NULL,
	114,
	105,
	220,
	275,
	257,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM16,
	&MM17,
	NULL,
	NULL,
};
static MENU MM19 = {
	0x8,
	105,
	NULL,
	119,
	21,
	220,
	275,
	257,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM15,
	&MM18,
	NULL,
	NULL,
};
static MENU MM20 = {
	0x40,
	0,
	"move",
	109,
	275,
	220,
	362,
	257,
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
static MENU MM21 = {
	0x40,
	-4638,
	"uncover",
	117,
	362,
	220,
	446,
	257,
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
static MENU MM22 = {
	0x40,
	0,
	"bound",
	98,
	448,
	190,
	531,
	222,
	14796,
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
static MENU MM23 = {
	0x40,
	-30584,
	"free",
	102,
	448,
	222,
	531,
	253,
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
static MENU MM24 = {
	0xC04,
	222,
	NULL,
	0,
	448,
	190,
	531,
	253,
	-17,
	-12,
	0,
	0,
	0,
	NULL,
	&MM22,
	&MM23,
	NULL,
	NULL,
};
static MENU MM25 = {
	0xA60,
	105,
	"submenu",
	63,
	446,
	220,
	534,
	257,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM24,
	NULL,
	NULL,
	NULL,
};
static MENU MM26 = {
	0x8,
	446,
	NULL,
	117,
	362,
	220,
	534,
	257,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM21,
	&MM25,
	NULL,
	NULL,
};
static MENU MM27 = {
	0x8,
	362,
	NULL,
	109,
	275,
	220,
	534,
	257,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM20,
	&MM26,
	NULL,
	NULL,
};
static MENU MM28 = {
	0x8,
	275,
	NULL,
	0,
	21,
	220,
	534,
	257,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM19,
	&MM27,
	NULL,
	NULL,
};
MENU cmd_men = {
	0x404,
	220,
	NULL,
	0,
	21,
	186,
	534,
	257,
	0,
	0,
	0,
	0,
	0,
	NULL,
	&MM14,
	&MM28,
	NULL,
	NULL,
};