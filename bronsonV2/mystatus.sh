#!/bin/bash
declare -r MYDEBUG=False
#|=== mystatus.sh ==============================================================
#|                                                                             |
#|FILE:         mystatus.sh                                                    |
#|                                                                             |
#|DESCRIPTION:  This is a script to send the current status to a mystatusd     |
#|              server.                                                        |
#|                                                                             |
#|BUGS:         Report all bugs and/or sugestions to bugs@1stcallhelp.co.uk.   |
#|                                                                             |
#|AUTHOR:       <Carl McAlwane>carl@1stcallhelp.co.uk                          |
#|                                                                             |
#|COMPANY:      1stcallhelp.co.uk                                              |
#|                                                                             |
#|VERSION:      2.0                                                            |
#|                                                                             |
#|CREATED:      31.07.2016                                                     |
#|                                                                             |
#|REVISION:     dev.2.0.2016                                                   |
#|                                                                             |
#|COPYRIGHT:    (C)2000-2016 1st Call Group.  All rights reserved.             |
#|                                                                             |
#|TODO:                                                                        |
#|                                                                             |
#|==============================================================================
#
# Store allready declared variables.
#
declare -a initial_variables=()
[[ ${MYDEBUG} == "True" ]] && echo -en "Debugging is on!\n"; initial_variables=( "$( compgen -v )" )
                                                          
#
# Main function
#
fnMain()
{
    fnDebug "\nfnMain() (start)"

    fnDebug "fnMain() -- Calling fnInitialise"
    fnInitialise

#    fnDebug "fnMain() -- Starting fnProcess process"
#    fnProcess &
#    echo $! > "${PIDFILE}"

    fnDebug "fnMain() -- Calling fnMonitorProcess"
    fnMonitorProcess

    fnDebug "fnMain() (end)\n"
    return 0

}

#                                                                              #
################################################################################
#                                                                              #

fnInitialise() 
{
    fnDebug "\nfnInitialise() (start)"
    fnDebug "fnInitialise() -- Setting Shell Options."
    set -o errtrace
    set -o pipefail
    set -o nounset
    set -o errexit

#    shopt -s nullglob

    fnDebug "fnInitialise() -- Setting Error Trap."
    trap fnErrorTrap ERR

    fnDebug "fnInitialise() -- Setting Exit Trap."
    trap fnExitTrap EXIT

    fnDebug "fnInitialise() -- Setting default configuration options."
    conf[global,help]=False

    fnDebug "fnInitialise() -- Calling fnReadConfig"
    fnReadConfig

    fnDebug "fnInitialise() -- Calling fnReadCommandline"
    fnReadCommandline "${@}"

    fnDebug "fnInitialise() (end)\n"
    return 0
}

fnReadConfig() 
{
    local var
    local val
    local section="global"
    local file
    local -a confarray=( "${CONFDIR}/clients-enabled/${SHORTHOST}*.conf" )
    local IFS=''

    fnDebug "\nfnReadConfig() (start)"
    fnDebug "fnReadConfig() -- confarray = ${confarray[@]}\n"
    for file in ${confarray} ; do

        fnDebug "fnReadConfig() -- file = ${file}\n"
        while IFS='= ' read var val
        do
            if [[ ${var} != "#" ]] ; then 
                if [[ ${var} == \[*] ]] ; then
                    section=$(echo "${var}" | tr -d "[" )
                    section=$(echo "${section}" | tr -d "]" )
                    sections+=(${section})
                elif [[ ${val} ]]
                then
                    conf["${section}","${var}"]="${val}"
#                    fnDebug "conf["$section","${var}"]=${conf["$section","$var"]}"
                fi
            fi
        done < "${file}"
    done

    fnDebug "fnReadConfig() (end)\n"
    return 0
}

fnGetScriptDir () {
 
    local BINNAME="${BASH_SOURCE[0]}"
    local SOURCE="${BINNAME}"
    local DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"

    if [[ ${1} == "DIR" ]] ; then
        echo -en "${DIR}"
        return 0
    fi

    if [[ "${1}" == "FNAME" ]] ; then
        echo -en "${BINNAME}"
        return 0
    fi

    # While $SOURCE is a symlink, resolve it
    while [ -h "${SOURCE}" ]; do
         DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
         SOURCE="$( readlink "${SOURCE}" )"

         # If ${SOURCE} was a relative symlink (so no "/" as prefix,
         # need to resolve it relative to the symlink base directory
         [[ ${SOURCE} != /* ]] && SOURCE="${DIR}/${SOURCE}"
    done

    if [ "${1}" == "RNAME" ] ; then
         echo -en "${SOURCE}"
         return 0
    fi 

    if [[ "${1}" == "RDIR" ]] ; then
         DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
         echo -en "${DIR}"
         return 0
    fi
    echo "fnGetScriptDir -- Unknown paramiter ${1}" >&2
    return 1
}

fnReadCommandline() 
{
    fnDebug "\nfnReadCommandline() (start)"

    local OPTLIND=1
    local opt

    fnDebug "fnReadCommandline() Sourcing getopts_long.\n"
    . "${LIBDIR}/getopts_long.sh"

    while getopts_long ":h" opt \
        help no_argument "" "$@"
    do
        fnDebug "opt = ${opt}"
        case "$opt" in
        h|help)
            conf[global,help]=True;;
        :)
            echo "Invalid option ${opt} specified." >&2
            conf[global,help]=True;;
        esac
    done
    shift "$(($OPTLIND - 1))"
#    printf "%s\n" "${conf[@]:-}"
    fnDebug "fnReadCommandline() (end)\n"
    return 0
}

fnMonitorProcess() 
{
    local section=''
    local var=''
    local IFS=''
    local res=''
    local fullRes=''
    local msg=''
    local ncmsg=''
    local msg_stat=''
    local msg_host=''
    local msg_type=''
    local msg_name=''
    local msg_date="$(date +"%Y-%m-%d %H:%M:%S")"

    fnDebug "\nfnMonitorProcess() (start)"


#    if [[ "${conf[global,ncathost]}" != "${SHORTHOST}" ]]; then
#        fnDebug "fnMonitorProcess -- Opening ssh tunnel to "
#        fnDebug "${conf[global,ncathost]}:${conf[global,ncatport]}\n"
#        ssh -f -o ExitOnForwardFailure=yes "${conf[global,ncathost]}" -L \
#            "${conf[global,ncatport]}:${conf[global,ncathost]}:${conf[global,ncatport]}" \
#            sleep 10
#        local nchost="localhost"
#    else
        local nchost="${SHORTHOST}"   #  "${conf[global,ncathost]}"
#        fnDebug "fnMonitorProcess -- No ssh tunnel required"
#    fi
#
#    fnDebug "fnMonitorProcess -- Port open for 10 seconds"

    for section in "${sections[@]}" ; do

        case "${conf[${section},type]}" in 
        "netinf")
            cmd='/sbin/ifconfig "${conf[${section},name]}"'
            ;;
        "systemd")
            cmd="/usr/sbin/service ${conf[${section},name]} status"
            ;;
        "vbox")
            cmd='/usr/bin/vboxmanage showvminfo "${conf[${section},name]}"'
            ;;
        "myupdates")
            cmd='/home/carl/bin/bronsonV2/myupdates.sh'
            ;;
        *)
            cmd='printf "Unknown type : ${conf[${section},name]}\n"'
#            exit 1
            ;;
        esac


        fnDebug "cmd1 = ${cmd} - conf[${section},name] = ${conf[${section},name]} - conf[${section},key] = ${conf[${section},key]}\n"
        [[ "${MYDEBUG}" == True ]] && trap - ERR
        fullRes=$( eval "${cmd}" || true )
        cmd='echo "${fullRes}" | grep "${conf[${section},key]}"'
        fnDebug "res1 = ${fullRes}\n\ncmd2 = ${cmd}\n"
        res=$( eval "${cmd}" || true )
        cmd='echo "${res}" | sed -e "s/^[[:space:]]*//"'
        fnDebug "res2 = ${res}\n\ncmd3 = ${cmd}\n"
        res=$( eval "${cmd}" || true )
        cmd='echo "${res}" | awk "{\$2=\$2};1"'
        fnDebug "res3 = ${res}\n\ncmd4 = ${cmd}\n"
        res=$( eval "${cmd}" || true )
        fnDebug "res4 = ${res}"

        if (echo "${res}" | grep "${conf[${section},up_res]}" 2>&1 >/dev/null) ; then
            ncmsg_stat="[PASS]"                       
            msg_stat="${GREEN}[PASS]${NORMAL}"                       
        else
            ncmsg_stat="[FAIL]"
            msg_stat="${RED}[FAIL]${NORMAL}"
        fi

        msg_host=$( cut -c1-12 <<<"${SHORTHOST}" )
        msg_type=$( cut -c1-12 <<<"${conf[${section},type]}" )
        msg_name=$( cut -c1-20 <<<"${conf[${section},name]}" )

        msg=$( printf "%-19s\t%-7s\t%-12s\t%-12s\t%-20s\t%s\n" \
            "${msg_date}" "${msg_stat}" "${msg_host}" \
            "${msg_type}" "${msg_name}" "${res}" )

        ncmsg=$( printf "%s|%s|%s|%s|%s|%s\n" \
            "${msg_date}" "${ncmsg_stat}" "${SHORTHOST}" \
            "${conf[${section},type]}" "${conf[${section},name]}" "${res}" )

        printf "%s\n" "${msg}"

        fnDebug "Running - ncat ${nchost} ${conf[global,ncatport]} <<<\"${msg}\""
        ncat "${nchost}" "${conf[global,ncatport]}" <<<"${ncmsg}"
        msgs+=( "${ncmsg}|${fullRes}" )
    done 
    
    fnDebug "fnMonitorProcess() (end)\n" "True"   
    return 0
}

fnProcess() 
{
    fnDebug "\nfnProcess() (start)"
    
    for msg in msgs ; do
        printf "%s\n" "${msg}"
    done

    fnDebug "fnProcess() (end)\n"    
    return 0 
}

fnCleanup()
{
    fnDebug "\nfnCleanup() (start)"
    [[ -e "${PIDFILE}" ]] && rkill -v $(cat "${PIDFILE}") >&2 ; rm -vf "${PIDFILE}" >&2
    [[ -e  "${LOCKFILE}" ]] && rm -vf "${PIDFILE}" >&2
    fnDebug "fnCleanup() (end)\n"
    return 0 
}

fnDebug() 
{ 
    [[ "${MYDEBUG}" == "True" ]] && echo -en "${1}\n"
    if [[ "${2:-false}" == "True" ]] ; then
        trap - EXIT
        exit 1
    fi

}

fnExitTrap()
{

    set +x
    local _ec="$?"

    trap - ERR
    trap - EXIT

    if [[ $_ec != 0 && "${_showed_traceback}" != t ]]; then

        fnTraceBack 1
        _showed_traceback=t

    fi

    if [[ ${MYDEBUG} == "True" ]] ; then

        fnBoldMsg "\n--------------------- Variable dump ---------------------\n"
        fnBoldMsg "$(fnDisplayDebugInfo)\n"
        for i in "${!conf[@]}"; do fnBoldMsg "conf[$i] = ${conf[$i]}\n"; done
        fnBoldMsg "---------------------------------------------------------\n\n"

    fi

    fnDebug "fnMain() -- Calling fnCleanup"
    fnCleanup
    exit "${_ec}"
}

fnErrorTrap()
{
    set +x
    local _ec="$?"
    local -a _ps="${PIPESTATUS[@]}"
    local _cmd="${BASH_COMMAND:-unknown}"

    trap - ERR

    fnBoldMsg "\n\nThe command ${_cmd} exited with exit code ${_ec} pipe status ${_ps[@]}."
    fnTraceBack 1
    _showed_traceback=t
    
}


fnDisplayDebugInfo()
{

#-------------------------------------------------------------------------------   
# Get the currently defined variables
#
    local -a values_now=( "$( compgen -v )" ) 
#   
# Remove all the variables that were allready defined when the script started  
#
    for item in ${initial_variables[@]} ; do
         values_now=( "${values_now[@]/$item}" )
    done
#-------------------------------------------------------------------------------   

#-------------------------------------------------------------------------------   
# Output all the new variables and there values
#
    for item in ${values_now[@]} ; do
        if [ "${item}" != "" ] ; then
           declare -p "${item}"
        fi
    done
#-------------------------------------------------------------------------------   
}

fnIsArray() {
  local variable_name=$1
  [[ "$(declare -p $variable_name)" =~ "declare -a" ]] || [[ "$(declare -p $variable_name)" =~ "declare -A" ]] 
}


fnTraceBack()
{
  # Hide the fnTraceBack() call.
  local -i start=$(( ${1:-0} + 1 ))
  local -i end=${#BASH_SOURCE[@]}
  local -i i=0
  local -i j=0

  fnBoldMsg "\n----------- Traceback (last called is first): -----------\n"
  for ((i=${start}; i < ${end}; i++)); do
    j=$(( $i - 1 ))
    local function="${FUNCNAME[$i]}"
    local file="${BASH_SOURCE[$i]}"
    local line="${BASH_LINENO[$j]}"
    fnBoldMsg "${function}() in ${file}:${line}\n"
  done
  fnBoldMsg "---------------------------------------------------------\n"
}

fnBoldMsg()
{
    echo -en "${BRIGHT}${@}${NORMAL}"
}

#
# Declare global functions.
#
declare -fx fnMain
declare -fx fnInitialise
declare -fx fnReadCommandline
declare -fx fnReadConfig
declare -fx fnProcess
declare -fx fnCleanup
declare -fx fnErrorTrap
declare -fx fnBoldMsg
declare -fx fnDebug
declare -fx fnDisplayDebugInfo
declare -fx fnExitTrap
declare -fx fnGetScriptDir
declare -fx fnMonitorProcess
declare -fx fnTraceBack

#
# Declare global constants.
#
declare -r SCRIPTDIR=$(fnGetScriptDir "DIR")
declare -r REALDIR=$(fnGetScriptDir "RDIR")
declare -r LIBDIR="${REALDIR}/lib"
declare -r CONFDIR="${REALDIR}/conf"
declare -r TMPDIR="${REALDIR}/tmp"
declare -r LOGDIR="${REALDIR}/log"
declare -r SCRIPTFILE=$(fnGetScriptDir "FNAME")
declare -r REALSCRIPT=$(fnGetScriptDir "RNAME")
declare -r SCRIPTFNAME=$(basename "${REALSCRIPT}")
declare -r SCRIPTSNAME="${SCRIPTFNAME%.*}"
declare -r LOCKFILE="${TMPDIR}/${SCRIPTSNAME}.lock"
declare -r PIDFILE="${TMPDIR}/${SCRIPTSNAME}.pid"
declare -r CONFFILE="${CONFDIR}/${SCRIPTSNAME}.conf"
declare -r SHORTHOST="$(hostname -s)"
declare -r LONGHOST="$(hostname -f)"

#
# Define colour escape sequences.
#
declare -r BLACK=$(tput -T screen setaf 0)
declare -r RED=$(tput -T screen setaf 1)
declare -r GREEN=$(tput -T screen setaf 2)
declare -r YELLOW=$(tput -T screen setaf 3)
declare -r LIME_YELLOW=$(tput -T screen setaf 190)
declare -r POWDER_BLUE=$(tput -T screen setaf 153)
declare -r BLUE=$(tput -T screen setaf 4)
declare -r MAGENTA=$(tput -T screen setaf 5)
declare -r CYAN=$(tput -T screen setaf 6)
declare -r WHITE=$(tput -T screen setaf 7)
declare -r BRIGHT=$(tput -T screen bold)
declare -r NORMAL=$(tput -T screen sgr0)
declare -r BLINK=$(tput -T screen blink)
declare -r REVERSE=$(tput -T screen smso)
declare -r UNDERLINE=$(tput -T screen smul)


#
# Declare global variables.
#
declare -A conf=()
declare -a sections=()
declare _showed_traceback=f
declare -i ret=0
declare -a msgs=()

fnMain "${@}"
exit 0