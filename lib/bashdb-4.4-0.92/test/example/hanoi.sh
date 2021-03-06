#!/bin/bash
# Towers of Hanoi
# We've added calls to set line tracing if the 1st argument is "trace"

init() {
    # We want to test _Dbg_set_trace inside a call
    if (( $tracing )) ; then
	_Dbg_linetrace_on
    fi
}

hanoi() { 
  typeset -i n=$1
  # Mul
  # _Dbg_set_trace
  typeset -r a=$2
  typeset -r b=$3
  typeset -r c=$4
  if (( n > 0 )) ; then
    (( n-- ))
    hanoi $n $a $c $b
    ((disc_num=max-n))
    echo "Move disk $n on $a to $b"
    if (( n > 0 )) ; then
       hanoi $n $c $b $a
    fi
  fi
}

typeset -i max=3
typeset -i tracing=0
if [[ "$1" = 'trace' ]] ; then
  if [[ -n $2 ]] ; then
      abs_top_builddir=$2
  elif [[ -z $builddir ]] ; then
      abs_top_builddir=/home/carl/bin/lib/bashdb-4.4-0.92
  fi
  tracing=1
  source ${abs_top_builddir}/bashdb-trace -B -q -L ${abs_top_srcdir} -x ${abs_top_srcdir}/test/data/settrace.cmd
fi
init
hanoi $max "a" "b" "c"
if (( $tracing )) ; then
  _Dbg_linetrace_off
  _Dbg_QUIT_ON_QUIT=1
fi
