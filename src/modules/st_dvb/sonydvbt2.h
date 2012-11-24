#if (!defined __SONY_DVBT2__)
#define __SONY_DVBT2__

/*
 * Copyright (C) 2012 by Elecard-STB.
 * Written by Andrey Kuleshov <Andrey.Kuleshov@elecard.ru>
 *
 * DVB-T2/T/C nim based on Sony MxL201RF and CX2820R
 */

#include <dvbdev.h>

int  sonydvbt2_register_frontend(int slot_num, struct dvb_adapter *dvb_adapter);
void sonydvbt2_unregister_frontend(int slot_num);

#endif // __SONY_DVBT2__
