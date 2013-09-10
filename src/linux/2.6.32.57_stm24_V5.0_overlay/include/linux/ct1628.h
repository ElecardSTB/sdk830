#ifndef __CT1628_H__
#define __CT1628_H__

#include <linux/input.h>

struct ct1628_character {
	char character;
	u16 value;
};

struct ct1628_key {
	u32 mask; /* as read from "keys" attribute */
	int code; /* input event code (KEY_*) */
	char *desc;
};

struct ct1628_platform_data {
	/* Wiring information */
	uint32_t gpio_dio, gpio_sclk, gpio_stb;
	uint32_t GPIOlock;  //Allow driver lock GPIO

	/* Keyboard */
	uint32_t keys_num;
	struct ct1628_key *keys;
	uint32_t keys_poll_period; /* jiffies */

	/* Display control */
	uint32_t brightness; /* initial value, 0 (disabled) - 8 (max) */
	uint32_t characters_num;
	struct ct1628_character *characters;
	const char *text; /* initial value, if encoding table available */

	struct mutex *spi_lock_mutex;
};

#endif //#ifndef __CT1628_H__

