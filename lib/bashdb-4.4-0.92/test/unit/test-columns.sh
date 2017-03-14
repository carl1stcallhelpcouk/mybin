#!/bin/bash
# -*- shell-script -*-
test_columnized()
{
    do_one() {
	typeset cols="$1"
	shift
	typeset last_line="$1"
	shift
	typeset -a columnized
	typeset -a list
	eval "list=($1)"
	if (($# == 3)) ; then
	    columnize "$2" "$3"
	else
	    columnize "$2"
	fi
	typeset size=${#columnized[@]}
# 	typeset -i i
# 	for ((i=0; i<${#columnized[@]}; i++)) ; do 
# 	    print "  ${columnized[i]}"
# 	done
	assertEquals "$cols" "$size"
	assertEquals "$last_line" "${columnized[$size-1]}"
    }
    do_one 1 '<empty>' '' 
    do_one 1 'a,2,c' 'a 2 c' 10 ','
    do_one 4 'for    8  ' \
' 1   two three
  for 5   six
  7   8' 12

    do_one 3 '3    six' \
' 1   two 3
  for 5   six
  7   8' 12


}

if [ '/home/carl/bin/lib/bashdb-4.4-0.92' = '' ] ; then
  echo "Something is wrong abs_top_srcdir is not set."
 exit 1
fi
abs_top_srcdir=/home/carl/bin/lib/bashdb-4.4-0.92
# Make sure $abs_top_srcrdir has a trailing slash
abs_top_srcdir=${abs_top_srcdir%%/}/
. ${abs_top_srcdir}test/unit/helper.sh
. $abs_top_srcdir/lib/columnize.sh

set -- # reset $# so shunit2 doesn't get confused.
[[ $0 == ${BASH_SOURCE} ]] && . ${shunit_file}
