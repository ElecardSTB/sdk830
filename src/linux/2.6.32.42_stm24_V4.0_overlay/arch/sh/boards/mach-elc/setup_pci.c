/*
 * arch/sh/boards/mach-elc/setup_pci.c
 *
 * Copyright (C) 2008 STMicroelectronics Limited
 * Author: Stuart Menefy (stuart.menefy@st.com)
 *
 * May be copied or modified under the terms of the GNU General Public
 * License.  See linux/COPYING for more information.
 *
 * STMicroelectronics HDK7105-SDK support.
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



#define HDK7105_PIO_PCI_SERR  stm_gpio(15, 4)
#define HDK7105_PIO_PHY_RESET stm_gpio(15, 5)
#define HDK7105_PIO_PCI_RESET stm_gpio(15, 7)



/* PCI configuration */
static struct stm_plat_pci_config pdk7105_pci_config = {
	.pci_irq = {
		[0] = PCI_PIN_DEFAULT,
		[1] = PCI_PIN_DEFAULT,
		[2] = PCI_PIN_UNUSED,
		[3] = PCI_PIN_UNUSED
	},
	.serr_irq = PCI_PIN_UNUSED, /* Modified in hdk7105_device_init() */
	.idsel_lo = 30,
	.idsel_hi = 30,
	.req_gnt = {
		[0] = PCI_PIN_DEFAULT,
		[1] = PCI_PIN_DEFAULT,
		[2] = PCI_PIN_UNUSED,
		[3] = PCI_PIN_UNUSED
	},
	.pci_clk = 33333333,
	.pci_reset_gpio = HDK7105_PIO_PCI_RESET,
};

int pcibios_map_platform_irq(struct pci_dev *dev, u8 slot, u8 pin)
{
        /* We can use the standard function on this board */
//	return stx7105_pcibios_map_platform_irq(&pdk7105_pci_config, pin);
	int i;
	i = stx7105_pcibios_map_platform_irq(&pdk7105_pci_config, pin+(23-pdk7105_pci_config.idsel_lo)-slot);
	printk("%s:%s()[%d]:***  (int)dev=0x%08x, slot=%d, pin=%d, int_no=%d\n", __FILE__, __func__, __LINE__, (int)dev, slot, pin, i);
	return i;
}

static int eth_u804 = 1;
static int eth_u902 = 1;

static int __init elc_stb830_cmdline_opt(char *str)
{
	char *opt;
//printk("%s[%d] **********************************************=%s\n", __FILE__, __LINE__, str);
	if (!str || !*str)
		return -EINVAL;
	while ((opt = strsep(&str, ",")) != NULL) {
		if(!strncmp(opt, "no_u804", 7))
			eth_u804 = 0;
		else if(!strncmp(opt, "no_u902", 7))
			eth_u902 = 0;
	}
	return 0;
}

__setup("elc_stb830=", elc_stb830_cmdline_opt);

void __init device_init_pci(void)
{
//SergA
	if( (eth_u804 == 0) && (eth_u902 == 0) )
	{
		pdk7105_pci_config.idsel_lo = 30;//this mean that there is nothing on AD30 idsel, so no any pci devices
		pdk7105_pci_config.idsel_hi = 30;
	}
	else
	{
		if(eth_u804 != 0)
			pdk7105_pci_config.idsel_hi = 23;
		else
			pdk7105_pci_config.idsel_hi = 22;

		if(eth_u902 != 0)
			pdk7105_pci_config.idsel_lo = 22;
		else
			pdk7105_pci_config.idsel_lo = 23;
	}

	/* Setup the PCI_SERR# PIO */
	if (gpio_request(HDK7105_PIO_PCI_SERR, "PCI_SERR#") == 0) {
		gpio_direction_input(HDK7105_PIO_PCI_SERR);
		pdk7105_pci_config.serr_irq =
				gpio_to_irq(HDK7105_PIO_PCI_SERR);
		set_irq_type(pdk7105_pci_config.serr_irq, IRQ_TYPE_LEVEL_LOW);
	} else {
		printk(KERN_WARNING "hdk7105: Failed to claim PCI SERR PIO!\n");
	}
	stx7105_configure_pci(&pdk7105_pci_config);

}
