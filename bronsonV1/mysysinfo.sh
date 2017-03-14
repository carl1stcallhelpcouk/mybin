#!/bin/bash
printf "%s\n\n%s\n\n" "Hello $(getent passwd ${USER} | cut -d ':' -f 5 | cut -d ',' -f 1)." "$(uname -a)" | tee "${HOME}/login.log"
printf "\n%s\n%s\n" "Last Login" "$(lastlog -u "${USER}")" | tee -a "${HOME}/login.log"
printf "\nToday's date is %s. this is week %s.\n" "$(date)" "$(date +"%V")" | tee -a "${HOME}/login.log"
printf "These users are currently connected:\n%s\n" "$(w -u)"  | tee -a "${HOME}/login.log"
printf "\nThis is %s running on a %s processor.\n" "$(uname -s)" "$(uname -m)" | tee -a "${HOME}/login.log"
printf "The the uptime information is:-\n%s\n\n" "$(uptime)" | tee -a "${HOME}/login.log"

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
    ( sudo apt-get update > /dev/null 2>&1 && apt-get --just-print upgrade 2>&1 | perl -ne 'if (/Inst\s([\w,\-,\d,\.,~,:,\+]+)\s\[([\w,\-,\d,\.,~,:,\+]+)\]\s\(([\w,\-,\d,\.,~,‌​:,\+]+)\)? /i) {print "PROGRAM: $1 INSTALLED: $2 AVAILABLE: $3\n"}' | column -s " " -t | tee -a "${HOME}/login.log" > "${HOME}/.upd_list" 2>&1 ) &
    echo "${currrun}" > "${HOME}/.upd_chk" 

else

    printf "Not checking for new updates \n\n" | tee -a "${HOME}/login.log"
    cat "${HOME}/.upd_list"

fi

printf "\n" | tee -a "${HOME}/login.log"
screen -ls | tee -a "${HOME}/login.log"

if [ -x "${HOME}/bin/lola/binsync.sh" ] ; then

	echo "Syncing ${HOME}/bin directory." | tee -a "${HOME}/login.log"
	source ${HOME}/bin/lola/binsync.sh >> "${HOME}/login.log" 2>&1 &

fi

bin/mystatus >> "${HOME}/login.log" 2>&1 &
printf "\n\nThat's all folks!\n"
