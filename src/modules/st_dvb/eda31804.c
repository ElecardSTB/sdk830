/*
 * Copyright (C) 2014 by Elecard-STB.
 * Written by Anton Sergeev <Anton.Sergeev@elecard.ru>
 *
 * EDA-31804 ATSC NIM based on Panasonic MN88436 and MxL603
 */

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include "eda31804.h"
#include "mn88436.h"

/******************************************************************
* LOCAL MACROS                                                    *
*******************************************************************/
#define LGDT3305_ADDR	0x0e

/******************************************************************
* LOCAL TYPEDEFS                                                  *
*******************************************************************/
static struct mn88436_config eda31804_config = {
	.i2c_sadr = 0x18,
};

/******************************************************************
* FUNCTION IMPLEMENTATION                     <Module>_<Word>+    *
*******************************************************************/
struct dvb_frontend* eda31804_init_frontend(struct i2c_adapter *adapter)
{
	struct dvb_frontend *fe;

	fe = dvb_attach(mn88436_attach, &eda31804_config, adapter);
	return fe;
}
