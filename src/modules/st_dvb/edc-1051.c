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
//general
#include "linux/module.h"

//dvb
#include <linux/i2c.h>
//#include <drivers/media/dvb/dvb-core/dvbdev.h>
#include <tda1002x.h>
#include <dvb-pll.h>

#include "st_dvb.h"
#include "edc-1051.h"

/*** MODULE PARAMETERS *******************************************************/
static int edc_1051_debug = 0;
module_param_named(debug_edc_1051, edc_1051_debug, int, 0644);
MODULE_PARM_DESC(debug_edc_1051, "enable verbose debug messages");


//DVB_DEFINE_MOD_OPT_ADAPTER_NR(adapter_nums);

/*** GLOBAL VARIABLES *********************************************************/


/*** EXPORTED SYMBOLS ********************************************************/


/*** LOCAL TYPES *********************************************************/
struct EDC_1051_s {
	struct i2c_adapter *i2c_adapter;
	struct dvb_frontend *fe;
	struct dvb_adapter *dvb_adapter;
	int initialised;
};

/*** LOCAL CONSTANTS ********************************************************/
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

#define dprintk(format, args...) if (edc_1051_debug) { printk("%s[%d]: " format, __FILE__, __LINE__, ##args); }


/*** LOCAL VARIABLES *********************************************************/

struct EDC_1051_s edc_1051[FRONTEND_NUM] = {
	{ .initialised = 0 },
	{ .initialised = 0 },
};

/*** METHODS ****************************************************************/


int __init edc_1051_register_frontend(int slot_num, struct dvb_adapter *dvb_adapter)
{
	int err     = 0;  /* No error */
	struct dvb_frontend * fe = NULL;
	struct i2c_adapter *adapter = NULL;
	int i2c_bus = 0;
	struct EDC_1051_s *edc_1051_private;

	if( (slot_num < 0) || (slot_num >= FRONTEND_NUM) ) {
		dprintk("slot_num=%d should be 0,1\n", slot_num);
		err = -1;
		goto error;
	}

	edc_1051_private = &(edc_1051[slot_num]);
	edc_1051_private->dvb_adapter = dvb_adapter;

	i2c_bus = get_i2c_bus(slot_num);
	adapter = i2c_get_adapter(i2c_bus);
	if( !adapter ) {
		dprintk("cant get i2c adapter\n");
		err = -1;
		goto err1;
	}
	edc_1051_private->i2c_adapter = adapter;
	fe = dvb_attach(tda10023_attach, &EDC_1051_tda10024_config,
				edc_1051_private->i2c_adapter, 0);
	if( !fe ) {
		dprintk("cant attach tda10024\n");
		err = -1;
		goto err1;
	}
	dprintk("tda10023 attached\n");
	edc_1051_private->fe = fe;
	dvb_attach(dvb_pll_attach, edc_1051_private->fe, 0x61,
			edc_1051_private->i2c_adapter,
			DVB_PLL_TDA665X);
	dprintk("pll attached\n");

	if (dvb_register_frontend(edc_1051_private->dvb_adapter, edc_1051_private->fe))
	{
	  dprintk("Frontend registration failed!\n");
	  dvb_frontend_detach(edc_1051_private->fe);
	  err = -1;
	  goto err2;
	}
	edc_1051_private->initialised = 1;
//	dprintk("EDC-1051 slot_num=%d i2c_bus=%d successfully initialized\n", slot_num, i2c_bus);
	printk("EDC-1051 slot_num=%d on i2c_bus=%d successfully initialized\n", slot_num, i2c_bus);

	return (0);  /* If we get here then we have succeeded */

	/**************************************************************************/
err2:
	dvb_frontend_detach(edc_1051_private->fe);
err1:

error :
	return (err);
}


/*=============================================================================

   edc_1051_unregister_frontend

   Unregister edc-1051 slot_num.

  ===========================================================================*/
void __exit edc_1051_unregister_frontend(int slot_num)
{
	struct EDC_1051_s *edc_1051_private;

	if( (slot_num < 0) || (slot_num >= FRONTEND_NUM) ) {
		dprintk("slot_num=%d should be 0,1\n", slot_num);
		return ;
	}

	edc_1051_private = &(edc_1051[slot_num]);
	if(edc_1051_private->initialised) {
		dvb_unregister_frontend(edc_1051_private->fe);
		dvb_frontend_detach(edc_1051_private->fe);
	}

	dprintk("edc-1051 unregister slot=%d\n", slot_num);
}

