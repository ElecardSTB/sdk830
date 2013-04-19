/*
 * Copyright (C) 2011 by Elecard-STB.
 * Written by Anton Sergeev <Anton.Sergeev@elecard.ru>
 * 
 * EDC-1051 frontend header.
 * 
 */
/**
 @File   edc-1051.h
 @brief
*/

#if !(defined __EDC_1051_H__)
#define __EDC_1051_H__

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include "st_dvb.h"

/******************************************************************
* EXPORTED FUNCTIONS PROTOTYPES               <Module>_<Word>+    *
*******************************************************************/
struct dvb_frontend* edc_1051_init_frontend(struct i2c_adapter *adapter);

#endif //#if !(define __EDC_1051_H__)
