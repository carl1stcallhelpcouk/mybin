#!/bin/bash
set -x
source lib/funcs.shinc

#
# If paramiter(s) passed, then run the function if it exists and print the results.
#
fn="${1}"

if [ -n "${fn}" ]; then 
    fnType=$(type -t "${fn}")

    if [ "${fnType}x" == "functionx" ] ; then
        shift
        ${fn} "${*}"
        printf "${msg}\n"
    
        if [ $ret -eq 0 ] ; then
            printf "Result %s\n" "Success"
        else
            printf "Restlt %s Code %s\n" "Failier" "${ret}"
        fi
     fi
else
    printf "\n%s\n" "Usage  :  ${0} [Function] [Paramiters]"
    printf "\n%s\n" "Functions :-"    
    declare -fF | cut -d ' ' -f3 | while read line; do hlpVar="${line}Help"; printf "\t%s\n" "${!hlpVar}"; done    
fi
