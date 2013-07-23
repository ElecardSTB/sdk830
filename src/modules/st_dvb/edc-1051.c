/*
 * Copyright (C) 2011 by Elecard-STB.
 * Written by Anton Sergeev <Anton.Sergeev@elecard.ru>
 * 
 * This is init for dvb-c nim EDC-1051.
 * 
 */
/**
 @File   edc-1051.c
 @brief
*/
/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include <linux/module.h>
#include <linux/i2c.h>

#include "st_dvb.h"
#include <tda1002x.h>
#include <dvb-pll.h>

#include "edc-1051.h"

/******************************************************************
* LOCAL MACROS                                                    *
*******************************************************************/
#undef dprintk
#define dprintk(format, args...) if (edc_1051_debug) { printk("%s[%d]: " format, __FILE__, __LINE__, ##args); }

/******************************************************************
* STATIC DATA                                                     *
*******************************************************************/
static struct tda10023_config EDC_1051_tda10024_config = {
	/* the demodulator's i2c address */
	.demod_address = 0x0c,
	.invert = 1,

	/* clock settings */
//	u32 xtal; /* defaults: 28920000 */
//	u8 pll_m; /* defaults: 8 */
//	u8 pll_p; /* defaults: 4 */
//	u8 pll_n; /* defaults: 1 */

	/* MPEG2 TS output mode */
//	u8 output_mode;

	/* input freq offset + baseband conversion type */
//	.deltaf = 36000000,
};

/******************************************************************
* MODULE PARAMETERS                                               *
*******************************************************************/
static int edc_1051_debug = 0;
module_param_named(debug_edc_1051, edc_1051_debug, int, 0644);
MODULE_PARM_DESC(debug_edc_1051, "enable verbose debug messages");

/******************************************************************
* FUNCTION IMPLEMENTATION                                         *
*******************************************************************/
struct dvb_frontend* edc_1051_init_frontend(struct i2c_adapter *adapter)
{
	struct dvb_frontend * fe = NULL;

	fe = dvb_attach(tda10023_attach, &EDC_1051_tda10024_config,
				adapter, 0);
	if( !fe ) {
		dprintk("cant attach tda10024\n");
		return NULL;
	}
	dprintk("tda10023 attached\n");
	dvb_attach(dvb_pll_attach, fe, 0x61,
			adapter,
			DVB_PLL_TDA665X);

	printk("EDC-1051 successfully initialized\n");
	return fe;
}
