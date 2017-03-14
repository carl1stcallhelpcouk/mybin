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
declare file

echo "running ${BINFILE}"

. "${BINDIR}/lib/read_ini.sh"

shopt -s nullglob
for file in "${BINDIR}/conf/clients-available/*.conf" ; do
    read_ini "${file}"
done 

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
#set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

declare host=gw

#
# Define colour escape sequences.
#
declare -rx BLACK=$(tput setaf 0)
declare -rx RED=$(tput setaf 1)
declare -rx GREEN=$(tput setaf 2)
declare -rx YELLOW=$(tput setaf 3)
declare -rx LIME_YELLOW=$(tput setaf 190)
declare -rx POWDER_BLUE=$(tput setaf 153)
declare -rx BLUE=$(tput setaf 4)
declare -rx MAGENTA=$(tput setaf 5)
declare -rx CYAN=$(tput setaf 6)
declare -rx WHITE=$(tput setaf 7)
declare -rx BRIGHT=$(tput bold)
declare -rx NORMAL=$(tput sgr0)
declare -rx BLINK=$(tput blink)
declare -rx REVERSE=$(tput smso)
declare -rx UNDERLINE=$(tput smul)

declare ini_key=""
declare ini_name=""
declare ini_ncathost=""
declare ini_ncatport=""
declare ini_server=""
declare ini_type=""
declare ini_up_res=""

declare ssh_tunnel_req=True
declare ssh_tunnel_open=False
declare this_server=""
declare c=1
declare ini_debug="False"

for (( c=1; c<=${INI__NUMSECTIONS}; c++ )) ; do
    declare ini_type="INI__serv${c}__type"
    declare ini_name="INI__serv${c}__name"
    declare ini_key="INI__serv${c}__key"
    declare ini_up_res="INI__serv${c}__up_res"
    declare ini_server="INI__serv${c}__server"
    declare ini_ncathost="INI__serv${c}__ncathost"
    declare ini_ncatport="INI__serv${c}__ncatport"
    this_server="$(hostname -s)"

    if [[ "${!ini_server}" == "${!ini_ncathost}" ]] ; then
        ssh_tunnel_req=False
    else
        if [[ "${ssh_tunnel_open}" != "True" ]] ; then
            ssh_tunnel_req=True
        else
            ssh_tunnel_req=False
        fi
    fi

    if [[ "${!ini_server}" == "${this_server}" ]] ; then
        msg_date="$(date +"%Y-%m-%d %H:%M:%S")"
        msg_fqdn="$(hostname -f)"
        msg_me="$(hostname -s)"
        msg_type=${!ini_type}
        msg_name=${!ini_name}

        case "${!ini_type}" in 
        "netinf")
            cmd="ifconfig ${msg_name}"
            ;;
        "systemd")
            cmd="service ${msg_name} status"
            ;;
        "vbox")
            cmd="vboxmanage showvminfo ${msg_name}"
            ;;
        *)
            cmd="printf "Unknown type ; ${msg_type}\n""
            ;;
        esac
        res="$(${cmd} | grep "${!ini_key}" | sed -e 's/^[[:space:]]*//' | awk '{$2=$2};1')"

        if (echo ${res} | grep "${!ini_up_res}" 1>/dev/null 2>&1) ; then
            msg_stat="[ OK ]"                       
        else
            msg_stat="[DOWN]"
        fi
        printf "%s %s %s\t%s\t%s\t%s\n" "${msg_stat}" "${msg_date}" "${msg_me}" "${msg_type}" "${msg_name}" "${res}"

        if [[ "${!ini_ncathost}" != "" ]] ; then
            if [[ "${ssh_tunnel_req}" == "True" ]] ; then
                ssh -f -N -T -M -L 5000:localhost:5000 -o ControlPath=~/.ssh/${host} -o ControlMaster=yes gw
                if [[ "${ini_debug}" == "True" ]] ; then
                     echo -e "Tunnel opened\n" >&2
                fi
                ssh_tunnel_req=False
                ssh_tunnel_open=True

            else
                if [[ "${ini_debug}" == "True" ]] ; then
                    echo -e "Tunnel not opened\n" >&2
                fi
            fi
            printf "%s|%s|%s|%s|%s|%s\n" "${msg_stat}" "${msg_date}" "${msg_me}" "${msg_type}" "${msg_name}" "${res}" | ncat --wait 25 localhost ${!ini_ncatport}
            sleep 0.5
        fi
        if [[ "${ini_debug}" == "True" ]] ; then
            echo -e "Tunnel not opened\n" >&2
        fi
    fi

done

if [[ "${ssh_tunnel_open}" == "True" ]] ; then
    if [[ "${ini_debug}" == "True" ]] ; then
        echo -e "Closing tunnel.\n" >&2
    fi
    ssh -o ControlPath=~/.ssh/${host} -T -O "exit" ${!ini_ncathost} >&2
else
    if [[ "${ini_debug}" == "True" ]] ; then
        echo -e "Not closing tunnel.\n" >&2
    fi
fi
exit 0
