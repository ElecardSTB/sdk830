/*
 * Copyright (C) 2013 by Elecard-STB.
 * Written by Anton Sergeev <Anton.Sergeev@elecard.ru>
 *
 * SP5650 ATSC NIM based on LG DT3305 and MxL603
 */

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include "sp5650.h"
#include "mxl603.h"
#include <lgdt3305.h>

/******************************************************************
* LOCAL MACROS                                                    *
*******************************************************************/
#define LGDT3305_ADDR	0x0e

/******************************************************************
* LOCAL TYPEDEFS                                                  *
*******************************************************************/
static struct lgdt3305_config lgdt3305_cfg = {
	.i2c_addr = LGDT3305_ADDR,

	/* user defined IF frequency in KHz */
	.qam_if_khz = 5000,//5MHz
	.vsb_if_khz = 5000,//5MHz

	/* AGC Power reference - defaults are used if left unset */
//	u16 usref_8vsb;   /* default: 0x32c4 */
//	u16 usref_qam64;  /* default: 0x5400 */
//	u16 usref_qam256; /* default: 0x2a80 */

	/* disable i2c repeater - 0:repeater enabled 1:repeater disabled */
//	unsigned int deny_i2c_rptr:1;

	/* spectral inversion - 0:disabled 1:enabled */
//	unsigned int spectral_inversion:1;

	/* use RF AGC loop - 0:disabled 1:enabled */
//	unsigned int rf_agc_loop:1;

	.mpeg_mode = LGDT3305_MPEG_PARALLEL,
	.tpclk_edge = LGDT3305_TPCLK_RISING_EDGE,
	.tpvalid_polarity = LGDT3305_TP_VALID_HIGH,
	.demod_chip = LGDT3305,
};

static struct mxl603_config mxl603_cfg = {
	.i2c_addr = 0x60,
	.externI2C = 0,
//	void *demod_priv;
//	int (*register_get)(void *priv, u8 addr, u8 reg, u8 *value);
//	int (*register_set)(void *priv, u8 addr, u8 reg, u8  value);
};

/******************************************************************
* FUNCTION IMPLEMENTATION                     <Module>_<Word>+    *
*******************************************************************/
struct dvb_frontend* sp5650_init_frontend(struct i2c_adapter *adapter)
{
	struct dvb_frontend *fe;
	struct dvb_frontend *pll = NULL;

	fe = dvb_attach(lgdt3305_attach, &lgdt3305_cfg, adapter);
	if(fe) {
		pll = dvb_attach(mxl603_attach, fe, adapter, &mxl603_cfg);
	}
	return fe;
}
