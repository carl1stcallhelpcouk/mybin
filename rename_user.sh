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

isValidUsername() {
  local re='^[[:lower:]_][[:lower:][:digit:]_-]{1,15}$'
  (( ${#1} > 16 )) && return 1
  [[ $1 =~ $re ]] # return value of this comparison is used for the function
}

#
#   Main script
#
locate_script
source "$DIR/lib/exit_codes.shinc"

while [ "${1}" != "" ]; do    # Process commandline.
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

if [ "${verbose}" == true ] ; then
  echo "fromuser : ${from_user}	touser : ${to_user}	interactive : ${interactive} verbose : ${verbose}"
fi

if isValidUsername "${from_user}" ; then
  if [ "${verbose}" == true ] ; then
    echo "From user ${from_user} is Valid"
  fi
else
  echo "From user ${from_user} is invalid"
  exit ${EX_NOUSER}
fi

if isValidUsername "${to_user}" ; then
  if [ "${verbose}" == true ] ; then
    echo "To user ${to_user} is Valid"
  fi
else
  echo "To user ${to_user} is invalid"
  exit ${EX_NOUSER}
fi

if [ "${verbose}" == true ] ; then
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

if [ "${from_user_notexists}" == "0" ] ; then
  if [ "${verbose}" == true ] ; then
    echo "From User ${from_user} Exists (${from_user_notexists})"
  fi

  if [ ${from_user} == ${USER} ] ; then
    echo "Cannot rename the current user."
    exit ${EX_NOUSER}
  else
    if [ "${verbose}" == true ] ; then
      echo "From user ${from_user} differs from ${USER}"
    fi
  fi

else
  if [ "${verbose}" == true ] ; then
    echo "From User ${from_user} Does not exists (${from_user_notexists})"
  fi
  exit ${EX_NOUSER}
fi

if [ "${to_user_notexists}" == "0" ] ; then
  if [ "${verbose}" == true ] ; then
    echo "To User ${to_user} Exists (${to_user_notexists})"
  fi
  exit ${to_user_notexists}
else
  if [ "${verbose}" == true ] ; then
    echo "To User ${to_user} Does not exists (${to_user_notexists})"
  fi
fi

cd /etc
file_list1=($(ls -f passwd group shadow gshadow sudoers lightdm/lightdm.conf systemd/system/autologin@.service sudoers.d/* polkit-1/localauthority.conf.d/60-desktop-policy.conf))
file_list2=($(ls -f passwd group shadow gshadow sudoers systemd/system/autologin@.service sudoers.d/* polkit-1/localauthority.conf.d/60-desktop-policy.conf))
file_list3=($(ls -f lightdm/lightdm.conf))

echo "File list1 - ${file_list1[@]}" 
echo "File list2 - ${file_list2[@]}" 
echo "File list3 - ${file_list3[@]}" 

sudo tar -cvf authfiles.tar ${file_list1[@]}
tar_return=${?}
if [${tar_return} == 0] ; then
  if [ "${verbose}" == true ] ; then
    echo "tar backup of files sucsessful."
  fi
else
  echo "tar backup of files failed."
  exit ${tar_return}
fi

sudo sed -i.$(date +'%y%m%d_%H%M%S') "s/\b${from_user}\b/${to_user}/g" ${file_list2[@]}
sudo sed -i.$(date +'%y%m%d_%H%M%S') "s/user=${from_user}/user=${to_user}/" ${file_list3[@]}
sudo mv /home/${from_user} /home/${to_user}
sudo ln -s /home/$to_user /home/${from_user}
sudo [ -f /var/spool/cron/crontabs/${from_user} ] && sudo mv -v /var/spool/cron/crontabs/${from_user} /var/spool/cron/crontabs/${to_user} "/var/spool/cron/crontabs/${from_user}" -> "/var/spool/cron/crontabs/${to_user}"

exit ${EX_OK}