#!/bin/bash
# $Id: interrupt.sh.in,v 1.4 2008/09/27 14:54:48 rockyb Exp $

if test -z "$srcdir"  ; then
  srcdir=`pwd`
fi

if [[ linux-gnu == cygwin ]] ; then
   cat ${srcdir}/interrupt.right
   exit 77
fi

# Make sure ../.. has a trailing slash
if [ '../..' = '' ] ; then
  echo "Something is wrong top_builddir is not set."
 exit 1
fi
top_builddir=../..
top_builddir=${top_builddir%%/}/
source ${top_builddir}bashdb-trace --no-init -q -B -L ../..

## FIXME
## _Dbg_handler INT
## echo "print: " ${_Dbg_sig_print[2]}
## echo "stop: " ${_Dbg_sig_stop[2]}

_Dbg_QUIT_ON_QUIT=1
for i in {0,1,2,3,4,5,6,7,9,9}{0,1,2,3,4,5,6,7,8,9} ; do
   touch $1
   sleep 5
done
