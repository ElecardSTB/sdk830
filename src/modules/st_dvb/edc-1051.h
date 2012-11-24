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

#include <dvbdev.h>


/*** PROTOTYPES **************************************************************/

extern int edc_1051_register_frontend(int slot_num, struct dvb_adapter *dvb_adapter);
extern void edc_1051_unregister_frontend(int slot_num);

#endif //#if !(define __EDC_1051_H__)
