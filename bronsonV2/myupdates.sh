#!/bin/bash
echo -en "Checking for updates....\r"
sudo apt-get update > /dev/null 2>&1

declare res=$( apt-get --just-print upgrade 2>&1 | \
    perl -ne 'if (/Inst\s([\w,\-,\d,\.,~,:,\+]+)\s\[([\w,\-,\d,\.,~,:,\+]+)\]\s\(([\w,\-,\d,\.,~,‌​:,\+]+)\)? /i) {print "Program: $1 Installed: $2 Available: $3\n"}' | \
    column -s " " -t \
)
declare -i count=$( wc -l <<< "${res}")

if [[ ! -z ${res} ]] ; then
    if [[ ${1} == "--verbose" ]] ; then
        echo -en "${res}\n\n${count} updates are available. \n\n"
    else
        echo -en "*** ${count} updates are available. ***   \n\n"
    fi
else
    echo -en "No updates are currently available.        \n\n"
fi
