/*
 * arch/sh/boards/st/stb/elc/setup_stb830.c
 *
 * Copyright (C) 2011 Elecard CTP
 * Author: Anton Sergeev (Anton.Sergeev@elecard.ru)
 *
 * May be copied or modified under the terms of the GNU General Public
 * License.  See linux/COPYING for more information.
 *
 * Elecards stb830 support.
 * Based on pdk7105/setup.c
 */

#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/delay.h>
#include <linux/io.h>
#include <linux/leds.h>
#include <linux/lirc.h>
#include <linux/gpio.h>
#include <linux/phy.h>
#include <linux/stm/platform.h>
#include <linux/stm/stx7105.h>
#include <linux/stm/emi.h>
#include <linux/mtd/mtd.h>
#include <linux/mtd/physmap.h>
#include <linux/mtd/nand.h>
#include <linux/mtd/partitions.h>
#include <linux/spi/spi.h>
#include <linux/spi/flash.h>
#include <asm/irq-ilc.h>

#include <linux/stm/pio.h>
#include <linux/i2c.h>


static struct platform_device elcStb830_leds = {
	.name = "leds-gpio",
	.id = 0,
	.dev.platform_data = &(struct gpio_led_platform_data) {
		.num_leds = 9,
		.leds = (struct gpio_led[]) {
			/* The schematics actually describes these PIOs
			 * the other way round, but all tested boards
			 * had the bi-colour LED fitted like below... */
			{
				.name = "STANDBY",
				.gpio = stm_gpio(11, 2),
				.active_low = 0,
			},
			{
				.name = "MENU_VD1_Y",
//				.default_trigger = "heartbeat",
				.gpio = stm_gpio(11, 3),
				.active_low = 0,
			},
			{
				.name = "MENU_VD1_B",
//				.default_trigger = "heartbeat",
				.gpio = stm_gpio(11, 4),
				.active_low = 0,
			},
			{
				.name = "MENU_VD3_R",
//				.default_trigger = "heartbeat",
				.gpio = stm_gpio(9, 1),
				.active_low = 0,
			},
			{
				.name = "STATUS_VD2_Y",
//				.default_trigger = "heartbeat",
				.gpio = stm_gpio(9, 0),
				.active_low = 0,
			},
			{
				.name = "STATUS_VD2_B",
//				.default_trigger = "heartbeat",
				.gpio = stm_gpio(9, 4),
				.active_low = 0,
			},
			{
				.name = "STATUS_VD4_R",
//				.default_trigger = "heartbeat",
				.gpio = stm_gpio(9, 3),
				.active_low = 0,
			},
			{
				.name = "WI-FI_VD6_Y",
//				.default_trigger = "heartbeat",
				.gpio = stm_gpio(9, 2),
				.active_low = 0,
			},
			{
				.name = "WI-FI_VD6_B",
//				.default_trigger = "heartbeat",
				.gpio = stm_gpio(2, 4),
				.active_low = 0,
			},
		},
	},
};



/* Configuration for NAND Flash */
static struct mtd_partition nand_parts[] = {
	{
		.name = "Boot",
		.size = 0x00100000,
		.offset = 0x00000000,
	}, {
		.name = "Boot-env",
		.size = 0x00100000,
		.offset = MTDPART_OFS_APPEND,
	}, {
		.name = "KernelReserve",
		.size = 0x00f00000,
		.offset = MTDPART_OFS_APPEND,
	}, {
		.name = "Kernel",
		.size = 0x00f00000,
		.offset = MTDPART_OFS_APPEND,
	}, {
		.name = "RootFS",
		.size = 0x08000000,
		.offset = MTDPART_OFS_APPEND,
	}, {
		.name = "Opt",
		.size = 0x04000000,
		.offset = MTDPART_OFS_APPEND,
	}, {
		.name = "User",
		.size = 0x01f00000,
		.offset = MTDPART_OFS_APPEND,
	}
};

static struct mtd_partition nand_parts_uboot[] = {
	{
		.name = "Boot_flex",
		.size = 0x00100000,
		.offset = 0x00000000,
	}
};


static struct stm_nand_timing_data nand_timing_data = {
	.sig_setup		= 50,		/* times in ns */
	.sig_hold		= 50,
	.CE_deassert	= 0,
	.WE_to_RBn		= 100,
//	.wr_on			= 10,
	.wr_on			= 15,
	.wr_off			= 40,
	.rd_on			= 10,
	.rd_off			= 40,
	.chip_delay		= 30,		/* in us */
};

/*struct stm_nand_bank_data nand_device = {
	.csn			= 0,
	.nr_partitions	= ARRAY_SIZE(nand_parts_uboot),
	.partitions		= nand_parts_uboot,
	.options		= NAND_NO_AUTOINCR | NAND_USE_FLASH_BBT,
	.timing_data	= &nand_timing_data,

	.emi_withinbankoffset	= 0,
};*/

static struct platform_device nand_device_2 = {
	.id = 0,
//	.name = "stm-nand-flex",
	.name = "stm-nand-afm",
	.num_resources = 2,
	.resource = (struct resource[2]) {
		STM_PLAT_RESOURCE_MEM_NAMED("flex_mem", 0xFE701000, 0x1000),
		STM_PLAT_RESOURCE_IRQ(evt2irq(0x14a0), -1),
	},
	.dev.platform_data = &(struct stm_plat_nand_flex_data) {
		.nr_banks = 1,
		.banks = &(struct stm_nand_bank_data) {
			.csn		= 0,
			.nr_partitions		= ARRAY_SIZE(nand_parts_uboot),
			.partitions			= nand_parts_uboot,
//			.nr_partitions		= ARRAY_SIZE(nand_parts),
//			.partitions			= nand_parts,
			.options			= NAND_NO_AUTOINCR | NAND_USE_FLASH_BBT,
			.timing_data		= &nand_timing_data,
			.emi_withinbankoffset	= 0,
		},
		.flex_rbn_connected = 0,
	},
};

#define EMI_NAND_DEVICE(_csn, _timing_config, \
			_parts, _nr_parts) \
{ \
	.name			= "stm-nand-emi", \
	.id				= _csn, \
	.num_resources	= 0, \
	.dev.platform_data = &(struct stm_plat_nand_emi_data) { \
		.nr_banks = 1, \
		.banks = &(struct stm_nand_bank_data) { \
			.csn			= _csn, \
			.nr_partitions	= _nr_parts, \
			.partitions		= _parts, \
			.options		= NAND_NO_AUTOINCR | NAND_USE_FLASH_BBT, \
			.timing_data	= 	_timing_config, \
			.emi_withinbankoffset	= 0, \
		}, \
		.emi_rbn_gpio=-1, \
		.wait_active_low=1, \
	}, \
}

static struct platform_device nand_device_emi_b =
	EMI_NAND_DEVICE( 1, &nand_timing_data, nand_parts, ARRAY_SIZE(nand_parts));
//static struct platform_device nand_device_emi_c =
//	EMI_NAND_DEVICE( 2, &nand_timing_data, nand_parts, ARRAY_SIZE(nand_parts));


static struct i2c_board_info __initdata rtc_i2c_board_info[] = {
	{ //rtc Seico s35390a
		I2C_BOARD_INFO("s35390a", 0x30),
	},
};

extern void device_init_pci(void);

static struct platform_device *hdk7105_devices[] __initdata = {
	&elcStb830_leds
};

int __init device_init_stb830(int ver)
{
	struct sysconf_field *sc;
	device_init_pci();

//printk("%s[%d] ****************** lo=%d, hi=%d \n", __FILE__, __LINE__, pdk7105_pci_config.idsel_lo, pdk7105_pci_config.idsel_hi);
//setting up keyscanner pio
	stpio_request_set_pin(5, 0, "key scanner", STPIO_ALT_OUT, 0);
	stpio_request_set_pin(5, 1, "key scanner", STPIO_ALT_OUT, 0);
	stpio_request_set_pin(5, 2, "key scanner", STPIO_ALT_OUT, 0);

	stpio_request_set_pin(5, 4, "key scanner", STPIO_IN, 0);
	stpio_request_set_pin(5, 5, "key scanner", STPIO_IN, 0);
	stpio_request_set_pin(5, 6, "key scanner", STPIO_IN, 0);

//	stpio_request_set_pin(7, 0, "test AV", STPIO_ALT_OUT, 0);
//stpio_request_set_pin(3, 3, "reset_nah", STPIO_BIDIR, 1);
//emi_config_gen_cfg(16, 1);
	stpio_request_set_pin(10, 1, "PCM out1", STPIO_ALT_OUT, 0);
	stpio_request_set_pin(10, 2, "PCM out2", STPIO_ALT_OUT, 0);
	stpio_request_set_pin(10, 0, "PCM out0", STPIO_ALT_OUT, 0);

	stpio_request_set_pin(10, 3, "out pcm", STPIO_ALT_OUT, 0);
	stpio_request_set_pin(10, 4, "out lrclk", STPIO_ALT_OUT, 0);
	stpio_request_set_pin(10, 5, "out bclk", STPIO_ALT_OUT, 0);


	stx7105_configure_sata(0);

	/* Set SPI Boot pads as inputs to avoid contention with SSC1 */
	gpio_request(stm_gpio(15, 0), "SPI Boot CLK");
	gpio_direction_input(stm_gpio(15, 0));
	gpio_request(stm_gpio(15, 1), "SPI Boot DOUT");
	gpio_direction_input(stm_gpio(15, 1));
	gpio_request(stm_gpio(15, 2), "SPI Boot NOTCS");
	gpio_direction_input(stm_gpio(15, 2));
	gpio_request(stm_gpio(15, 3), "SPI Boot DIN");
	gpio_direction_input(stm_gpio(15, 3));

	/*
	 * Fix the reset chain so it correct to start with in case the
	 * watchdog expires or we trigger a reset.
	 */
	sc = sysconf_claim(SYS_CFG, 9, 27, 28, "reset_chain");
	sysconf_write(sc, 0);
	/* Release the sysconf bits so the coprocessor driver can claim them */
	sysconf_release(sc);

	/* I2C_xxxA - HDMI */
	stx7105_configure_ssc_i2c(0, &(struct stx7105_ssc_config) {
			.routing.ssc0.sclk = stx7105_ssc0_sclk_pio2_2,
			.routing.ssc0.mtsr = stx7105_ssc0_mtsr_pio2_3, });
	/* SPI - SerialFLASH */
	/*stx7105_configure_ssc_spi(1, &(struct stx7105_ssc_config) {
			.routing.ssc1.sclk = stx7105_ssc1_sclk_pio2_5,
			.routing.ssc1.mtsr = stx7105_ssc1_mtsr_pio2_6,
			.routing.ssc1.mrst = stx7105_ssc1_mrst_pio2_7});*/

	stx7105_configure_ssc_i2c(1, &(struct stx7105_ssc_config) {
					.routing.ssc2.sclk = stx7105_ssc1_sclk_pio2_5,
					.routing.ssc2.mtsr = stx7105_ssc1_mtsr_pio2_6, });

	/* I2C_xxxC - JN1 (NIM), JN3, UT1 (CI chip), US2 (EEPROM) */
	stx7105_configure_ssc_i2c(2, &(struct stx7105_ssc_config) {
			.routing.ssc2.sclk = stx7105_ssc2_sclk_pio3_4,
			.routing.ssc2.mtsr = stx7105_ssc2_mtsr_pio3_5, });
	/* I2C_xxxD - JN2 (NIM), JN4 */
	stx7105_configure_ssc_i2c(3, &(struct stx7105_ssc_config) {
			.routing.ssc3.sclk = stx7105_ssc3_sclk_pio3_6,
			.routing.ssc3.mtsr = stx7105_ssc3_mtsr_pio3_7, });

	stx7105_configure_usb(0, &(struct stx7105_usb_config) {
			.ovrcur_mode = stx7105_usb_ovrcur_active_low,
			.pwr_enabled = 0,
			.routing.usb0.ovrcur = stx7105_usb0_ovrcur_pio4_4,
			.routing.usb0.pwr = stx7105_usb0_pwr_pio4_5, });
	stx7105_configure_usb(1, &(struct stx7105_usb_config) {
			.ovrcur_mode = stx7105_usb_ovrcur_active_low,
			.pwr_enabled = 0,
			.routing.usb1.ovrcur = stx7105_usb1_ovrcur_pio4_6,
			.routing.usb1.pwr = stx7105_usb1_pwr_pio4_7, });
//SergA: walk around: for seting 0 on usb power
	stpio_request_set_pin(4, 5, "usb power0", STPIO_OUT, 0);
	stpio_request_set_pin(4, 7, "usb power1", STPIO_OUT, 0);


	stx7105_configure_lirc(&(struct stx7105_lirc_config) {
#ifdef CONFIG_LIRC_STM_UHF
			.rx_mode = stx7105_lirc_rx_mode_uhf,
#else
			.rx_mode = stx7105_lirc_rx_mode_ir,
#endif
			.tx_enabled = 0,
			.tx_od_enabled = 0, });

	stx7105_configure_audio(&(struct stx7105_audio_config) {
			.spdif_player_output_enabled = 1, });

//	wait_active_low = 1; // no ver ..ver1
//	wait_active_low = 0; //>=ver2
	if( ver >= 2 )
		((struct stm_plat_nand_emi_data *)(nand_device_emi_b.dev.platform_data))->wait_active_low = 0;
	platform_device_register(&nand_device_emi_b);
//	platform_device_register(&nand_device_emi_c);
//	stx7105_configure_nand_flex(1, &nand_device, 1);
//SergA: TODO: fix registering second nand
	platform_device_register(&nand_device_2);


	i2c_register_board_info(2, rtc_i2c_board_info, ARRAY_SIZE(rtc_i2c_board_info));

	return platform_add_devices(hdk7105_devices,
			ARRAY_SIZE(hdk7105_devices));
}

