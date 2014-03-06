/*
 * MN88436 demodulator driver
 *
 * Copyright (C) 2014 Anton Sergeev <Anton.Sergeev@elecard.ru>
 * 
 * This is header of private driver for mn88436.
 * See $PRJROOT/src/elecard/modules/mn88436 if have access.
 */

#ifndef __MN88436_H__
#define __MN88436_H__
/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include <linuxtv_common/linuxtv.h>


/******************************************************************
* EXPORTED TYPEDEFS                            [for headers only] *
*******************************************************************/
struct mn88436_config {
	uint8_t	i2c_sadr;
};

/******************************************************************
* EXPORTED FUNCTIONS PROTOTYPES               <Module>_<Word>+    *
*******************************************************************/
struct dvb_frontend *mn88436_attach(const struct mn88436_config *cfg, struct i2c_adapter *i2c);

#endif /* __MN88436_H__ */
