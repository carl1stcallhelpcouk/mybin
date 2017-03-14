#!/bin/bash

declare -ar hosts=( www mysql mail nas gw dell-server dell-laptop)

printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
    "date               " "status " "host        " "type        " "name                " "result"
printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
    "-------------------" "-------" "------------" "------------" "--------------------" "-----------------------------------------------------------------------------------"

for host in ${hosts[@]} ; do
    ssh ${host} "/home/carl/bin/binsync > /dev/null 2>&1 ; /home/carl/bin/mystatus"
done
