#!/bin/bash

die () {
  echo >&2 "$@"
  exit 1
}

# we need one parameter - the hostname or IP address
[ "$#" -eq 1 ] || die "hostname or IP address is required, $# provided"

if [[ ! -f "/etc/ethers" ]]; then
  die "Can't find /etc/ethers file!"
fi

host="$1"

# if argument isn't an IPv4 address, try to resolve it
if [[ ! $host =~ ^([0-2]?[0-9]{1,2}\.){3}([0-2]?[0-9]{1,2})$ ]]; then
  echo "Attempting to identify IP from name: $host..."
  host=$(getent ahosts $host | head -n 1 | cut -d" " -f1)
fi

if [[ ! $host =~ ^([0-2]?[0-9]{1,2}\.){3}([0-2]?[0-9]{1,2})$ ]]; then
  die "Invalid hostname"
fi

mac=""

# read /etc/ethers line by line
while read line
do
  if [[ !(${line:0:1} == "#") && ( -n "$line" ) ]]; then
    ip=$(echo $line | cut -d" " -f2)
    addr=$(echo $line | cut -d" " -f1)

    if [[ $ip == $host ]]; then
      mac=$addr
      break
    fi
  fi
done < "/etc/ethers"

if [[ -z $mac ]]; then
  die "No MAC address asociated with that host!"
fi

wakeonlan $mac

exit 0