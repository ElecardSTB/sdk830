/*
 * Copyright (C) 2012 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *
 * MxL9201S01 dvb-t2/dvb-c nim based on Sony MxL201RF and CX2820R
 */

#include <dvb_frontend.h>

#include "sonydvbt2.h"
#include "st_dvb.h"

#include "cxd2820r.h"

#include "mxl201rf_tuner.h"
//#include "MxL201RF_Common.h"


#define  CXD2820R_I2C_U1 0x6c
#define  CXD2820R_I2C_U2 0x6d

#define dprintk(format, args...) if (st_dvb_debug) { printk("%s[%d]: " format, __FILE__, __LINE__, ##args); }


struct sonydvbt2_status {
	struct dvb_frontend * frontend;
	int initialised;
};

struct sonydvbt2_status sonydvbt2_status[FRONTEND_NUM] = {
	{ .initialised = 0, },
	{ .initialised = 0, },
};

typedef struct sonydvbt2_config {
	struct cxd2820r_config cxd2820r_config;
	struct {
		unsigned char tuner_addr;
		MxL201RF_IF_Freq if_freq;
	} mxl201rf_config;
} sonydvbt2_config;

static sonydvbt2_config pioneer_config = {
	.cxd2820r_config = {
	.i2c_address = CXD2820R_I2C_U1,
	.ts_mode     = CXD2820R_TS_PARALLEL_MSB|CXD2820R_TS_CLK_ACTIVE,
	.if_agc_polarity = 0,
	.if_dvbt_6  = 5000,
	.if_dvbt_7  = 5000,
	.if_dvbt_8  = 5000,
	.if_dvbt2_5 = 5000,
	.if_dvbt2_6 = 5000,
	.if_dvbt2_7 = 5000,
	.if_dvbt2_8 = 5000,
	.if_dvbc    = 5000,
	.gpio_dvbt   = { CXD2820R_GPIO_D, CXD2820R_GPIO_E|CXD2820R_GPIO_O|CXD2820R_GPIO_L, CXD2820R_GPIO_D },
	.gpio_dvbc   = { CXD2820R_GPIO_D, CXD2820R_GPIO_E|CXD2820R_GPIO_O|CXD2820R_GPIO_L, CXD2820R_GPIO_D },
	.gpio_dvbt2  = { CXD2820R_GPIO_D, CXD2820R_GPIO_E|CXD2820R_GPIO_O|CXD2820R_GPIO_L, CXD2820R_GPIO_D },
	},
	.mxl201rf_config = {
	.tuner_addr = MxL210RF_I2C_ADDRESS_PATH2,
	.if_freq    = MxL_IF_5_MHZ,
	},
};

int sonydvbt2_check_pll(struct dvb_frontend * fe, struct i2c_adapter *adapter, unsigned char tuner_addr)
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
	if (fe->ops.i2c_gate_ctrl)
		fe->ops.i2c_gate_ctrl(fe, 1);
	ret = i2c_transfer(adapter, msg, 1);
	if (ret != 1)
		dprintk("Read from tuner address %02x: error %d\n", tuner_addr, ret);
	if (fe->ops.i2c_gate_ctrl)
		fe->ops.i2c_gate_ctrl(fe, 0);
	return ret;
}

int sonydvbt2_register_frontend(int slot_num, struct dvb_adapter *dvb_adapter)
{
	int err = 0;
	int i2c_bus;
	struct i2c_adapter *adapter;
	struct dvb_frontend * fe = NULL;

	if ((slot_num < 0) || (slot_num >= FRONTEND_NUM) ) {
		dprintk("slot_num=%d should be 0,1\n", slot_num);
		err = -1;
		goto error;
	}

	i2c_bus = get_i2c_bus(slot_num);
	adapter = i2c_get_adapter(i2c_bus);
	if (!adapter) {
		dprintk("cant get i2c adapter\n");
		err = -1;
		goto error;
	}

	fe = dvb_attach(cxd2820r_attach, &pioneer_config.cxd2820r_config, adapter);
	if (!fe) {
		dprintk("cant attach cxd2820r\n");
		err = -1;
		goto error;
	}
	fe->dtv_property_cache.delivery_system = SYS_DVBT;
	fe->ops.info.type = FE_OFDM;
	dprintk("[%d] cxd2820r (DVB-T) attached\n", slot_num);

	sonydvbt2_status[slot_num].frontend = fe;

	pioneer_config.mxl201rf_config.tuner_addr = MxL210RF_I2C_ADDRESS_PATH1;
	if (sonydvbt2_check_pll(fe, adapter, pioneer_config.mxl201rf_config.tuner_addr) < 0) {
		pioneer_config.mxl201rf_config.tuner_addr = MxL210RF_I2C_ADDRESS_PATH2;
		if (sonydvbt2_check_pll(fe, adapter, pioneer_config.mxl201rf_config.tuner_addr) < 0) {
			dprintk("[%d] failed to detect mxl201rf\n", slot_num);
			err = -1;
			goto tuner_error;
		}
	}

	fe = dvb_attach(mxl201rf_attach, sonydvbt2_status[slot_num].frontend, adapter,
	                pioneer_config.mxl201rf_config.tuner_addr, pioneer_config.mxl201rf_config.if_freq);
	if (!fe) {
		dprintk("[%d] cant attach mxl201rf\n", slot_num);
		err = -1;
		goto tuner_error;
	}
	dprintk("[%d] mxl201rf attached\n", slot_num);

	if (dvb_register_frontend(dvb_adapter, sonydvbt2_status[slot_num].frontend))
	{
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
	if ((slot_num < 0) || (slot_num >= FRONTEND_NUM) ) {
		dprintk("slot_num=%d should be 0,1\n", slot_num);
		return ;
	}

	if (sonydvbt2_status[slot_num].initialised) {
		dvb_unregister_frontend(sonydvbt2_status[slot_num].frontend);
		dvb_frontend_detach(sonydvbt2_status[slot_num].frontend);
	}

	dprintk("[%d] sonydvbt2 unregister\n", slot_num);
}
