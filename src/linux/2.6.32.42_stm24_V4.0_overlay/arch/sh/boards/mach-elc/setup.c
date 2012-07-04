/*
 * arch/sh/boards/mach-elc/setup.c
 *
 * Copyright (C) 2012 Elecard CTP
 * Author: Anton Sergeev (Anton.Sergeev@elecard.ru)
 *
 * May be copied or modified under the terms of the GNU General Public
 * License.  See linux/COPYING for more information.
 *
 * Elecards boards support.
 * Based on arch/sh/boards/mach-hdk7105/setup.c
 */

#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/delay.h>
#include <linux/io.h>
#include <linux/gpio.h>
#include <linux/stm/platform.h>
#include <linux/stm/stx7105.h>
#include <linux/stm/pci-glue.h>
#include <linux/stm/emi.h>
#include <asm/irq-ilc.h>

#include <linux/stm/pio.h>
#include <linux/i2c.h>
#include <linux/board_id.h>

#undef ARRAY_SIZE
#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))


typedef int (board_init_func)(int ver);
extern int device_init_stb830(int ver);
extern int device_init_stb840_promSvyaz(int ver);
extern int device_init_stb840_promWad(int ver);
extern int device_init_stb840_ch7162(int ver);
extern int device_init_stb830_reference(int ver);

struct board_descr_s {
	g_board_type_t		type;
	char				*name;
	board_init_func		*init_func;
};

struct board_config_s {
	g_board_type_t					type;
	int								version; //if setted to -1, this configuration apply for all board versions
	struct board_special_config_s	special_configs;
};

struct board_descr_s board_descr[] __initdata = {
  {eSTB830,				"stb830_st",		device_init_stb830},
  {eSTB840_PromSvyaz,	"stb840_promSvyaz",	device_init_stb840_promSvyaz},
  {eSTB840_PromWad,		"stb840_promWad",	device_init_stb840_promWad},
  {eSTB840_ch7162,		"stb840_ch7162",	device_init_stb840_ch7162},
  {eSTB830_reference,	"stb830_reference",	device_init_stb830_reference},
};

struct board_config_s board_config[]  = {
  {eSTB830,				0,	{0, 1} },
  {eSTB830,				2,	{0, 0} },
  {eSTB840_PromSvyaz,	-1,	{0, 1} },
  {eSTB840_PromWad,		-1,	{1, 1} },
  {eSTB840_ch7162,		-1,	{0, 1} },
  {eSTB830_reference,	-1,	{0, 1} },
};

static g_board_type_t g_board_type = eSTB830;
static int g_board_version = 0;
static int g_board_type_Id = 0;
static int g_board_config_Id = -1;


static void __init hdk7105_setup(char **cmdline_p)
{
	printk(KERN_INFO "Elecard. STi7105\n");

	stx7105_early_device_init();

	stx7105_configure_asc(2, &(struct stx7105_asc_config) {
			.routing.asc2 = stx7105_asc2_pio4,
			.hw_flow_control = 1,
			.is_console = 1, });
/*	stx7105_configure_asc(3, &(struct stx7105_asc_config) {
			.hw_flow_control = 1,
			.is_console = 0, });*/
}

struct board_special_config_s *get_board_special_config(void)
{
	int i;
	if(g_board_config_Id >= 0)
		return &(board_config[g_board_config_Id].special_configs);

	for(i = 0; i < ARRAY_SIZE(board_config); i++) {
		if(board_config[i].type == g_board_type) {
			if( (board_config[i].version == -1) ||
				(board_config[i].version == g_board_version) ) {
				g_board_config_Id = i;
				return &(board_config[i].special_configs);
			}
		}
	}

	return &(board_config[0].special_configs);//return default configs
}
EXPORT_SYMBOL(get_board_special_config);

static int __init board_cmdline_opt(char *str)
{
	int i;
	if (!str || !*str)
		return -EINVAL;

	for(i = 0; i < ARRAY_SIZE(board_descr); i++) {
		int descrNameLen = 0;
		if( board_descr[i].name == NULL )
			continue;
		descrNameLen = strlen(board_descr[i].name);
		if(!strncmp(str, board_descr[i].name, descrNameLen)) {
			if( str[descrNameLen] == '.' ) {
				if( sscanf(str+descrNameLen, ".%d", &g_board_version) != 1 )
					g_board_version = 0;
			} else if( str[descrNameLen] != 0 )
				continue;
			g_board_type = board_descr[i].type;
			g_board_type_Id = i;
			break;
		}
	}
	if(g_board_type == eSTB840_PromWad) {
		//This for PromWad's board
		stx7105_configure_asc(0, &(struct stx7105_asc_config) {
				.hw_flow_control = 1,
				.is_console = 0, });
	}
	return 0;
}

//early_param("board_name=", board_cmdline_opt);
__setup("board_name=", board_cmdline_opt);



static int __init hdk7105_device_init(void)
{
	struct sysconf_field *sc;
	u32 boot_mode;
	int ret = 0;

	/* Configure FLASH devices */
	sc = sysconf_claim(SYS_STA, 1, 15, 16, "boot_mode");
	boot_mode = sysconf_read(sc);
	switch (boot_mode) {
	case 0x0:
		/* Boot-from-NOR: */
		/* NOR mapped to EMIA + EMIB (FMI_A26 = EMI_CSA#) */
		pr_info("Configuring FLASH for boot-from-NOR\n");
		break;
	case 0x1:
		/* Boot-from-NAND */
		pr_info("Configuring FLASH for boot-from-NAND\n");
		break;
	case 0x2:
		/* Boot-from-SPI */
		/* NOR mapped to EMIB, with physical offset of 0x06000000! */
		pr_info("Configuring FLASH for boot-from-SPI\n");
		break;
	}

	if( board_descr[g_board_type_Id].init_func ) {
		printk("*Board: %s, ver=%d\n", board_descr[g_board_type_Id].name, g_board_version);
		board_descr[g_board_type_Id].init_func(g_board_version);
	} else {
		printk("Init fucnction not setted!!!\n");
		BUG();
	}

	return ret;
}
arch_initcall(hdk7105_device_init);

static void __iomem *hdk7105_ioport_map(unsigned long port, unsigned int size)
{
	/*
	 * If we have PCI then this should never be called because we
	 * are using the generic iomap implementation. If we don't
	 * have PCI then there are no IO mapped devices, so it still
	 * shouldn't be called.
	 */
	BUG();
	return (void __iomem *)CCN_PVR;
}

struct sh_machine_vector mv_hdk7105 __initmv = {
	.mv_name		= "hdk7105",
	.mv_setup		= hdk7105_setup,
	.mv_nr_irqs		= NR_IRQS,
	.mv_ioport_map		= hdk7105_ioport_map,
	STM_PCI_IO_MACHINE_VEC
};
