#!/bin/bash

echo “Started Setup at $(date)“ > /var/log/mysetup.log

sed -i -- 's/jessie/stretch/g' /etc/apt/sources.list
apt-get update
apt-get -yqq dist-upgrade | tee -a /var/log/mysetup.log
apt-get -yqq install netcat sed gawk mailutils gpgsm mutt nano sudo autofs apt-file command-not-found openssl | tee -a /var/log/mysetup.log
adduser carl sudo | tee -a /var/log/mysetup.log
apt-file update | tee -a /var/log/mysetup.log
update-command-not-found | tee -a /var/log/mysetup.log
sudo apt-get -yqq autoremove | tee -a /var/log/mysetup.log
sudo apt-get -yqq install openssh-server pacemaker pcs psmisc policycoreutils | tee -a /var/log/mysetup.log
ssh-keygen -t dsa -b 4096 
sudo -ucarl "ssh-keygen -t dsa -b 4096"
echo "192.168.0.109 nas" | tee -a /etc/hosts | tee -a /var/log/mysetup.log
scp -r nas:/shares/data/nas.dev/etc /etc
sudo update-rc.d pcsd enable

echo “Compleated Setup at $(date)” | tee -a /var/log/mysetup.log
