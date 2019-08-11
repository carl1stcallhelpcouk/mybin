#!/bin/bash
#
filelist=(/var/log/mail.log /var/log/mail.err /var/log/dovecot.log /var/log/mysql.err /var/log/syslog /var/log/Xorg.1.log /var/log/apache2/error.log /var/log/apache2/other_vhosts_access.log /var/log/mystatusd.log /var/log/mystatusd.err /var/log/mystatysd.last /var/log/apache2/access.log)

for file in "${filelist[@]}" 
do 
    if [ -r "${file}" ] ; then
        printf "\nScanning %s ...\n" "${file}"
        grep --color=always -i -B 5 "error\|warn\|fail\|missing\|grep (EE)" "${file}" | grep -v "fail2ban"
    else
        printf "\nSkipping %s ...\n" "${file}"
    fi
done