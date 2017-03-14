#!/bin/bash
#
# Initalise variables
#

RET=255
ATTEMPT=0
SECONDS=0
TOREACHED="false"
MESS=""
LASTRES=" "
CONNECTED="false"

#
# Set command line defaults
#

HOST="advent"
QUIET="false"
VERBOSE="false"
WAIT="false"
WAKEUP="false"
CONNECT="false"
TIMEOUT=-1
FASTCONNECT="false"

#
# Pause function
#
function pause(){
   read -p "$*"
}

#
# Connect to Host functiom
#
function fnConnectToHost {

    if [ $QUIET == "false" ] ; then
        printf "\nConnecting to $HOST\n"
    fi

    SSHSTART=$SECONDS
    ssh -o ConnectTimeout=3 $HOST
    RET=$?

    if [ "${RET}" -eq 0 ] ; then
        CONNECTED="true"
        HOSTUP="true"
    else

 #       if [ $(($SECONDS-$SSHSTART)) -lt 30 ] ; then
            HOSTUP="false"
            CONNECTED="false"
            
            if [ $VERBOSE == "true" ] ; then
                printf "Host : ${HOST} : Connect Failed  Return : ${RET}\n"
            fi
 #       else
 #           HOSTUP="true"
 #           CONNECTED="true"
 #           RET=0
 #       fi
    fi
    
}

#
# Wakeup host function
#
function fnWakeupHost {

    if [ $HOSTUP == "false" ] ; then

        if [ $VERBOSE == "true" ] ; then 
            printf "Waking up $HOST\n"
        fi

        mac=$(awk "/$HOST/" /etc/macaddresses|awk -F'=' '{ print $1 }')

     	if [ $VERBOSE == "true" ] ; then
		    printf "MAC Address of host is $mac\n"
     	fi

     	wakeonlan $mac
        sleep 1
#
# Check host state
#
        fnCheckHostState
    fi
}

#
# Check host state Function
#

function fnCheckHostState {

    if [ $(ping -c 1 -s 1 -W 1 $HOST 1>/dev/null 2>&1;echo $?) -ne 0 ] ; then
        HOSTUP="false"
        
        if [ "${VERBOSE}" == "true" ] ; then
            printf "Pining ${HOST} says not up\n"
        fi

    else

        HOSTUP="true"

   	    if [ "${VERBOSE}" == "true" ] ; then
	       printf "Pining ${HOST} says up\n"
  	    fi
    fi
}

#
# Read commandline Function
#
function fnReadCommandline {
    local opt    

    while getopts ":h:qvwcfut:" opt; do

        MESS="$MESS-${opt} ${OPTARG} "

        case "${opt}" in
        u)
            WAKEUP="true"
            ;;
        h)
            HOST="${OPTARG}"
            ;;
        q)
            QUIET="true"
            ;;
        v)
            VERBOSE="true"
            ;;
        w)
            WAIT="true"
            ;;
        c)
            CONNECT="true"
            ;;
        t)
            TIMEOUT="${OPTARG}"
            ;;
        f)
            FASTCONNECT="true"
            ;;
        \?)
            printf "Invalid option: -${OPTARG}\n" >&2
            printf "Usage : ${0##*/} -h host -q -v -w -c -u -t [timeout]\n"
            exit 1
            ;;
        :)
            printf "Option -${OPTARG} requires an argument.\n" >&2
            printf "Usage : ${0##*/} -h host -q -v -w -c -u -t [timeout]\n"
            exit 1
            ;;
        esac
    done

    if [ "{$VERBOSE}" == "true" ] ; then
        printf "CommandLine : ${0##*/} ${MESS}\n"
    fi
}
#
# Display time function
#
function displaytime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))

  if [ $D -gt 1 ] ; then
    [[ $D > 0 ]] && printf '%d days ' $D
  else
    [[ $D > 0 ]] && printf '%d day ' $D
  fi
  
  if [ $H -gt 1 ] ; then
    [[ $H > 0 ]] && printf '%d hours ' $H
  else
    [[ $H > 0 ]] && printf '%d hour ' $H
  fi

  if [ $M -gt 1 ] ; then
    [[ $M > 0 ]] && printf '%d minutes ' $M
  else
    [[ $M > 0 ]] && printf '%d minute ' $M
  fi

  [[ $D > 0 || $H > 0 || $M > 0 ]] && printf 'and '

  if [ $S -eq 1 ] ; then
    printf '%d second' $S
  else
    printf '%d seconds' $S
  fi
}
