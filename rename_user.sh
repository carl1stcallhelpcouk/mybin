#!/usr/bin/env bash

usage ()
{
	me=`basename $0`
	echo "${me} [-f | --fromuser username] [-t | --touser username] [-i | --interactive] [-h | --help]"
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then
	DIR="$PWD";
fi

source "$DIR/lib/exit_codes.shinc"

echo "Your command line contains $# arguments."


interactive=false
fromuser=pi
touser=carl

while [ "$1" != "" ]; do
    case $1 in
        -f | --fromuser )	shift
				fromuser=$1
				;;
	-t | --touser )		shift
				touser=$1
				;;
        -i | --interactive )	interactive=true
				;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

echo "fromuser : ${fromuser}	touser : ${touser}	interactive : ${interactive}"

exit $EX_NOUSER

exit 1

id
cd /etc
sudo tar -cvf authfiles.tar passwd group shadow gshadow sudoers lightdm/lightdm.conf systemd/system/autologin@.service sudoers.d/* polkit-1/localauthority.conf.d/60-desktop-policy.conf
#sudo sed -i.$(date +'%y%m%d_%H%M%S') 's/\bpi\b/carl/g' passwd group shadow gshadow sudoers systemd/system/autologin@.service sudoers.d/* polkit-1/localauthority.conf.d/60-desktop-policy.conf
sudo sed -i.$(date +'%y%m%d_%H%M%S') 's/\bpi\b/carl/g' passwd group shadow gshadow sudoers systemd/system/autologin@.service sudoers.d/* polkit-1/localauthority.conf.d/60-desktop-policy.conf
#sudo sed -i.$(date +'%y%m%d_%H%M%S') 's/user=pi/user=carl/' lightdm/lightdm.conf
sudo sed -i.$(date +'%y%m%d_%H%M%S') 's/user=pi/user=carl/' lightdm/lightdm.conf
grep carl /etc/group
sudo mv /home/pi /home/carl
sudo ln -s /home/carl /home/pi
#sudo [ -f /var/spool/cron/crontabs/pi ] && sudo mv -v /var/spool/cron/crontabs/pi /var/spool/cron/crontabs/carl '/var/spool/cron/crontabs/pi' -> '/var/spool/cron/crontabs/carl'
ls -lah /var/spool/mail
ls -lah /var/spool/mail/




#	EX_USAGE -- The command was used incorrectly, e.g., with
#		the wrong number of arguments, a bad flag, a bad
#		syntax in a parameter, or whatever.
#	EX_DATAERR -- The input data was incorrect in some way.
#		This should only be used for user's data & not
#		system files.
#	EX_NOINPUT -- An input file (not a system file) did not
#		exist or was not readable.  This could also include
#		errors like "No message" to a mailer (if it cared
#		to catch it).
#	EX_NOUSER -- The user specified did not exist.  This might
#		be used for mail addresses or remote logins.
#	EX_NOHOST -- The host specified did not exist.  This is used
#		in mail addresses or network requests.
#	EX_UNAVAILABLE -- A service is unavailable.  This can occur
#		if a support program or file does not exist.  This
#		can also be used as a catchall message when something
#		you wanted to do doesn't work, but you don't know
#		why.
#	EX_SOFTWARE -- An internal software error has been detected.
#		This should be limited to non-operating system related
#		errors as possible.
#	EX_OSERR -- An operating system error has been detected.
#		This is intended to be used for such things as "cannot
#		fork", "cannot create pipe", or the like.  It includes
#		things like getuid returning a user that does not
#		exist in the passwd file.
#	EX_OSFILE -- Some system file (e.g., /etc/passwd, /etc/utmp,
#		etc.) does not exist, cannot be opened, or has some
#		sort of error (e.g., syntax error).
#	EX_CANTCREAT -- A (user specified) output file cannot be
#		created.
#	EX_IOERR -- An error occurred while doing I/O on some file.
#	EX_TEMPFAIL -- temporary failure, indicating something that
#		is not really an error.  In sendmail, this means
#		that a mailer (e.g.) could not create a connection,
#		and the request should be reattempted later.
#	EX_PROTOCOL -- the remote system returned something that
#		was "not possible" during a protocol exchange.
#	EX_NOPERM -- You did not have sufficient permission to
#		perform the operation.  This is not intended for
#		file system problems, which should use NOINPUT or
#		CANTCREAT, but rather for higher level permissions.

