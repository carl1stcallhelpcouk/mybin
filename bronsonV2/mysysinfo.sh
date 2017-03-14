#!/bin/bash 

printf "%s\n\n%s\n\n" "Hello $(getent passwd ${USER} | cut -d ':' -f 5 | cut -d ',' -f 1)." "$(uname -a)" | tee "${HOME}/login.log"
printf "%s\n%s\n" "Last Login" "$(lastlog -u "${USER}")" | tee -a "${HOME}/login.log"
printf "\nToday's date is %s. this is week %s.\n" "$(date)" "$(date +"%V")" | tee -a "${HOME}/login.log"
printf "These users are currently connected:\n%s\n" "$(w -u)"  | tee -a "${HOME}/login.log"
printf "\nThis is %s running on a %s processor.\n" "$(uname -s)" "$(uname -m)" | tee -a "${HOME}/login.log"
printf "\nThe the uptime information is:-\n%s\n\n" "$(uptime)" | tee -a "${HOME}/login.log"
printf "The hostname is $(hostname -f)\n\n"

if [ -f "${HOME}/.upd_chk" ] ; then
    lastrun=$(cat "${HOME}/.upd_chk")
else
    dt="1974-01-01 00:00:00"
    lastrun=`date --date="${dt}" +%s`
fi

dt=$(date +%Y-%m-%d\ %H:%M:%S)
currrun=$(date --date="$dt" +%s)
let "timesince=${currrun}-${lastrun}"
let "timelim=14400"
touch "${HOME}/.upd_list"

if [ ${timesince} -gt ${timelim} ] ; then
    printf "Checking for updates...\n\n" | tee -a "${HOME}/login.log"
    res="$( ${HOME}/bin/bronsonV2/myupdates.sh 2>&1 )"
    echo "${res}" > "${HOME}/.upd_list"
    echo "${currrun}" > "${HOME}/.upd_chk" 
else
    printf "Not checking for new updates \n\n" | tee -a "${HOME}/login.log"
fi

cat "${HOME}/.upd_list" | tee -a "${HOME}/login.log"
printf "\n" | tee -a "${HOME}/login.log"

if [ -x /usr/bin/screen ] ; then
    /usr/bin/screen -ls | tee -a "${HOME}/login.log"
else
    echo "screen is not currently installed.  Install with 'sudo apt-get install screen'" | tee -a "${HOME}/login.log"
fi

printf "%s\n" "That's all folks!" | tee -a "${HOME}/login.log"