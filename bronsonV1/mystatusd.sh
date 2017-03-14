#!/bin/bash
#

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"
     # While $SOURCE is a symlink, resolve it
     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          # If $SOURCE was a relative symlink (so no "/" as prefix, need to resolve it relative to the symlink base directory
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
}
get_script_dir

declare BINFILE=${SOURCE}
declare BINDIR=${DIR}

echo "running ${BINFILE}"

declare -i ret=0
declare -ri status=0
declare -ri timestamp=1
declare -ri server=2
declare -ri type=3
declare -ri name=4
declare -ri responce=5
declare line=""
declare -a statLine
declare IFS='|'
declare -r lastStat="/var/log/mystatusd.last"
declare -r nextStat="/var/log/mystatusd.next"
declare -r htmlFile="/var/www/html/index.html"
declare -r htmlTeml="${BINDIR}/conf/mystatusd.teml"

while [[ ${ret} -eq 0 ]] ; do

    line="$(ncat --listen 5000 && ret=$?)"

    if [[ ${ret} -eq 0 ]] ; then

        read -ra statLine <<< "${line}"
        touch "${lastStat}"

        sed "/|${statLine[${server}]}|${statLine[${type}]}|${statLine[${name}]}|/d" "${lastStat}" > "${nextStat}"
        echo "${line}" | tee -a "${nextStat}"
        rm "${lastStat}" >&2
        sort -k2 -Vr "${nextStat}" > "${lastStat}"
        rm  "${htmlFile}" > /dev/null 2>&1
        touch "${htmlFile}"
        chown www-data:www-data "${htmlFile}"
        
        while IFS='' read -r line || [[ -n "${line}" ]] ; do

            if [[ "${line}" =~ "--TABLEDATA--" ]]; then

                while IFS='' read -r line || [[ -n "${line}" ]] ; do

                    if [[ "${line}" != "" ]] ; then

                        IFS='|' read -ra statLine <<< "${line}"
                        printf "        %s\n" "<tr><td>${statLine[0]}</td><td>${statLine[1]}</td><td>${statLine[2]}</td><td>${statLine[3]}</td><td>${statLine[4]}</td><td>${statLine[5]}</td></tr>" >> ${htmlFile}

                    fi

                done < "${lastStat}" 

            else

                echo "${line/--TITLE--/mystatusd Latest Updates on ${HOSTNAME}}" >> ${htmlFile}

            fi

        done < "${htmlTeml}"

    else

        echo "ncat returned ${ret}" >&2
        exit ${ret}

    fi

done
