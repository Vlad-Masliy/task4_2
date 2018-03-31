#!/bin/bash

ntpd_pidof=`pidof ntpd`
if [ -z "$ntpd_pidof" ] 
    then
    echo "NOTICE: ntp is not running"
    set -e
    service ntp start
    set +e
fi
if [ ! -f /etc/ntp.conf.deploy ] 
    then
    cp /etc/ntp.conf /etc/ntp.conf.deploy
elif [ ! -f /etc/ntp.conf ]
    then
    cp /etc/ntp.conf.deploy /etc/ntp.conf
fi
diff=`diff -u /etc/ntp.conf /etc/ntp.conf.deploy`
if [ ! -z "$diff" ] 
    then
    echo "NOTICE: /etc/ntp.conf was changes. Calculated diff:"
    diff -u /etc/ntp.conf /etc/ntp.conf.deploy
    cp /etc/ntp.conf.deploy /etc/ntp.conf
    service ntp restart
fi        
