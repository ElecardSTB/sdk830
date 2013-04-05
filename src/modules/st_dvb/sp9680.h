#if (!defined SP9680_H_)
#define SP9680_H_

/*
 * Copyright (C) 2012 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *
 * SP9680 DVB-T2/T/C NIM based on Panasonic MN88472 and MxL603
 */

struct dvb_frontend;
struct i2c_adapter;

struct dvb_frontend* sp9680_init_frontend(struct i2c_adapter *adapter);

#endif // SP9680_H_
