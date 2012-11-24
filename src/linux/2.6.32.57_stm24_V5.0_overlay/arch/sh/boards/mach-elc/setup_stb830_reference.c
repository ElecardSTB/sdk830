/*
 * arch/sh/boards/st/stb/elc/setup_stb840_promSvyaz.c
 *
 * Copyright (C) 2011 Elecard-STB
 * Author: Anton Sergeev (Anton.Sergeev@elecard.ru)
 *
 * May be copied or modified under the terms of the GNU General Public
 * License.  See linux/COPYING for more information.
 *
 * Elecards stb840 PromSvyaz support.
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
#include <linux/tm1668.h>
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


#define HDK7105_PIO_PHY_RESET stm_gpio(15, 5)
#define HDK7105_GPIO_FLASH_WP stm_gpio(6, 4)



static struct platform_device pdk7105_leds = {
	.name = "leds-gpio",
	.id = 0,
	.dev.platform_data = &(struct gpio_led_platform_data) {
		.num_leds = 2,
		.leds = (struct gpio_led[]) {
			/* The schematics actually describes these PIOs
			 * the other way round, but all tested boards
			 * had the bi-colour LED fitted like below... */
			{
				.name = "GREEN", /* This is also frontpanel LED */
				.gpio = stm_gpio(7, 0),
				.active_low = 1,
			},
			{
				.name = "RED",
				.default_trigger = "heartbeat",
				.gpio = stm_gpio(7, 1),
				.active_low = 1,
			},
		},
	},
};

static int hdk7105_phy_reset(void *bus)
{
	gpio_set_value(HDK7105_PIO_PHY_RESET, 0);
	udelay(100);
	gpio_set_value(HDK7105_PIO_PHY_RESET, 1);

	return 1;
}

static struct stmmac_mdio_bus_data stmmac_mdio_bus = {
	.bus_id = 0,
	.phy_reset = hdk7105_phy_reset,
	.phy_mask = 0,
};



/* Configuration for NAND Flash */
static struct mtd_partition nand_parts[] = {
	{
		.name = "Boot_flex",
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
//		.size = MTDPART_SIZ_FULL,
		.offset = MTDPART_OFS_APPEND,
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

static struct stm_nand_config stm_nand_device = {
	.driver = stm_nand_flex,
//	.driver = stm_nand_afm,
	.nr_banks = 1,
	.banks = &(struct stm_nand_bank_data) {
		.csn		= 0,
		.nr_partitions		= ARRAY_SIZE(nand_parts),
		.partitions			= nand_parts,
		.options			= NAND_NO_AUTOINCR | NAND_USE_FLASH_BBT,
		.timing_data		= &nand_timing_data,
		.emi_withinbankoffset	= 0,
	},
	.rbn.flex_connected = -1,
};


static struct platform_device *hdk7105_devices[] __initdata = {
	&pdk7105_leds
};

int __init device_init_stb830_reference(int ver)
{
	struct sysconf_field *sc;

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
			.pwr_enabled = 1,
			.routing.usb0.ovrcur = stx7105_usb0_ovrcur_pio4_4,
			.routing.usb0.pwr = stx7105_usb0_pwr_pio4_5, });
	stx7105_configure_usb(1, &(struct stx7105_usb_config) {
			.ovrcur_mode = stx7105_usb_ovrcur_active_low,
			.pwr_enabled = 1,
			.routing.usb1.ovrcur = stx7105_usb1_ovrcur_pio4_6,
			.routing.usb1.pwr = stx7105_usb1_pwr_pio4_7, });


	gpio_request(HDK7105_PIO_PHY_RESET, "eth_phy_reset");
	gpio_direction_output(HDK7105_PIO_PHY_RESET, 1);

	stx7105_configure_ethernet(0, &(struct stx7105_ethernet_config) {
			.mode = stx7105_ethernet_mode_mii,
			.ext_clk = 0,
			.phy_bus = 0,
			.phy_addr = 0,
			.mdio_bus_data = &stmmac_mdio_bus,
		});

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

	/*
	 * FLASH_WP is shared between between NOR and NAND FLASH.  However,
	 * since NAND MTD has no concept of write-protect, we permanently
	 * disable WP.
	 */
	gpio_request(HDK7105_GPIO_FLASH_WP, "FLASH_WP");
	gpio_direction_output(HDK7105_GPIO_FLASH_WP, 1);

	stx7105_configure_nand(&stm_nand_device);

	return platform_add_devices(hdk7105_devices,
			ARRAY_SIZE(hdk7105_devices));
}

