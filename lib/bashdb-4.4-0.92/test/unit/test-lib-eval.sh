#!/bin/bash
# -*- shell-script -*-

test_eval_subst()
{
    # Set up necessary vars
    typeset extracted
    typeset -a texts
    texts=(
	'if (( x == 1 )); then'
	'if (( y == 2 )) ; then'
	'if (( y == 3 )) ;'
	'if (( y == 4 ))'
	'if (( z == 5 ))   '
	'return something'
	'elif [[ $x = test1 ]] && [ $? -eq 0 ] ; then'
	'while [[ $x = test2 ]] && [ $? -eq 0 ] ; do'
	'while [[ $x = test3 ]] && [ $? -eq 0 ]'
    )
    
    expected=(
	'(( x == 1 ))'
	'(( y == 2 )) '
	'(( y == 3 )) '
	'(( y == 4 ))'
	'(( z == 5 ))   '
	'echo something'
	'[[ $x = test1 ]] && [ $? -eq 0 ] '
	'[[ $x = test2 ]] && [ $? -eq 0 ] '
	'[[ $x = test3 ]] && [ $? -eq 0 ]'
    )
    typeset -i i
    for (( i=0 ; i<${#expected[@]}; i++ )) ; do
	_Dbg_eval_extract_condition "${texts[i]}"
	assertEquals "${expected[i]}" "$extracted"
    done
    assign='foo=bar'
    pat='^[ \t]*[A-Za-z_][A-Za-z_0-9[]*[]-+]?=(.*$)'
    if [[ $assign =~ $pat ]] ; then
	texts=(
	    'x=10'
	    'array[1]=20'
	    '__fn__+=30'
	    'PROFILES="/etc/apparmor.d"'
	)

	expected=(
	    'echo 10'
	    'echo 20'
	    'echo 30'
	    'echo "/etc/apparmor.d"'
	)
	for (( i=0 ; i<${#expected[@]}; i++ )) ; do
	    _Dbg_eval_extract_condition "${texts[i]}"
	    assertEquals "${expected[i]}" "$extracted"
	done
    fi
}

abs_top_srcdir=/home/carl/bin/lib/bashdb-4.4-0.92
# Make sure $abs_top_srcrdir has a trailing slash
abs_top_srcdir=${abs_top_srcdir%%/}/
. ${abs_top_srcdir}test/unit/helper.sh
. ${abs_top_srcdir}lib/fns.sh
set -- # reset $# so shunit2 doesn't get confused.
[[ $0 == ${BASH_SOURCE} ]] && . ${shunit_file}
