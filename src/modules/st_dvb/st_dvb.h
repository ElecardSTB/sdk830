#ifndef __ST_DVB_H
#define __ST_DVB_H

/*
 * Copyright (C) 2012 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *
 * Common header for st_dvb wrapper driver.
 */

#define FRONTEND_NUM 2

extern int pll_debug;
extern int st_dvb_debug;

static inline int get_i2c_bus(int slot_num)
{
	switch(slot_num) {
		case 0:
			return 3;
		case 1:
			return 2;
	}
	return 0;
}

#endif // __ST_DVB_H
