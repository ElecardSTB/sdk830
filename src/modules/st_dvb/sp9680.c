/*
 * Copyright (C) 2013 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *
 * SP9680 DVB-T2/T/C NIM based on Panasonic MN88472 and MxL603
 */

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include "sp9680.h"
#include "mn88472.h"

/******************************************************************
* LOCAL MACROS                                                    *
*******************************************************************/

/******************************************************************
* LOCAL TYPEDEFS                                                  *
*******************************************************************/
static struct mn88472_config sp9680_config = {
	.i2c_sadr = 0,
};

/******************************************************************
* FUNCTION IMPLEMENTATION                     <Module>_<Word>+    *
*******************************************************************/
struct dvb_frontend* sp9680_init_frontend(struct i2c_adapter *adapter)
{
	struct dvb_frontend * fe = dvb_attach(mn88472_attach, &sp9680_config, adapter);
	return fe;
}
