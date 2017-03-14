#!/bin/bash
if [ $EUID != 0 ]; then
    su -c "$0" "$@"
    exit $?
fi
apt-get install -y unison screen gawk command-not-found libpam-systemd dbus nmap pv apt-file mutt sudo nfs-common autofs
update-command-not-found
apt-file update
