/*
 * Copyright (C) 2012 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *            Anton Sergeev <Anton.Sergeev@elecard.ru>
 *
 * MxL9201S01 dvb-t2/dvb-c nim based on Sony MxL201RF and CX2820R.
 * Also supports connective CX2820R with TDA665x.
 */

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#ifdef USE_LINUXTV
#include <uapi/linux/dvb/frontend.h>
//#include <v4l/config-compat.h>
#else
//#include <dvb_frontend.h>
#endif

#include <dvb-pll.h>

#include "sonydvbt2.h"
#include "st_dvb.h"
#include "cxd2820r.h"
#include "mxl201rf_tuner.h"
//#include "MxL201RF_Common.h"

/******************************************************************
* LOCAL MACROS                                                    *
*******************************************************************/
#define  CXD2820R_I2C_U1 0x6c
#define  CXD2820R_I2C_U2 0x6d

#define dprintk(format, args...) if (st_dvb_debug) { printk("%s[%d]: " format, __FILE__, __LINE__, ##args); }

/******************************************************************
* LOCAL TYPEDEFS                                                  *
*******************************************************************/
struct sonydvbt2_status {
	struct dvb_frontend *frontend;
	int initialised;
};

struct sonydvbt2_status sonydvbt2_status[FRONTEND_NUM] = {
	{ .initialised = 0, },
	{ .initialised = 0, },
};

typedef enum {
	ePllType_mxl201,
	ePllType_tda6651,

	ePllType_count,
} ePllType;

typedef struct {
	char		*name;
	ePllType	type;
	uint8_t		i2c_addr;
} pllDescription_t;

/******************************************************************
* STATIC DATA                                                     *
*******************************************************************/
static struct cxd2820r_config	cxd2820r_cfg = {
	.i2c_address = CXD2820R_I2C_U1,
#ifdef USE_LINUXTV
	.ts_mode     = CXD2820R_TS_PARALLEL_MSB,
#else
	.ts_mode     = CXD2820R_TS_PARALLEL_MSB | CXD2820R_TS_CLK_ACTIVE,
	.if_agc_polarity = 0,
	.if_dvbt_6  = 5000,
	.if_dvbt_7  = 5000,
	.if_dvbt_8  = 5000,
	.if_dvbt2_5 = 5000,
	.if_dvbt2_6 = 5000,
	.if_dvbt2_7 = 5000,
	.if_dvbt2_8 = 5000,
	.if_dvbc    = 5000,
	.gpio_dvbt   = { CXD2820R_GPIO_D, CXD2820R_GPIO_E | CXD2820R_GPIO_O | CXD2820R_GPIO_L, CXD2820R_GPIO_D },
	.gpio_dvbc   = { CXD2820R_GPIO_D, CXD2820R_GPIO_E | CXD2820R_GPIO_O | CXD2820R_GPIO_L, CXD2820R_GPIO_D },
	.gpio_dvbt2  = { CXD2820R_GPIO_D, CXD2820R_GPIO_E | CXD2820R_GPIO_O | CXD2820R_GPIO_L, CXD2820R_GPIO_D },
#endif
};

pllDescription_t pllDescripton[] = {
	{"Maxlinear MXL201 pll on path1",	ePllType_mxl201,	MxL210RF_I2C_ADDRESS_PATH1},
	{"Maxlinear MXL201 pll on path2",	ePllType_mxl201,	MxL210RF_I2C_ADDRESS_PATH2},
	{"Philips TDA6650/TDA6651 pll",		ePllType_tda6651,	0x61},
};

/******************************************************************
* FUNCTION IMPLEMENTATION                     <Module>_<Word>+    *
*******************************************************************/
int sonydvbt2_check_pll(struct dvb_frontend *fe, struct i2c_adapter *adapter, unsigned char tuner_addr)
{
	int ret;
	u8 buf[1];
	struct i2c_msg msg[1] = {
		{
			.addr = tuner_addr,
			.flags = I2C_M_RD,
			.len = 1,
			.buf = buf,
		}
	};
	if(fe->ops.i2c_gate_ctrl) {
		fe->ops.i2c_gate_ctrl(fe, 1);
	}
	ret = i2c_transfer(adapter, msg, 1);
	if(ret != 1) {
		dprintk("Read from tuner address %02x: error %d\n", tuner_addr, ret);
	}
	if(fe->ops.i2c_gate_ctrl) {
		fe->ops.i2c_gate_ctrl(fe, 0);
	}
	return ret;
}

int sonydvbt2_register_frontend(int slot_num, struct dvb_adapter *dvb_adapter)
{
	int32_t		err = 0;
	uint32_t	i2c_bus;
	uint32_t	pllId;
	struct i2c_adapter *adapter;
	struct dvb_frontend *fe = NULL;

	if((slot_num < 0) || (slot_num >= FRONTEND_NUM)) {
		dprintk("slot_num=%d should be 0,1\n", slot_num);
		err = -1;
		goto error;
	}

	i2c_bus = get_i2c_bus(slot_num);
	adapter = i2c_get_adapter(i2c_bus);
	if(!adapter) {
		dprintk("cant get i2c adapter\n");
		err = -1;
		goto error;
	}

#ifdef USE_LINUXTV
	fe = dvb_attach(cxd2820r_attach, &cxd2820r_cfg, adapter, NULL);
#else
	fe = dvb_attach(cxd2820r_attach, &cxd2820r_cfg, adapter);
#endif
	if(!fe) {
		dprintk("cant attach cxd2820r\n");
		err = -1;
		goto error;
	}
	fe->dtv_property_cache.delivery_system = SYS_DVBT;
	fe->ops.info.type = FE_OFDM;
	dprintk("[%d] cxd2820r (DVB-T) attached\n", slot_num);
// 	fe->dtv_property_cache.delivery_system = SYS_DVBC_ANNEX_A;
// 	fe->ops.info.type = FE_QAM;
// 	dprintk("[%d] cxd2820r (DVB-C) attached\n", slot_num);

	sonydvbt2_status[slot_num].frontend = fe;

	for(pllId = 0; pllId < ARRAY_SIZE(pllDescripton); pllId++) {
		pllDescription_t *pllDescr = pllDescripton + pllId;
		if(sonydvbt2_check_pll(fe, adapter, pllDescr->i2c_addr) == 1) {
			break;
		}
	}
	if(pllId >= ARRAY_SIZE(pllDescripton)) {
		dprintk("[%d] failed to detect pll\n", slot_num);
		err = -1;
		goto tuner_error;
	}

	fe = NULL;
	if(pllDescripton[pllId].type == ePllType_mxl201) {
		fe = dvb_attach(mxl201rf_attach, sonydvbt2_status[slot_num].frontend,
						adapter, pllDescripton[pllId].i2c_addr, MxL_IF_5_MHZ);
	} else if(pllDescripton[pllId].type == ePllType_tda6651) {
		fe = dvb_attach(dvb_pll_attach, sonydvbt2_status[slot_num].frontend,
						pllDescripton[pllId].i2c_addr, adapter, DVB_PLL_TDA665X);
	}
	if(!fe) {
		dprintk("[%d] cant attach %s\n", slot_num, pllDescripton[pllId].name);
		err = -1;
		goto tuner_error;
	}
	dprintk("[%d] %s attached\n", slot_num, pllDescripton[pllId].name);

	if(dvb_register_frontend(dvb_adapter, sonydvbt2_status[slot_num].frontend)) {
		dprintk("[%d] Frontend registration failed!\n", slot_num);
		err = -1;
		goto tuner_error;
	}

	dprintk("[%d] sonydvbt2 registered\n", slot_num);

	sonydvbt2_status[slot_num].initialised = 1;

	return 0;

tuner_error:
	dvb_frontend_detach(sonydvbt2_status[slot_num].frontend);
	sonydvbt2_status[slot_num].frontend = NULL;
error:
	return err;
}

void sonydvbt2_unregister_frontend(int slot_num)
{
	if((slot_num < 0) || (slot_num >= FRONTEND_NUM)) {
		dprintk("slot_num=%d should be 0,1\n", slot_num);
		return ;
	}

	if(sonydvbt2_status[slot_num].initialised) {
		dvb_unregister_frontend(sonydvbt2_status[slot_num].frontend);
		dvb_frontend_detach(sonydvbt2_status[slot_num].frontend);
	}

	dprintk("[%d] sonydvbt2 unregister\n", slot_num);
}
