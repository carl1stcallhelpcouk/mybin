#!/bin/bash

#
# Get current directory
#

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then 
    DIR="$PWD"
fi

#
# Source standard functions and options
#
. "$DIR/getopts_long.sh"

fnHelp() {
me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
cat<<HELP
Usage :
    $me [-o|--host <host>] [-h|--help] [-q|--quiet] [-v|--verbose] [-w|--wait] [-c|--connect] [-u|--wake-up] [-t|--timeout <timeout>]
HELP
    exit 0
}

#
# Set default options
#
optHost=localhost
optHelp=false
optQuiet=false
optVerbose=false
optWait=false
optConnect=false
optWakeup=false
optTimeout=30

fnGetOps() {

   OPTLIND=1
   while getopts_long :o::h:q:v:w:c:u:t: opt \
     host required_argument \
     help no_argument \
     quiet no_argument \
     verbose no_argument \
     wait no_argument \
     connect no_argument \
     wakeup no_argument \
     timeout required_argument "" "$@"
   do
     case "$opt" in
       o|host) optHost=$OPTLARG;;
       h|help) optHelp=true;;
       q|quiet) optQuiet=true;;
       v|verbose) optVerbose=true;;
       w|wait) optWait=true;;
       c|connect) optConnect=true;;
       u|wakeup) optWakeup=true;;
       t|timeout) optTimeout=$OPTLARG;;
       :) printf >&2 '%s: %s\n' "${0##*/}" "$OPTLERR"
          fnHelp
          exit 1;;
     esac
   done
   shift "$(($OPTLIND - 1))"
}

fnGetOps "$@"
echo "optHost=$optHost  optHelp=$optHelp   optQuiet=$optQuiet   optVerbose=$optVerbose   optWait=$optWait   optConnect=$optConnect   optWakeup=$optWakeup   optTimeout=$optTimeout"
