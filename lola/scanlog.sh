#!/bin/bash
#
old_pwd=$(pwd)
#cd /var/log

filelist=(/var/log/mail.log /var/log/dovecot.log /var/log/mysql.err /var/log/syslog /var/log/Xorg.1.log)

for file in "${filelist[@]}" 
do 
    if [ -r "${file}" ] ; then
    	printf "\nScanning %s ...\n" "${file}"
    	grep --color=always -i -B 5 "error\|warn\|fail\|missing\|grep (EE)" "${file}" | grep -v "fail2ban"
   else
	printf "\nSkipping %s ...\n" "${file}"
   fi
done

#cd "${old_pwd}"
