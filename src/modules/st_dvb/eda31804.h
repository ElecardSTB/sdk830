/*
 * Copyright (C) 2014 by Elecard-STB.
 * Written by Anton Sergeev <Anton.Sergeev@elecard.ru>
 *
 * EDA-31804 ATSC NIM based on Panasonic MN88436 and MxL603
 */
#if (!defined __EDA31804_H__)
#define __EDA31804_H__

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include "st_dvb.h"

/******************************************************************
* EXPORTED FUNCTIONS PROTOTYPES               <Module>_<Word>+    *
*******************************************************************/
struct dvb_frontend* eda31804_init_frontend(struct i2c_adapter *adapter);

#endif // __EDA31804_H__
