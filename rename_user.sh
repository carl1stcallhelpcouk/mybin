#!/usr/bin/env bash
#set -exv
PS4='$LINENO: '

script_name=`basename $0`       # Find the script name.

#
#   Set default values 
#
verbose=false                   # Display verbosly.
interactive=false               # Run interactivly.
from_user="pi"                  # User to rename.
to_user=""                      # Username to raname to.

script_name=`basename $0`     # Find the script name.

#
#   Define functions
#
show_usage ()                   # Display the usage instuctions
{
	printf "%s: %s\n" "${script_name}" "${script_name} [-h | --help] [-v | --verbose ] [-i | --interactive] [ -f | --fromuser username] [-t | --touser username]"
  return ${EX_USAGE}
}

show_help ()
{
  show_usage
  cat <<ENDOFHELP
    Renames a user.

    Options:
      -v | --verbose                Display verbosly.
      -i | --interactive            Run interactivly.
      -f | --fromuser username      Username to rename from (Defaults to 'pi').
      -t | --touser username        Username to raname to (required).
      -h | --help                   Display this help.

ENDOFHELP

  return ${EX_USAGE}
}

locate_script ()                # Locate the script path.
{
  DIR="${BASH_SOURCE%/*}"

  if [[ ! -d "$DIR" ]]; then
	  DIR="${PWD}";
  fi

  return ${EX_OK}
}

#
#   Main script
#
locate_script
source "$DIR/lib/exit_codes.shinc"

while [ "${1}" != "" ]; do
    case ${1} in
      -v | --verbose )
        verbose=true
        ;;
      -f | --fromuser )	shift
				from_user=${1}
				;;
	    -t | --touser )		shift
				to_user=${1}
				;;
      -i | --interactive )	
        interactive=true
				;;
      -h | --help )
        show_help
        exit ${EX_OK}
        ;;
      * )
        show_usage
        exit ${EX_DATAERR}
    esac
    shift
done

if [ "${verbose}" == true ]
then
  echo "fromuser : ${from_user}	touser : ${to_user}	interactive : ${interactive} verbose : ${verbose}"
fi

if [ "${verbose}" == true ]
then
  id "${from_user}" 
  from_user_notexists=${?}
  id "${to_user}"
  to_user_notexists=${?}
else
  id "${from_user}"> /dev/null 2>&1
  from_user_notexists=${?}
  id "${to_user}"> /dev/null 2>&1
  to_user_notexists=${?}
fi
echo $from_user_notexists
if [ "${from_user_notexists}" == "0" ]
then

  if [ "${verbose}" == true ]
  then
    echo "User ${from_user} Exists (${from_user_notexists})"
  fi
#  exit ${EX_OK}

else
  if [ "${verbose}" == true ]
  then
    echo "User ${from_user} Does not exists (${from_user_notexists})"
  fi
  exit ${EX_NOUSER}
fi

if [ "${to_user_notexists}" == "0" ]
then

  if [ "${verbose}" == true ]
  then
    echo "User ${to_user} Exists (${to_user_notexists})"
  fi
  exit ${to_user_notexists}

else
  if [ "${verbose}" == true ]
  then
    echo "User ${to_user} Does not exists (${to_user_notexists})"
  fi
#  exit ${EX_OK}
fi
cd /etc
file_list1=($(ls -f authfiles.tar passwd group shadow gshadow sudoers lightdm/lightdm.conf systemd/system/autologin@.service sudoers.d/* polkit-1/localauthority.conf.d/60-desktop-policy.conf))
echo "File list - ${file_list1[@]}" 
tar -cvf ~/authfiles.tar ${file_list1[@]}
exit ${?}


  exit 1





tar -cvf authfiles.tar passwd group shadow gshadow sudoers lightdm/lightdm.conf systemd/system/autologin@.service sudoers.d/* polkit-1/localauthority.conf.d/60-desktop-policy.conf
#sudo sed -i.$(date +'%y%m%d_%H%M%S') 's/\bpi\b/carl/g' passwd group shadow gshadow sudoers systemd/system/autologin@.service sudoers.d/* polkit-1/localauthority.conf.d/60-desktop-policy.conf
#sudo sed -i.$(date +'%y%m%d_%H%M%S') 's/\bpi\b/carl/g' passwd group shadow gshadow sudoers systemd/system/autologin@.service sudoers.d/* polkit-1/localauthority.conf.d/60-desktop-policy.conf
#sudo sed -i.$(date +'%y%m%d_%H%M%S') 's/user=pi/user=carl/' lightdm/lightdm.conf
#sudo sed -i.$(date +'%y%m%d_%H%M%S') 's/user=pi/user=carl/' lightdm/lightdm.conf
#grep carl /etc/group
#sudo mv /home/pi /home/carl
#sudo ln -s /home/carl /home/pi
#sudo [ -f /var/spool/cron/crontabs/pi ] && sudo mv -v /var/spool/cron/crontabs/pi /var/spool/cron/crontabs/carl '/var/spool/cron/crontabs/pi' -> '/var/spool/cron/crontabs/carl'
#ls -lah /var/spool/mail
#ls -lah /var/spool/mail/




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

