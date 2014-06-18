#!/bin/sh

grep nameserver /var/etc/resolv.conf &>/dev/null && cat /var/etc/resolv.conf > /tmp/resolv.conf
exit 0
