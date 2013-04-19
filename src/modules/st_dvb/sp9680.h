/*
 * Copyright (C) 2012 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *
 * SP9680 DVB-T2/T/C NIM based on Panasonic MN88472 and MxL603
 */
#if (!defined __SP9680_H__)
#define __SP9680_H__

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include "st_dvb.h"

/******************************************************************
* EXPORTED FUNCTIONS PROTOTYPES               <Module>_<Word>+    *
*******************************************************************/
struct dvb_frontend* sp9680_init_frontend(struct i2c_adapter *adapter);

#endif // __SP9680_H__
