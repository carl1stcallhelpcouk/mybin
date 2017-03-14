#!/bin/bash
#
# Send <stdin> to email
#
# PARAMITERS    ${1}    to email
#               ${2}    from email
#		${3}	Subject
#               <stdin> mail message
#

#mutt -e "my_hdr From:${2}" -e "set content_type=text/html" -s "${3}" "${1}"
#sendmail -f ${2}" -s${3} ${1}
mutt -e "my_hdr From:${2}" -e "set content_type=text/html" "${1}" -s "${3}"
