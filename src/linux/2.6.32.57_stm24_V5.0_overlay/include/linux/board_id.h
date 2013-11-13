
#ifndef __BOARD_TYPE_H__
#define __BOARD_TYPE_H__

/******************************************************************
* EXPORTED TYPEDEFS                                               *
*******************************************************************/
typedef enum g_board_type_e {
	eSTB_unknown = -1,
	eSTB830 = 0,
	eSTB840_PromSvyaz,
	eSTB840_PromWad,
	eSTB840_ch7162,
	eSTB830_reference,
	eSTB_pioneer,
	eSTB850,

} g_board_type_t;

#ifdef __KERNEL__
struct board_special_config_s {
	int	hdmi_hpd_inverted; //is hdmi hpd (hot plug detection) inverted, default 0
	int	nand_wait_active_low; //is nand emi wait active low, default 1
};

/******************************************************************
* EXPORTED FUNCTIONS PROTOTYPES               <Module>_<Word>+    *
*******************************************************************/
extern struct board_special_config_s *get_board_special_config(void);
extern g_board_type_t elc_get_board_type(void);
extern int elc_get_board_version(void);

#endif //#ifdef __KERNEL__

#endif //#ifndef __BOARD_TYPE_H__
