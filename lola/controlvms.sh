#!/bin/bash

if [ "${HOSTNAME}" != "dell-server" ] ; then

    echo "Running 'ssh dell-server ${0} ${@}'"
    ssh dell-server "${0} ${@}"
    exit 0

fi

declare -ar vms=( nas gw mysql mail www )

start ()
{

	if [ -x /usr/bin/vboxheadless ] ; then

		for vm in "${vms[@]}" ; do

			rm "${HOME}/${vm}.log "${HOME}/${vm}con.log > /dev/null 2>&1
			echo "Starting ${vm} VM..." | tee "${HOME}/${vm}.log"
			/usr/bin/vboxheadless --vrde off --startvm "${vm}" 2>&1 >> "${HOME}/${vm}.log" &
			printf "Waiting for console tty to become available (/tmp/vm${vm}con)."
			while [ ! -e /tmp/vm${vm}con ] ; do printf "." ; sleep 0.5 ; done
			socat UNIX-CONNECT:"/tmp/vm${vm}con" PTY,link="/tmp/vm${vm}con-pty" 2>&1 >> "${HOME}/${vm}.log" &
			while [ ! -e /tmp/vm${vm}con-pty ] ; do printf "+" ; sleep 1 ; done
#			ttylog -b 115200 -d /tmp/vm${vm}con-pty > "${HOME}/${vm}con.log" &
			echo ""

		done

	else

		echo "VirtualBox Not Installed !!!" >&2
		exit 1

	fi

}

reset ()
{
	if [ -x /usr/bin/vboxheadless ] ; then

		for vm in "${vms[@]}" ; do

			echo "Resetting ${vm} VM..." | tee -a "${HOME}/${vm}.log"
			/usr/bin/vboxmanage controlvm ${vm} reset | tee -a "${HOME}/${vm}.log" 2>&1

		done

	else

		echo "VirtualBox Not Installed !!!" >&2
		exit 1

	fi

}

save ()
{
	if [ -x /usr/bin/vboxheadless ] ; then

		for ((i=${#vms[@]}-1; i>=0; i--)); do

			vm="${vms[${i}]}"
			echo "Saving State of ${vm} VM..." | tee -a "${HOME}/${vm}.log"
			/usr/bin/vboxmanage controlvm "${vm}" savestate | tee -a "${HOME}/${vm}.log" 2>&1
			printf "Waiting for console tty to become unavailable (/tmp/vm${vm}con)."
			while [ -e "/tmp/vm${vm}con" ] ; do printf "." ; sleep 1 ; done
			echo ""

		done

	else

		echo "VirtualBox Not Installed !!!" >&2
		exit 1

	fi
}

shutdown ()
{

	if [ -x /usr/bin/vboxheadless ] ; then

		for ((i=${#vms[@]}-1; i>=0; i--)); do

			vm="${vms[${i}]}"
			echo "Stoping ${vm} VM..." | tee -a "${HOME}/${vm}.log"
			/usr/bin/vboxmanage controlvm ${vm} acpipowerbutton | tee -a "${HOME}/${vm}.log" 2>&1
			printf "Waiting for console tty to become unavailable (/tmp/vm${vm}con)."
			while [ -e "/tmp/vm${vm}con" ] ; do printf "." ; sleep 1 ; done
			echo ""
		done

	else

		echo "VirtualBox Not Installed !!!" >&2
		exit 1

	fi

}

if [ "${1}" == "start" ] ; then

	start

elif [ "${1}" == "shutdown" ] ; then

	shutdown

elif [ "${1}" == "reset" ] ; then

	reset

elif [ "${1}" == "save" ] ; then

	save

elif [ "${1}" == "restart" ] ; then

	shutdown
	sleep 5
	start

else

	echo "$0 $1 not understood!!!" >&2
	echo "USAGE: $0 --start | --save | --shutdown | --reset" >&2
	exit 1

fi
exit 0