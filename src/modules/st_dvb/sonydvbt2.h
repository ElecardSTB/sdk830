#if (!defined __SONY_DVBT2__)
#define __SONY_DVBT2__

/*
 * Copyright (C) 2012 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *
 * DVB-T2/T/C nim based on Sony MxL201RF and CX2820R
 */

struct i2c_adapter;
struct dvb_frontend;

struct dvb_frontend* sonydvbt2_init_frontend(struct i2c_adapter *i2c_adapter);

#endif // __SONY_DVBT2__
