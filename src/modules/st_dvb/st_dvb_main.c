/*
 * Copyright (C) 2011 by Elecard-STB.
 * Written by Anton Sergeev <Anton.Sergeev@elecard.ru>
 * 
 * Initialization dvb subsystem for STB.
 * 
 */
/**
 @File   st_dvb.c
 @brief
*/

/******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include <linux/module.h>
#include <linux/i2c.h>

//local
#include "st_dvb.h"
#include "edc-1051.h"
#include "sonydvbt2.h"
#include "sp9680.h"
#include "sp5650.h"
#include "eda31804.h"
#include "st_dvb_ca_en50221.h"


/******************************************************************
* LOCAL MACROS                                                    *
*******************************************************************/
#define DVB_NUMS 2

#if 1
#define DVB_CI_FUNC(FUNCTION, ARGS...) \
({ \
	int32_t __ret = 0; \
	typeof(&FUNCTION) __a = symbol_request(FUNCTION); \
	if(__a == NULL) { \
		printk("Cant find %s()\n", #FUNCTION); \
		__ret = -1; \
	} else { \
		__a(ARGS); \
		symbol_put_addr(__a); \
	}; \
	__ret; \
})
#else
#define DVB_CI_FUNC(FUNCTION, ...) FUNCTION(ARGS)
#endif


/******************************************************************
* LOCAL TYPEDEFS                                                  *
*******************************************************************/
struct frontend_ops_s {
	char *name;
	struct dvb_frontend* (*init_frontend)(struct i2c_adapter *);
};

struct st_dvb_s {
	char					*name;
	uint8_t					dvb_adapter_reg;
	struct dvb_adapter		dvb_adapter;
	struct dvb_frontend		*frontend;
	struct frontend_ops_s	*fops;
};


/******************************************************************
* STATIC DATA                                                     *
*******************************************************************/
/*** MODULE INFO *************************************************************/
MODULE_AUTHOR("SergA");
MODULE_DESCRIPTION("Elecard-STB");
MODULE_SUPPORTED_DEVICE("STi7105 dvb-ci, EDC-1051, SONY_DVBT2");
MODULE_LICENSE("GPL");

/*** MODULE PARAMETERS *******************************************************/
int st_dvb_debug = 0;
module_param_named(debug_st_dvb, st_dvb_debug, int, 0644);
MODULE_PARM_DESC(debug_st_dvb, "enable verbose debug in st_dvb_main messages");

static char *frontend_param[2] = { "NONE", "NONE" };
module_param_named(fe0, frontend_param[0], charp, 0644);
MODULE_PARM_DESC(fe0, "First frontend name");

module_param_named(fe1, frontend_param[1], charp, 0644);
MODULE_PARM_DESC(fe1, "Second frontend name");

static int32_t frontend_i2c_bus[2] = { 3, 2 };
module_param_named(fe0_i2c_bus, frontend_i2c_bus[0], int, 0644);
MODULE_PARM_DESC(fe0_i2c_bus, "First frontend i2c bus");

module_param_named(fe1_i2c_bus, frontend_i2c_bus[1], int, 0644);
MODULE_PARM_DESC(fe1_i2c_bus, "Second frontend i2c bus");

static bool ci_enable[2] = { 0, 0 };
module_param_named(ci0, ci_enable[0], bool, 0644);
MODULE_PARM_DESC(ci0, "Enable first dvb-ci");

module_param_named(ci1, ci_enable[1], bool, 0644);
MODULE_PARM_DESC(ci1, "Enable second dvb-ci");


struct st_dvb_s st_dvb[DVB_NUMS] = {
	{.name = "ST DVB slot 0", .dvb_adapter_reg = 0, .frontend = NULL, .fops = NULL, },
	{.name = "ST DVB slot 1", .dvb_adapter_reg = 0, .frontend = NULL, .fops = NULL, },
};

struct frontend_ops_s frontend_ops[] = {
	{"EDC_1051",		edc1051_init_frontend},
	{"SONY_DVBT2",		sonydvbt2_init_frontend},
	{"NIM_SP9680",		sp9680_init_frontend},
	{"NIM_SP5650",		sp5650_init_frontend},
	{"NIM_EDA31804",	eda31804_init_frontend},
};


/******************************************************************
* FUNCTION IMPLEMENTATION                     <Module>_<Word>+    *
*******************************************************************/
static int32_t __init st_dvb_register_frontend(struct st_dvb_s *p_st_dvb, struct frontend_ops_s *fe_ops_p, struct i2c_adapter *i2c_adap)
{
	if(!fe_ops_p || !fe_ops_p->init_frontend) {
		return -1;
	}

	dprintk("%s init\n", fe_ops_p->name);

	p_st_dvb->frontend = fe_ops_p->init_frontend(i2c_adap);
	if(p_st_dvb->frontend == NULL) {
		printk(KERN_ERR ": Failed to initialize frontend %s\n", fe_ops_p->name);
		return -2;
	}

	if(dvb_register_frontend(&p_st_dvb->dvb_adapter, p_st_dvb->frontend) != 0) {
		printk(KERN_ERR ": Failed to register frontend %s\n", fe_ops_p->name);
		dvb_frontend_detach(p_st_dvb->frontend);
		p_st_dvb->frontend = NULL;
		return -3;
	}
	p_st_dvb->fops = fe_ops_p;

	return 0;
}

static int32_t __init st_dvb_init_module(void)
{
	int err = 0;
	static short adapter_nums[] = {
					[0] = 0,
					[1 ... (DVB_MAX_ADAPTERS - 1)] = DVB_UNSET
				};
	int i, j;
	
	if(ci_enable[0] || ci_enable[1]) {
		if(DVB_CI_FUNC(st_dvb_init_stpccrd) != 0) {
			return -1;
		}
	}

	for(i = 0; i < DVB_NUMS; i++) {
		struct st_dvb_s *p_st_dvb = st_dvb + i;
		struct dvb_adapter *dvb_adap = &(p_st_dvb->dvb_adapter);
		struct i2c_adapter *i2c_adap = i2c_get_adapter(frontend_i2c_bus[i]);

		if(i2c_adap == NULL) {
			continue;
		}

		adapter_nums[0] = i;
		// Use i2c_adap->dev for correct work dev_*() functions
		if((err = dvb_register_adapter(dvb_adap, p_st_dvb->name, THIS_MODULE, &(i2c_adap->dev), adapter_nums)) < 0) {
			dprintk("dvb_register_adapter failed (errno = %d)\n", err);
			continue;
		}
		p_st_dvb->dvb_adapter_reg = 1;

		//init dvb-ca
		if(ci_enable[i]) {
			if(DVB_CI_FUNC(st_dvb_init_ca, i, dvb_adap) != 0) {
				return -1;
			}
		}

		//init frontend
		for(j = 0; j < ARRAY_SIZE(frontend_ops); j++) {
			struct frontend_ops_s *fe_ops_p = frontend_ops + j;
			if (!strncmp(frontend_param[i], fe_ops_p->name, strlen(fe_ops_p->name))) {
				st_dvb_register_frontend(p_st_dvb, fe_ops_p, i2c_adap);
			}
		}
	}
	return 0;
}

static void __exit st_dvb_cleanup_module(void)
{
	int i;
	for(i = 0; i < DVB_NUMS; i++) {
		if(st_dvb[i].frontend) {
			dprintk("%s deinit\n", st_dvb[i].fops->name);
			dvb_unregister_frontend(st_dvb[i].frontend);
			dvb_frontend_detach(st_dvb[i].frontend);
		}
		if(ci_enable[i]) {
			DVB_CI_FUNC(st_dvb_release_ca, i);
		}
		if(st_dvb[i].dvb_adapter_reg) {
			dvb_unregister_adapter(&(st_dvb[i].dvb_adapter));
		}
//		st_dvb[i].fops = NULL;
	}
	if(ci_enable[0] || ci_enable[1]) {
		DVB_CI_FUNC(st_dvb_release_stpccrd);
	}
}

/*** MODULE LOADING ******************************************************/

/* Tell the module system these are our entry points. */
module_init(st_dvb_init_module);
module_exit(st_dvb_cleanup_module);
