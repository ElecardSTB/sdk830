#!/bin/sh

[% IF CONFIG_TESTSERVER_ENABLE -%]
TEST_FIRMWARE=1
[% ELSE -%]
TEST_FIRMWARE=
[% END -%]
UPNET=`/opt/elecard/bin/hwconfigManager h 0 UPNET 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`
let UPNET=0x${UPNET:-0}
UPFOUND=`/opt/elecard/bin/hwconfigManager h 0 UPFOUND 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`
let UPFOUND=0x${UPFOUND:-0}

export NETWORK_NEED=
if [ "$TEST_FIRMWARE" -o $UPNET -ne 0 -o $UPFOUND -ne 0 ]; then
	NETWORK_NEED=1
fi
