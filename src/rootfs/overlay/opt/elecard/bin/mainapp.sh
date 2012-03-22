#!/bin/sh

while :; do
    /opt/elecard/bin/StbMainApp >> /var/log/mainapp.log 2>&1
    sleep 1
done
