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
#include "linux/module.h"

//local
#include "edc-1051.h"
#include "sonydvbt2.h"
//#include "stv0367_tda18250.h"
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
typedef int (register_fe_func)(int slot_num, struct dvb_adapter *dvb_adapter);
typedef void (unregister_fe_func)(int slot_num);

struct frontend_ops_s {
	char				*name;
	register_fe_func	*register_fe;
	unregister_fe_func  *unregister_fe;
};

struct st_dvb_s {
	char					*name;
	struct dvb_adapter		dvb_adapter;
	struct frontend_ops_s	*fops;
};

/*** LOCAL CONSTANTS ********************************************************/
#define dprintk(format, args...) if (st_dvb_debug) { printk("%s[%d]: " format, __FILE__, __LINE__, ##args); }

#define DVB_NUMS 2

/*** LOCAL VARIABLES *********************************************************/
struct st_dvb_s st_dvb[DVB_NUMS] = {
	{.name = "ST DVB slot 0", .fops = NULL},
	{.name = "ST DVB slot 1", .fops = NULL},
};

struct frontend_ops_s frontend_ops[] = {
	{"EDC_1051"			,edc_1051_register_frontend				,edc_1051_unregister_frontend},
	{"SONY_DVBT2"		,sonydvbt2_register_frontend			,sonydvbt2_unregister_frontend},
/*	{"STV0367_TDA18250"	,stv0367_tda18250_register_frontend		,stv0367_tda18250_unregister_frontend},*/
};


/*** METHODS ****************************************************************/

static int __init st_dvb_init_module(void)
{
	int err = 0;
	static short adapter_nums[] = {
					[0] = 0,
					[1 ... (DVB_MAX_ADAPTERS - 1)] = DVB_UNSET
				};
	int i, j;

	if(ci_enable[0] || ci_enable[1])
		st_dvb_init_stpccrd();
	for(i = 0; i < DVB_NUMS; i++) {
		struct dvb_adapter *dvb_adapter = &(st_dvb[i].dvb_adapter);

		adapter_nums[0] = i;
		if ((err = dvb_register_adapter(dvb_adapter, st_dvb[i].name, THIS_MODULE, NULL, adapter_nums)) < 0) {
			dprintk("dvb_register_adapter failed (errno = %d)\n", err);
			continue;
		}
		//init dvb-ca
		if(ci_enable[i])
			st_dvb_init_ca(i, dvb_adapter);

		//init frontend
		for(j = 0; j < ARRAY_SIZE(frontend_ops); j++) {
			int descrNameLen = 0;
			struct frontend_ops_s *fe_ops_p = frontend_ops + j;
			
			if( fe_ops_p->name == NULL )
				continue;
			descrNameLen = strlen(fe_ops_p->name);
			if(!strncmp(frontend_param[i], fe_ops_p->name, descrNameLen)) {
				if(fe_ops_p->register_fe) {
					dprintk("%s init\n", fe_ops_p->name);
					fe_ops_p->register_fe(i, dvb_adapter);
					st_dvb[i].fops = fe_ops_p;
					break;
				} else {
					dprintk("ERROR: %s function register_fe=NULL.\n", fe_ops_p->name);
				}
			}
		}
		
	}
	return 0;
}

static void __exit st_dvb_cleanup_module(void)
{
	int i;
	for (i = 0; i < DVB_NUMS; i++) {
		if(st_dvb[i].fops && st_dvb[i].fops->unregister_fe)
			st_dvb[i].fops->unregister_fe(i);
//		else
//			dprintk("ERROR: %s function unregister_fe=NULL.\n", st_dvb[i].fops->name);

		st_dvb_release_ca(i);
		dvb_unregister_adapter(&(st_dvb[i].dvb_adapter));
		st_dvb[i].fops = NULL;
	}
	st_dvb_release_stpccrd();
}


/*** MODULE LOADING ******************************************************/

/* Tell the module system these are our entry points. */
module_init(st_dvb_init_module);
module_exit(st_dvb_cleanup_module);
