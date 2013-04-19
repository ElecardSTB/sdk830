/*
 * MN88472 demodulator driver
 *
 * Copyright (C) 2013 Andrey Kuleshov <andrey.kuleshov@elecard.ru>
 */

#ifndef __MN88472_H__
#define __MN88472_H__

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include "st_dvb.h"

//This is header of closed driver for mn88472. See $PRJROOT/src/elecard/modules/mn88472/ if have access.

/******************************************************************
* EXPORTED TYPEDEFS                                               *
*******************************************************************/
struct mn88472_config {
	/* Demodulator I2C address SADR pin state
	 * The lower bit of the slave adresses
	 * Default: none, must set
	 * Values: 0,1
	 */
	u8 i2c_sadr;
};

/******************************************************************
* EXPORTED FUNCTIONS PROTOTYPES               <Module>_<Word>+    *
*******************************************************************/
struct dvb_frontend *mn88472_attach(const struct mn88472_config *config, struct i2c_adapter *i2c);

#endif /* __MN88472_H__ */
