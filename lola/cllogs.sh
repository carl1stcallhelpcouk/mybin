#!/bin/bash
#
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi
filelist=(/var/log/mail.log /var/log/mail.err /var/log/dovecot.log /var/log/mysql.err /var/log/syslog /var/log/Xorg.1.log /var/log/apache2/error.log /var/log/apache2/other_vhosts_access.log /var/log/mystatusd.log /var/log/mystatusd.err /var/log/mystatysd.last /var/log/apache2/access.log)

for file in "${filelist[@]}"
do
    if [ -r "${file}" ] ; then
    	printf "\nTruncating %s ...\n" "${file}"
	sudo bash -c "echo "" > "${file}""
   else
	printf "\nSkipping %s ...\n" "${file}"
   fi
done
if [[ "$1" == "--reboot" ]] ; then sudo reboot ; fi
