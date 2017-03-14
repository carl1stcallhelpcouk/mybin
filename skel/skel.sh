#!/bin/bash
declare -r MYDEBUG=True
#|=== skel.sh ==================================================================
#|                                                                             |
#|FILE:         skel.sh                                                        |
#|                                                                             |
#|DESCRIPTION:  This is a template file for my bash scripts                    |
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

    fnDebug "fnMain() -- Starting fnProcess process"
    fnProcess &
    echo $! > "${PIDFILE}"

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
                fnDebug "conf["$section","${var}"]=${conf["$section","$var"]}"
            fi
        fi
    done < "${CONFFILE}"

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
    printf "%s\n" "${conf[@]:-}"
    fnDebug "fnReadCommandline() (end)\n"
    return 0
}

fnMonitorProcess() 
{
    fnDebug "\nfnMonitorProcess() (start)"
# Code Here
    fnDebug "fnMonitorProcess() (end)\n"    
    return 0
}

fnProcess() 
{
    fnDebug "\nfnProcess() (start)"
# Code Here
    fnDebug "fnProcess() (end)\n"    
    return 0 
}

fnCleanup()
{
    fnDebug "\nfnCleanup() (start)"
    rkill -v $(cat "${PIDFILE}") >&2
    rm -vf "${PIDFILE}" "${LOCKFILE}" >&2
    fnDebug "fnCleanup() (end)\n"
    return 0 
}

fnDebug() 
{ 
    [[ "${MYDEBUG}" == "True" ]] && echo -en "${@}\n"
}

fnExitTrap()
{

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

    local _ec="$?"
    local _cmd="${BASH_COMMAND:-unknown}"

    trap - ERR

    fnBoldMsg "\n\nThe command ${_cmd} exited with exit code ${_ec}."
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
    tput bold
    echo -en "${@}"
    tput sgr0
}

fnCenterMsg()
{
    local cols=$( tput cols )
    local rows=$( tput lines )
    local -i input_length
    local -i half_input_length
    local -i middle_row
    local -i middle_col
    local message="${@}"

    echo -e "\r"
    input_length=${#message}
    half_input_length=$(( $input_length / 2 ))
    middle_col=$(( ($cols / 2) - $half_input_length ))
    tput cuf $middle_col
    tput bold
    echo -en "${message}"
    tput sgr0
    tput cup $( tput lines ) 0
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
declare -fx fnCenterMsg
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

#
# Declare global variables.
#
declare -A conf=()
declare _showed_traceback=f

fnMain "${@}"
exit 0