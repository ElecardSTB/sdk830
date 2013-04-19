/*
 * Copyright (C) 2012 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *
 * MxL201RF tuner driver header.
 */

#if !(defined __MXL201RF_H__)
#define __MXL201RF_H__

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include "st_dvb.h"
#include <linux/i2c.h>

//This is header of closed driver for MxL201RF. See $PRJROOT/src/elecard/modules/mxl201/.

/******************************************************************
* EXPORTED MACROS                                                 *
*******************************************************************/
#define MxL210RF_I2C_ADDRESS_PATH1	99
#define MxL210RF_I2C_ADDRESS_PATH2	96

/******************************************************************
* EXPORTED TYPEDEFS                                               *
*******************************************************************/
/* Enumeration of Acceptable IF Frequencies */
typedef enum
{
	MxL_IF_4_MHZ		= 4000000,
	MxL_IF_4_5_MHZ		= 4500000,
	MxL_IF_4_57_MHZ		= 4570000,
	MxL_IF_5_MHZ		= 5000000,
	MxL_IF_5_38_MHZ		= 5380000,
	MxL_IF_6_MHZ		= 6000000,
	MxL_IF_6_28_MHZ		= 6280000,
	MxL_IF_7_2_MHZ		= 7200000,
	MxL_IF_35_25_MHZ	= 35250000,
	MxL_IF_36_MHZ		= 36000000,
	MxL_IF_36_15_MHZ	= 36150000,
	MxL_IF_44_MHZ		= 44000000
} MxL201RF_IF_Freq ;

/******************************************************************
* EXPORTED FUNCTIONS PROTOTYPES               <Module>_<Word>+    *
*******************************************************************/
struct dvb_frontend* mxl201rf_attach(struct dvb_frontend *fe, struct i2c_adapter *i2c,
									  unsigned char tuner_addr, MxL201RF_IF_Freq if_freq);

#endif //#if !(define __MXL201RF_H__)
