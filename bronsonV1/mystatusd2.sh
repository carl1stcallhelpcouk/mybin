#!/bin/bash
declare -r MYDEBUG=True
#|=== mystatusd2.sh ============================================================
#|                                                                             |
#|FILE:         mystatusd2.sh                                                  |
#|                                                                             |
#|DESCRIPTION:  This is the second incarnation of the mystatusd deamon script. |
#|              This time i'm going to try to background the ncat process      |
#|              while sending the output to a named pipe.  The main process    |
#|              will then monitor the pipe and process each status line        |
#|              recieved.                                                      |
#|                                                                             |
#|BUGS:         Report all bugs and/or sugestions to bugs@1stcallhelp.co.uk.   |
#|                                                                             |
#|AUTHOR:       <Carl McAlwane>carl@1stcallhelp.co.uk                          |
#|                                                                             |
#|COMPANY:      1stcallhelp.co.uk                                              |
#|                                                                             |
#|VERSION:      2.0                                                            |
#|                                                                             |
#|CREATED:      25.07.2016                                                     |
#|                                                                             |
#|REVISION:     dev.0.0.2016                                                   |
#|                                                                             |
#|COPYRIGHT:    (C)2000-2016 1st Call Group.  All rights reserved.             |
#|                                                                             |
#|TODO:         1. Everything atm.                                             |
#|                                                                             |
#|==============================================================================
#

fnMain() 
{
    fnDebug "\nfnMain (start)"

    fnDebug "fnMain -- Calling fnInitialise"
    fnInitialise #|| fnError "${0}" "${LINENO}" "${@}"

    fnDebug "fnMain -- Calling fnReadCommandline"
    fnReadCommandline #|| "${0}" "${LINENO}" "${@}"

    fnDebug "fnMain -- Calling fnReadConfig"
    fnReadConfig #|| fnError "${0}" "${LINENO}" "${@}"

    fnDebug "fnMain -- Calling fnMonitorProcess"
    fnMonitorProcess #&

    fnDebug "fnMain -- Calling fnUpdate"
    fnUpdate #|| fnError "${0}" "${LINENO}" "${@}"

    fnDebug "fnMain -- Calling fnCleanup"
    fnCleanup #|| fnError "${0}" "${LINENO}" "${@}"

    fnDebug "fnMain (end)\n"
    return 0

}

#                                                                              #
################################################################################
#                                                                              #

fnInitialise() 
{
    fnDebug "\nfnInitialise (start)"

    fnDebug "fnInitialise -- Setting Shell Options"
    set -o errtrace
    set -o pipefail
    set -o nounset
    set -o errexit

    fnDebug "fnInitialise -- Setting Error Trap"
    trap fnErrorTrap ERR

    fnDebug "fnInitialise -- Setting Exit Trap"
    trap fnExitTrap EXIT

    fnDebug "fnInitialise (end)\n"
    return 0
}

fnReadConfig() 
{
    fnDebug "\nfnReadConfig (start)"
# code here    
    fnDebug "fnReadConfig (end)\n"
    return 0
}

fnReadCommandline() 
{
    fnDebug "\nfnReadCommandline (start)"
# code here
    fnDebug "fnReadCommandline (end)\n"
    return 0
}

fnMonitorProcess() 
{
    fnDebug "\nfnMonitorProcess (start)"
# code here
    fnDebug "fnMonitorProcess (end)\n"    
    return 0
}

fnUpdate() 
{
    fnDebug "\nfnUpdate (start)"
    cat filenot.found
    fnDebug "fnUpdate (end)\n"    
    return 0 
}

fnCleanup()
{
    fnDebug "\nfnCleanup (start)"
# code here
    fnDebug "fnCleanup (end)\n"
    return 0 
}

fnDebug() 
{ 
    [[ "${MYDEBUG}" == "True" ]] && echo -e "${@}" >&2
}

fnExitTrap()
{
  local _ec="$?"
  if [[ $_ec != 0 && "${_showed_traceback}" != t ]]; then
    traceback 1
    _showed_traceback=t
  fi
}

fnErrorTrap()
{
  local _ec="$?"
  local _cmd="${BASH_COMMAND:-unknown}"
  trap - ERR
  tput bold
  echo -e "\n\nThe command ${_cmd} exited with exit code ${_ec}." 1>&2
  tput sgr0
  fnTraceBack 1
  _showed_traceback=t
}

fnTraceBack()
{
  # Hide the fnTraceBack() call.
  local -i start=$(( ${1:-0} + 1 ))
  local -i end=${#BASH_SOURCE[@]}
  local -i i=0
  local -i j=0

#  echo -e "\n ----------- Traceback (last called is first): -----------" 1>&2
  fnCenterMsg "----------- Traceback (last called is first): -----------"
  for ((i=${start}; i < ${end}; i++)); do
    j=$(( $i - 1 ))
    local function="${FUNCNAME[$i]}"
    local file="${BASH_SOURCE[$i]}"
    local line="${BASH_LINENO[$j]}"
#    echo -e "     ${function}() in ${file}:${line}" 1>&2
    fnCenterMsg "${function}() in ${file}:${line}"
  done
  fnCenterMsg "---------------------------------------------------------\n"
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

  echo -e "\r" >&2
  input_length=${#message}
  half_input_length=$(( $input_length / 2 ))
  middle_col=$(( ($cols / 2) - $half_input_length ))
  tput cuf $middle_col
  tput bold
  echo -en "${message}" >&2
  tput sgr0
  tput cup $( tput lines ) 0
}


declare -fx fnMain
declare -fx fnInitialise
declare -fx fnReadCommandline
declare -fx fnReadConfig
declare -fx fnMonitorProcess
declare -fx fnUpdate
declare -fx fnCleanup
declare -fx fnErrorTrap

declare _showed_traceback=f

fnMain "${@}"
exit 0