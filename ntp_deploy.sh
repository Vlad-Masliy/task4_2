#!/bin/bash

sistem_path=`realpath $0`
dirpath=`dirname $sistem_path`
buffer=0

silent () {
    if [ $1 = "on" ]
    then
        if [ $buffer = 0 ]
        then
            exec 3>&1
            exec > /dev/null          
            buffer=3
        fi
    elif [ $1 = "off" ]
    then
        if [ ! $buffer = 0 ]
        then
	    exec 1>&3 3>& -            
            buffer=0
        fi
    fi             
}

path=`which ntpd`
if [ -z $path ] 
then
    echo "installing ntp...."
    silent on
    apt-get install -y ntp 
    i=$?
    silent off
    if [ ! $i = 0 ] 
    then
         echo "error!"
    else
         cp /etc/ntp.conf /etc/ntp.conf.default
	 echo "installed!"
    fi 
fi
echo "configurating default pools..."
sed -i "/^pool .*ntp\./d" /etc/ntp.conf
echo "pool ua.pool.ntp.org" >> /etc/ntp.conf
if [ ! -f /etc/ntp.conf.deploy ] 
then 
    cp /etc/ntp.conf /etc/ntp.conf.deploy
fi
echo "restarting ntp service..."
service ntp restart
verify_path="$dirpath/ntp_verify.sh"
if [ -f $verify_path ] 
then
    cron_exists=`crontab -l | grep $verify_path`
    if [ -z "$cron_exists" ] 
    then
        cron_line="*/5 * * * * $verify_path"
        (crontab  -u $USER -l; echo "$cron_line") | crontab -u $USER -
        echo "cron task for $USER added..."
    fi
else
    echo "File ntp_verify.sh not found as $verify_path"
fi
