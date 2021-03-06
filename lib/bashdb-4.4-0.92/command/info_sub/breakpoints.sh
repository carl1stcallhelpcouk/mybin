# -*- shell-script -*-
# "info breakpoints" debugger command
#
#   Copyright (C) 2010-2012 Rocky Bernstein <rocky@gnu.org>
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

_Dbg_help_add_sub info breakpoints \
"info breakpoints

Show status of user-settable breakpoints. If no breakpoint numbers are
given, the show all breakpoints. Otherwise only those breakpoints
listed are shown and the order given. 

The \"Disp\" column contains one of \"keep\", \"del\", the disposition of
the breakpoint after it gets hit.

The \"enb\" column indicates whether the breakpoint is enabled.

The \"Where\" column indicates where the breakpoint is located.
Info whether use short filenames

See also \"break\", \"enable\", and \"disable\"." 1

# list breakpoints and break condition.
# If $1 is given just list those associated for that line.
_Dbg_do_info_breakpoints() {
    _Dbg_do_list_brkpt $@
    return $?
}
