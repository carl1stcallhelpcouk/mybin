#!/bin/bash
# $Id: bug-args.sh.in,v 1.1 2008/08/19 21:23:26 rockyb Exp $
echo First parm is: $1
set a b c d e
shift 2
# At this point we shouldn't have a $5 or a $4
exit 0
