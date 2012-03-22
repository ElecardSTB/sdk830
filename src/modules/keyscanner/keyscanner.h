/*
 * 
 * Copyright (C) 2011  Elecard Devices
 * Author: Anton.Sergeev@elecard.ru
 * 
*/

#ifndef __KEYSCANNER_H__
#define __KEYSCANNER_H__

#ifdef __cplusplus
extern "C" {
#endif

struct keyStatus {
	int valid;
	struct timeval time;
	int status;
};



/*
typedef enum keyEnum {
	eKey_Menu = 0,
	eKey_Left,
	eKey_Up,
	eKey_Down,
	eKey_OK,
	eKey_Right,
	eKey_Power,
	
	eKey_Unknown,
} keys_t;

struct sKeyName {
	keys_t id;
	int mask;
	char *name;
};

struct sKeyName keyNames[] = {
	{ eKey_Menu,	0x0001, "menu"},
	{ eKey_Left,	0x0002, "left"},
	{ eKey_Up,		0x0004, "up"},
	{ eKey_Down,	0x0010, "down"},
	{ eKey_OK,		0x0020, "ok"},
	{ eKey_Right,	0x0040, "right"},
	{ eKey_Unknown,	0x0100, "unknown"},
	{ eKey_Unknown,	0x0200, "unknown"},
	{ eKey_Power,	0x0400, "power"}
};*/



#ifdef __cplusplus
}
#endif

#endif //__KEYSCANNER_H__
