/*
 * Copyright (C) 2012 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *
 * Common header for st_dvb wrapper driver.
 */
#ifndef __ST_DVB_H__
#define __ST_DVB_H__

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include <linuxtv_common/linuxtv.h>
#include <dvb_frontend.h>

/******************************************************************
* EXPORTED MACROS                                                 *
*******************************************************************/
#define FRONTEND_NUM 2

/******************************************************************
* EXPORTED DATA                                                   *
*******************************************************************/
extern int pll_debug;
extern int st_dvb_debug;

#endif // __ST_DVB_H__
