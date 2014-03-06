/*
 * Copyright (C) 2012 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *
 * This is header of private driver for MxL603.
 * See $PRJROOT/src/elecard/modules/mxl603.
 */

#if !(defined __MXL603_H__)
#define __MXL603_H__

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include <dvb_frontend.h>

/******************************************************************
* EXPORTED MACROS                                                 *
*******************************************************************/
//#define MXL603_I2C_ADDR 0x96
#define MXL603_I2C_ADDR 0xC0//(0x60<<1)

/******************************************************************
* EXPORTED TYPEDEFS                                               *
*******************************************************************/
struct mxl603_config {
	uint8_t		i2c_addr;
	uint8_t		xtal_freq_id;//0 - 16MHz, 1 - 24MHz
	uint16_t	if_khz;

	uint8_t	externI2C; //use external set/get i2c functions
	void	*register_priv;
	int (*register_get)(void *priv, u8 addr, u8 reg, u8 *value);
	int (*register_set)(void *priv, u8 addr, u8 reg, u8  value);
};

/******************************************************************
* EXPORTED FUNCTIONS PROTOTYPES               <Module>_<Word>+    *
*******************************************************************/
extern struct dvb_frontend* mxl603_attach(struct dvb_frontend *fe,
										  struct i2c_adapter *i2c,
										  struct mxl603_config *config);

#endif //#if !(define __MXL603_H__)
