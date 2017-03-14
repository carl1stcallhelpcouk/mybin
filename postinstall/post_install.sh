#!/bin/bash
if [ ! -d /tmp/install_new ] ; then
    printf "%s\n\n" "Creating tempory dircetory /tmp/install_new."
    mkdir /tmp/install_new
fi

if [ ! -r /home/carl/.ssh/id_rsa ] ; then
    printf "%s\n\n" "Generating ssh keys and sending them to time."
    ssh-keygen -b 4069 -t rsa
    ssh-copy-id carl@192.168.0.103
fi

printf "%s\n\n" "scp ing required files."
scp carl@192.168.0.103:/exports/data/etc/{hosts,apt/sources.list,sudoers.d/carl} /tmp/install_new
scp carl@192.168.0.103:/exports/data/home/carl/{.bashrc,.bash_aliases,bin/lola/{mysysinfo.sh,binsync.sh},bin/post_install/ius.sh} /tmp/install_new

printf "%s\n\n" "Starting 'sudo' Section"
sudo bash <<EOS

printf "%s\n\n" "Updateing /etc/hosts"
cat /tmp/install_new/hosts | tee -a /etc/hosts 

printf "%s\n\n" "Updatesing /etc/apt/sources.list"
cat /tmp/install_new/sources.list | tee /etc/apt/sources.list

printf "%s\n\n" "Updateing /etc/sudoers.d/carl"
cat /tmp/install_new/carl | tee /etc/sudoers.d/carl

printf "%s\n\n" "Creating /home/carl/bin"
mkdir /home/carl/bin

printf "%s\n\n" "Updateing /home/carl/.bashrc, .bash_aliases"
cat /tmp/install_new/.bashrc | tee -a /home/carl/.bashrc
cat /tmp/install_new/.bash_aliases | tee /home/carl/.bash_aliases

printf "%s\n\n" "Installing the usual suspects"
/tmp/install_new/ius.sh | tee /home/carl/ius.log

printf "%s\n\n" "Changing ownership of ~ to carl"
chown -R carl:carl /home/carl/.

#printf "%s\n\n" "Adding carl to sudoers group"
#adduser carl sudo

printf "%s\n\n" "Setting up shared folders"
mkdir --parents --verbose /shares/data
echo '/-    /etc/auto.mount' | tee -a /etc/auto.master
echo '/shares/data -fstype=nfs,rw  time.1stcallhelp.co.uk:/exports/data' | tee -a /etc/auto.mount
service autofs restart

EOS
printf "%s\n\n" "End of 'sudo' Section"

printf "%s\n\n" "cp ing /home/carl/bin/lola/mysysinfo.sh and binsync.sh"
mkdir /home/carl/bin/lola
cp -v /tmp/install_new/mysysinfo.sh /home/carl/bin/lola
cp -v /tmp/install_new/binsync.sh /home/carl/bin/lola

printf "%s\n\n" "All Done."