/*
 * Copyright (C) 2011 by Elecard-STB.
 * Written by Anton Sergeev <Anton.Sergeev@elecard.ru>
 * 
 * EDC-1051 frontend header.
 * 
 */
/**
 @File   st_dvb.h
 @brief
*/

#if !(defined __EDC_1051_H__)
#define __EDC_1051_H__

struct dvb_frontend;
struct i2c_adapter;

/*** PROTOTYPES **************************************************************/

struct dvb_frontend* edc_1051_init_frontend(struct i2c_adapter *adapter);

#endif //#if !(define __EDC_1051_H__)
