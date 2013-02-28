/*
 * Copyright (C) 2011 by Elecard-STB.
 * Written by Anton Sergeev <Anton.Sergeev@elecard.ru>
 * 
 * Initialization dvb for ST.
 * 
 */
/**
 @File   st_dvb.c
 @brief
*/
//general
#include <dvb_frontend.h>
#include <linux/module.h>
#include <linux/i2c.h>

//local
#include "edc-1051.h"
#include "sonydvbt2.h"
#include "st_dvb_ca_en50221.h"

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

static bool ci_enable[2] = { 0, 0 };
module_param_named(ci0, ci_enable[0], bool, 0644);
MODULE_PARM_DESC(ci0, "Enable first dvb-ci");

module_param_named(ci1, ci_enable[1], bool, 0644);
MODULE_PARM_DESC(ci1, "Enable second dvb-ci");

/*** LOCAL TYPES *********************************************************/

struct frontend_ops_s {
	char *name;
	struct dvb_frontend* (*init_frontend)(struct i2c_adapter *);
};

struct st_dvb_s {
	char					*name;
	int						i2c_bus;
	struct dvb_adapter		dvb_adapter;
	struct dvb_frontend		*frontend;
	struct frontend_ops_s	*fops;
};

/*** LOCAL CONSTANTS ********************************************************/

#define DVB_NUMS 2

#define dprintk(format, args...) if (st_dvb_debug) { printk("%s[%d]: " format, __FILE__, __LINE__, ##args); }

#if 1
#define DVB_CI_FUNC(FUNCTION, RETURN, ...) \
{ \
	typeof(&FUNCTION) __a = symbol_request(FUNCTION); \
	if(__a == NULL) { \
		printk("Cant find %s()\n", #FUNCTION); \
		return RETURN; \
	} else { \
		__a(__VA_ARGS__); \
	}; \
}
#else
#define DVB_CI_FUNC(FUNCTION, ...) FUNCTION(__VA_ARGS__)
#endif

/*** LOCAL VARIABLES *********************************************************/
struct st_dvb_s st_dvb[DVB_NUMS] = {
	{.name = "ST DVB slot 0", .i2c_bus = 3, .frontend = NULL, .fops = NULL, },
	{.name = "ST DVB slot 1", .i2c_bus = 2, .frontend = NULL, .fops = NULL, },
};

struct frontend_ops_s frontend_ops[] = {
	{"EDC_1051"			,edc_1051_init_frontend},
	{"SONY_DVBT2"		,sonydvbt2_init_frontend},
};

/*** METHODS ****************************************************************/

static void st_dvb_register_frontend(int slot, struct frontend_ops_s *fe_ops_p)
{
	struct i2c_adapter *adapter = i2c_get_adapter(st_dvb[slot].i2c_bus);

	dprintk("%s init\n", fe_ops_p->name);
	st_dvb[slot].frontend = fe_ops_p->init_frontend(adapter);
	if (!st_dvb[slot].frontend)
		return;

	if (dvb_register_frontend(&st_dvb[slot].dvb_adapter, st_dvb[slot].frontend)) {
		printk(KERN_ERR ": Failed to register frontend %s\n", fe_ops_p->name);
		dvb_frontend_detach(st_dvb[slot].frontend);
		st_dvb[slot].frontend = 0;
	} else
		st_dvb[slot].fops = fe_ops_p;
}

static int __init st_dvb_init_module(void)
{
	int err = 0;
	static short adapter_nums[] = {
					[0] = 0,
					[1 ... (DVB_MAX_ADAPTERS - 1)] = DVB_UNSET
				};
	int i, j;

	if (ci_enable[0] || ci_enable[1])
		DVB_CI_FUNC(st_dvb_init_stpccrd, -1);

	for(i = 0; i < DVB_NUMS; i++) {
		struct dvb_adapter *dvb_adapter = &(st_dvb[i].dvb_adapter);

		adapter_nums[0] = i;
		if ((err = dvb_register_adapter(dvb_adapter, st_dvb[i].name, THIS_MODULE, NULL, adapter_nums)) < 0) {
			dprintk("dvb_register_adapter failed (errno = %d)\n", err);
			continue;
		}
		//init dvb-ca
		if(ci_enable[i])
			DVB_CI_FUNC(st_dvb_init_ca, -1, i, dvb_adapter);

		//init frontend
		for(j = 0; j < ARRAY_SIZE(frontend_ops); j++) {
			struct frontend_ops_s *fe_ops_p = frontend_ops + j;
			if (!strncmp(frontend_param[i], fe_ops_p->name, strlen(fe_ops_p->name)))
				st_dvb_register_frontend(i, fe_ops_p);
		}
	}
	return 0;
}

static void __exit st_dvb_cleanup_module(void)
{
	int i;
	for (i = 0; i < DVB_NUMS; i++) {
		if (st_dvb[i].frontend) {
			dprintk("%s deinit\n", st_dvb[i].fops->name);
			dvb_unregister_frontend(st_dvb[i].frontend);
			dvb_frontend_detach(st_dvb[i].frontend);
		}
		DVB_CI_FUNC(st_dvb_release_ca, ,i);
		dvb_unregister_adapter(&(st_dvb[i].dvb_adapter));
		st_dvb[i].fops = NULL;
	}
	DVB_CI_FUNC(st_dvb_release_stpccrd,);
}

/*** MODULE LOADING ******************************************************/

/* Tell the module system these are our entry points. */
module_init(st_dvb_init_module);
module_exit(st_dvb_cleanup_module);
