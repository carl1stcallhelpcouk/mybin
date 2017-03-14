#!/bin/bash
declare -r MYDEBUG=False
#|=== mystatusd.sh ============================================================|
#|                                                                             |
#|FILE:         mystatusd.sh                                                   |
#|                                                                             |
#|CODENAME:     Bronson                                                        |
#|                                                                             |
#|DESCRIPTION:  mystatusd is listens for status updates from configured        |
#|              servers on the network.  The default port if 5000 but can be   |
#|              configured to use any available port, either in                |
#|              conf/mystatusd.conf or on the commandline.    
#|                                                                             |
#|BUGS:         Report all bugs and/or sugestions to bugs@1stcallhelp.co.uk.   |
#|                                                                             |
#|AUTHOR:       <Carl McAlwane>carl@1stcallhelp.co.uk                          |
#|                                                                             |
#|COMPANY:      1stcallhelp.co.uk                                              |
#|                                                                             |
#|VERSION:      1.0                                                            |
#|                                                                             |
#|CREATED:      28.07.2016                                                     |
#|                                                                             |
#|REVISION:     dev.0.0.2016                                                   |
#|                                                                             |
#|COPYRIGHT:    (C)2000-2016 1st Call Group.  All rights reserved.             |
#|                                                                             |
#|TODO:                                                                        |
#|                                                                             |
#|=============================================================================|
#
# Store allready declared variables.
#
declare -a initial_variables=()
[[ ${MYDEBUG} == "True" ]] && initial_variables=( "$( compgen -v )" )
                                                          
#
# Main function
#
fnMain()
{
    fnDebug "\nfnMain() (start)"
    [[ ${MYDEBUG} == "True" ]] && fnBoldMsg "Debugging is on!\n"

    fnDebug "fnMain() -- Calling fnInitialise"
    fnInitialise

    fnDebug "fnMain() -- Starting fnProcess process"
    fnProcess &
    echo $! > "${PIDFILE}"

    fnDebug "fnMain() -- Calling fnMonitorProcess"
    fnMonitorProcess

#    fnDebug "fnMain() -- Calling fnCleanup"
#    fnCleanup

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

    fnDebug "fnInitialise() -- Setting Error Trap."
    trap fnErrorTrap ERR

    fnDebug "fnInitialise() -- Setting Exit Trap."
    trap fnExitTrap EXIT

    fnDebug "fnInitialise() -- Setting default configuration options."
    conf[global,help]=False
    conf[global,port]=5000
    conf[global,host]="$(hostname -s)"
    conf[global,fifoInFile]="${TMPDIR}/${SCRIPTSNAME}.in"
    conf[global,fifoOutFile]="${TMPDIR}/${SCRIPTSNAME}.out"

    fnDebug "fnInitialise() -- Calling fnReadConfig"
    fnReadConfig

    fnDebug "fnInitialise() -- Calling fnReadCommandline"
    fnReadCommandline "${@}"

    fnDebug "fnInitialise() -- Createing fifo files."
    
    [[ ! -p "${conf[global,fifoInFile]}" ]] && \
    [[ -e "${conf[global,fifoInFile]}" ]] && \
        fnBoldMsg "${conf[global,fifoInFile]} exists but is not a pipe\n" && exit 1 
    [[ ! -p "${conf[global,fifoOutFile]}" ]] && \
    [[ -e "${conf[global,fifoOutFile]}" ]] && \
        fnBoldMsg "${conf[global,fifoOutFile]} exists but is not a pipe\n" && exit 1 
    [[ ! -e "${conf[global,fifoInFile]}" ]] && mkfifo "${conf[global,fifoInFile]}"
    [[ ! -e "${conf[global,fifoOutFile]}" ]] && mkfifo "${conf[global,fifoOutFile]}"

    fnDebug "fnInitialise() (end)\n"
    return 0
}

fnReadConfig() 
{
    local var
    local val
    local section="global"

    fnDebug "\nfnReadConfig() (start)"

    while IFS='= ' read var val
    do
        if [[ ${var} != "#" ]] ; then 
            if [[ $var == \[*] ]] ; then
                section=$(echo "${var}" | tr -d "[" )
                section=$(echo "${section}" | tr -d "]" )
            elif [[ $val ]]
            then
                conf["$section","$var"]="$val"
#                fnDebug "conf["$section","${var}"]=${conf["$section","$var"]}"
            fi
        fi
    done < "${CONFDIR}/${SCRIPTSNAME}.conf"

    fnDebug "fnReadConfig() (end)\n"
    return 0
}

fnGetScriptDir ()
{
 
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
    fnBoldMsg "fnGetScriptDir -- Unknown paramiter ${1}"
    return 1
}

fnReadCommandline() 
{
    fnDebug "\nfnReadCommandline() (start)"

    local OPTLIND=1
    local opt

    . "${LIBDIR}/getopts_long.sh"

    while getopts_long ":h" opt \
        help no_argument "" "$@"
    do
#        fnDebug "opt = ${opt}"
        case "$opt" in
        h|help)
            conf[global,help]=True;;
        :)
            fnBoldMsg "Invalid option ${opt} specified."
            conf[global,help]=True;;
        esac
    done
    shift "$(($OPTLIND - 1))"
    fnDebug "${conf[@]:-}\n"
    fnDebug "fnReadCommandline() (end)\n"
    return 0
}

fnMonitorProcess() 
{
    fnDebug "\nfnMonitorProcess() (start)"
    local -a statLine
    local line
    local IFS="|"

    while true
    do
        if read line <"${conf[global,fifoOutFile]}"; then
            if [[ "$line" == 'quit' ]]; then
                break
            fi

            tee -a "${LOGDIR}/${SCRIPTSNAME}.${FUNCNAME[0]}.log" <<<"${line}"
            read -ra statLine <<< "${line}"
            [[ "${MYDEBUG}" == True ]] && fnDebug "$( declare -p statLine )"

            touch "${lastStat}"

            sed "/|${statLine[2]}|${statLine[3]}|${statLine[4]}|/d" "${lastStat}" > "${nextStat}"
            declare -p statLine >&2
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

        fi
    done

    fnDebug "fnMonitorProcess() (end)\n"    
    return 0
}

fnProcess() 
{
    local res

    fnDebug "\nfnProcess() (start)"
    if ( set -o noclobber; echo "locked" > "${LOCKFILE}") 2> /dev/null; then

        # --output "${LOGFILE}" 
        while [[ True == True ]] ; do
#            fnDebug "ncat --verbose --listen --keep-open --append-output --output \
            fnDebug "ncat --verbose --listen --append-output --output \
                ${LOGDIR}/${SCRIPTSNAME}.${FUNCNAME[0]}.log \
                ${conf[global,host]} ${conf[global,port]} \
                > ${conf[global,fifoOutFile]}" 

            ncat --verbose --listen --append-output --output \
                "${LOGDIR}/${SCRIPTSNAME}.${FUNCNAME[0]}.log" \
                "0.0.0.0" "${conf[global,port]}" \
                >> "${conf[global,fifoOutFile]}" || true
        done
        
    else

        fnBoldMsg "Lock failed - exiting.\n"
        exit 1

    fi
    fnDebug "fnProcess() (end)\n"    
    return 0 
}

fnCleanup()
{
    fnDebug "\nfnCleanup() (start)"
    [[ -e "${PIDFILE}" ]] && rkill -v $(cat "${PIDFILE}") >&2 ; rm -vf "${PIDFILE}" >&2
    [[ -e  "${LOCKFILE}" ]] && rm -vf "${LOCKFILE}" >&2
    fnDebug "fnCleanup() (end)\n"
    return 0 
}

fnDebug() 
{ 
    if [[ "${MYDEBUG}" == "True" ]] ; then 
        echo -en "${1}\n" >&2
        if [[ "${2:-false}" == "True" ]] ; then
            trap - EXIT
            exit 1
        fi
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

fnIsArray()
{
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
#    tput bold
    echo -en "${BRIGHT}${@}${NORMAL}" >&2
#    tput sgr0
}

#
# Declare functions.
#
declare -fx fnMain
declare -fx fnInitialise
declare -fx fnReadCommandline
declare -fx fnReadConfig
declare -fx fnProcess
declare -fx fnCleanup
declare -fx fnErrorTrap
declare -fx fnBoldMsg
declare -fx fnCenterMsg
declare -fx fnDebug
declare -fx fnDisplayDebugInfo
declare -fx fnExitTrap
declare -fx fnGetScriptDir
declare -fx fnMonitorProcess
declare -fx fnTraceBack

#
# Declare constants.
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
declare -r lastStat="${LOGDIR}/${SCRIPTSNAME}.last"
declare -r nextStat="${LOGDIR}/${SCRIPTSNAME}.next"
declare -r htmlFile="/var/www/html/index.html"
declare -r htmlTeml="${CONFDIR}/mystatusd.teml"

#
# Define colour escape sequences.
#
declare -r BLACK=$(tput -Tscreen setaf 0)
declare -r RED=$(tput -Tscreen setaf 1)
declare -r GREEN=$(tput -Tscreen setaf 2)
declare -r YELLOW=$(tput -Tscreen setaf 3)
declare -r LIME_YELLOW=$(tput -Tscreen setaf 190)
declare -r POWDER_BLUE=$(tput -Tscreen setaf 153)
declare -r BLUE=$(tput -Tscreen setaf 4)
declare -r MAGENTA=$(tput -Tscreen setaf 5)
declare -r CYAN=$(tput -Tscreen setaf 6)
declare -r WHITE=$(tput -Tscreen setaf 7)
declare -r BRIGHT=$(tput -Tscreen bold)
declare -r NORMAL=$(tput -Tscreen sgr0)
declare -r BLINK=$(tput -Tscreen blink)
declare -r REVERSE=$(tput -Tscreen smso)
declare -r UNDERLINE=$(tput -Tscreen smul)


#
# Declare variables.
#
declare -A conf=()
#declare -A commandline=()
#declare -A defaults=()

declare _showed_traceback=f

fnMain "${@}"
exit 0