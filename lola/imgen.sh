#!/bin/bash
RET=0
while [ $RET -eq 0 ] ;do
    sudo -u www-data streamer -f jpeg -o /var/www/html/compaq.jpeg 2>&1 >/dev/null
    RET=$?
done

