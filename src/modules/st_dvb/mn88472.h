/*
 * MN88472 demodulator driver
 *
 * Copyright (C) 2013 Andrey Kuleshov <andrey.kuleshov@elecard.ru>
 */

#ifndef MN88472_H
#define MN88472_H

#include <linux/dvb/frontend.h>

struct mn88472_config {
	/* Demodulator I2C address SADR pin state
	 * The lower bit of the slave adresses
	 * Default: none, must set
	 * Values: 0,1
	 */
	u8 i2c_sadr;
};

struct dvb_frontend *mn88472_attach(const struct mn88472_config *config, struct i2c_adapter *i2c);

#endif /* MN88472_H */
