#!/bin/sh

[% IF CONFIG_ELECD_ENABLE -%]
TEST_FIRMWARE=
[% ELSE -%]
TEST_FIRMWARE=1
[% END -%]
UPDATER_CHECK_ALWAYS=`/opt/elecard/bin/hwconfigManager a 0 UPDATER_CHECK_ALWAYS 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`
UPDATER_FOUND_UPDATE=`/opt/elecard/bin/hwconfigManager a 0 UPDATER_FOUND_UPDATE 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`

NETWORK_NEED=
if [ "$TEST_FIRMWARE" -o "${UPDATER_CHECK_ALWAYS:-0}" != "0" -o "${UPDATER_FOUND_UPDATE:-0}" != "0" ]; then
	NETWORK_NEED=1
fi
export NETWORK_NEED
