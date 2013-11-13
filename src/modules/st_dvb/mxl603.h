/*
 * Copyright (C) 2012 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *
 * MaxLinear MxL603 tuner driver
 */

#if !(defined MXL603_H_)
#define MXL603_H_

//#define MXL603_I2C_ADDR 0x96
#define MXL603_I2C_ADDR 0xC0//(0x60<<1)

struct dvb_frontend;

struct mxl603_config {
	uint8_t		i2c_addr;
	uint8_t		externI2C; //use external set/get i2c functions
	uint16_t	if_khz;
	void		*demod_priv;
	int (*register_get)(void *priv, u8 addr, u8 reg, u8 *value);
	int (*register_set)(void *priv, u8 addr, u8 reg, u8  value);
};

extern struct dvb_frontend* mxl603_attach(struct dvb_frontend *fe,
										  struct i2c_adapter *i2c,
										  struct mxl603_config *config);

#endif //#if !(define MXL603_H_)
