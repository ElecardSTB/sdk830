/*
 * Copyright (C) 2013 by Elecard-STB.
 * Written by Anton Sergeev <Anton.Sergeev@elecard.ru>
 *
 * SP5650 ATSC NIM based on LG DT3305 and MxL603
 */
#if (!defined __SP5650_H__)
#define __SP5650_H__

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include "st_dvb.h"

/******************************************************************
* EXPORTED FUNCTIONS PROTOTYPES               <Module>_<Word>+    *
*******************************************************************/
struct dvb_frontend* sp5650_init_frontend(struct i2c_adapter *adapter);

#endif // __SP5650_H__
