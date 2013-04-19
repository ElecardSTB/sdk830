/*
 * Copyright (C) 2011 by Elecard-STB.
 * Written by Anton Sergeev <Anton.Sergeev@elecard.ru>
 * 
 * ST`s DVB CA en50221 header.
 * 
 */
/**
 @File   st_dvb_ca_en50221.h
 @brief
*/

#if !(defined __ST_DVB_CA_EN502211_H__)
#define __ST_DVB_CA_EN502211_H__

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include "st_dvb.h"

//This functions are part of stapisdk now. See $PRJROOT/src/elecard/stapisdk/$STAPISDK_VERSION_overlay/apilib/src/stpccrd/linux/stpccrd_core/.
/******************************************************************
* EXPORTED FUNCTIONS PROTOTYPES               <Module>_<Word>+    *
*******************************************************************/
int  st_dvb_init_stpccrd(void);
void st_dvb_release_stpccrd(void);
int  st_dvb_init_ca(int slot_num, struct dvb_adapter *dvb_adapter);
void st_dvb_release_ca(int slot_num);

#endif //#if !(define __ST_DVB_CA_EN502211_H__)
