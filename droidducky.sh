#!/bin/bash

# DroidDucky
# Simple Duckyscript interpreter in Bash. Based on android-keyboard-gadget and hid-gadget-test utility.
#
function usage() { echo "Usage: $0 [-d dryrun -h help -v verbose] <duckfile_to_execute>" 1>&2; exit 1; }
# Usage: droidducky.sh payload_file.dd
#
# Copyright (C) 2015 - Andrej Budinčević <andrew@hotmail.rs>
# Copyright (C) 2017 - Remy Chatti <rockeek@yahoo.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

do_dry=0
do_verbose=0
duckfile=""
defdelay=0
pipe="| ./hid-gadget-test /dev/hidg0 keyboard > /dev/null"
last_cmd=""
last_string=""
line_num=0

if [[ -z $1 ]]; then
    usage
fi
for duckfile; do true; done #get last argument

while getopts "dhv" opt
do
    case $opt in
    (d) do_dry=1 ;;
    (v) do_verbose=1 ;;
    (h) usage ;;
    (*) printf "Illegal option '-%s'\n" "$opt" && exit 1 ;;
    esac
done

function execute(){
    # if dry run is enabled then simply return 
    (( do_dry && !do_verbose )) && echo "${@}"
    (( !do_dry && do_verbose )) && echo "#${@}"
     
    (( do_dry )) && return 0
        
    # if dry run is disabled, then execute the command
    eval "$@"
}

function convert() 
{
	local kbcode=""

	if [ "$1" == " " ]
	then
		kbcode='space'
	elif [ "$1" == "!" ]
	then
		kbcode='left-shift 1'
	elif [ "$1" == "." ]
	then
		kbcode='period'
	elif [ "$1" == "\`" ]
	then
		kbcode='backquote'
	elif [ "$1" == "~" ]
	then
		kbcode='left-shift tilde'
	elif [ "$1" == "+" ]
	then
		kbcode='kp-plus'
	elif [ "$1" == "=" ]
	then
		kbcode='equal'
	elif [ "$1" == "_" ]
	then
		kbcode='left-shift minus'
	elif [ "$1" == "-" ]
	then
		kbcode='minus'
	elif [ "$1" == "\"" ]
	then
		kbcode='left-shift quote'
	elif [ "$1" == "'" ]
	then
		kbcode='quote'
	elif [ "$1" == ":" ]
	then
		kbcode='left-shift semicolon'
	elif [ "$1" == ";" ]
	then
		kbcode='semicolon'
	elif [ "$1" == "<" ]
	then
		kbcode='left-shift comma'
	elif [ "$1" == "," ]
	then
		kbcode='comma'
	elif [ "$1" == ">" ]
	then
		kbcode='left-shift period'
	elif [ "$1" == "?" ]
	then
		kbcode='left-shift slash'
	elif [ "$1" == "\\" ]
	then
		kbcode='backslash'
	elif [ "$1" == "|" ]
	then
		kbcode='left-shift backslash'
	elif [ "$1" == "/" ]
	then
		kbcode='slash'
	elif [ "$1" == "{" ]
	then
		kbcode='left-shift lbracket'
	elif [ "$1" == "}" ]
	then
		kbcode='left-shift rbracket'
	elif [ "$1" == "(" ]
	then
		kbcode='left-shift 9'
	elif [ "$1" == ")" ]
	then
		kbcode='left-shift 0'
	elif [ "$1" == "[" ]
	then
		kbcode='lbracket'
	elif [ "$1" == "]" ]
	then
		kbcode='rbracket'
	elif [ "$1" == "#" ]
	then
		kbcode='left-shift 3'
	elif [ "$1" == "@" ]
	then
		kbcode='left-shift 2'
	elif [ "$1" == "$" ]
	then
		kbcode='left-shift 4'
	elif [ "$1" == "%" ]
	then
		kbcode='left-shift 5'
	elif [ "$1" == "^" ]
	then
		kbcode='left-shift 6'
	elif [ "$1" == "&" ]
	then
		kbcode='left-shift 7'
	elif [ "$1" == "*" ]
	then
		kbcode='kp-multiply'

	else
		case $1 in
		[[:upper:]])
			tmp=$1
			kbcode="left-shift ${tmp,,}"
			;;
		*)
			kbcode="$1"
			;;
		esac
	fi

	echo "$kbcode"
} #function execute()


(( do_dry )) && echo "#####dry mode#####"
while IFS='' read -r line || [[ -n "$line" ]]; do
	((line_num++))
	read -r cmd info <<< "$line"
	if [ "$cmd" == "STRING" ] 
	then
		last_string="$info"
		last_cmd="$cmd"

		for ((  i=0; i<${#info}; i++  )); do
			kbcode=$(convert "${info:$i:1}")

			if [ "$kbcode" != "" ]
			then
				execute "$kbcode $pipe"
			fi
		done
	elif [ "$cmd" == "ENTER" ] 
	then
		last_cmd="enter"
		execute "$last_cmd $pipe"
	
	elif [ "$cmd" == "DELAY" ] 
	then
		last_cmd="UNS"
		((info = info*1000))
		execute "usleep $info"

	elif [ "$cmd" == "WINDOWS" -o "$cmd" == "GUI" ] 
	then
		last_cmd="left-meta ${info,,}"
		execute "$last_cmd $pipe"

	elif [ "$cmd" == "MENU" -o "$cmd" == "APP" ] 
	then
		last_cmd="menu"
		execute "$last_cmd $pipe"

	elif [ "$cmd" == "DOWNARROW" -o "$cmd" == "DOWN" ] 
	then
		last_cmd="down"
		execute "$last_cmd $pipe"

	elif [ "$cmd" == "LEFTARROW" -o "$cmd" == "LEFT" ] 
	then
		last_cmd="left"
		execute "$last_cmd $pipe"

	elif [ "$cmd" == "RIGHTARROW" -o "$cmd" == "RIGHT" ] 
	then
		last_cmd="right"
		execute "$last_cmd $pipe"

	elif [ "$cmd" == "UPARROW" -o "$cmd" == "UP" ] 
	then
		last_cmd="up"
		execute "$last_cmd $pipe"

	elif [ "$cmd" == "DEFAULT_DELAY" -o "$cmd" == "DEFAULTDELAY" ] 
	then
		last_cmd="UNS"
		((defdelay = info*1000)) #todo

	elif [ "$cmd" == "BREAK" -o "$cmd" == "PAUSE" ] 
	then
		last_cmd="pause"
		execute "$last_cmd $pipe"

	elif [ "$cmd" == "ESC" -o "$cmd" == "ESCAPE" ] 
	then
		last_cmd="escape"
		execute "$last_cmd $pipe"

	elif [ "$cmd" == "PRINTSCREEN" ] 
	then
		last_cmd="print"
		execute "$last_cmd $pipe"

	elif [ "$cmd" == "CAPSLOCK" -o "$cmd" == "DELETE" -o "$cmd" == "END" -o "$cmd" == "HOME" -o "$cmd" == "INSERT" -o "$cmd" == "NUMLOCK" -o "$cmd" == "PAGEUP" -o "$cmd" == "PAGEDOWN" -o "$cmd" == "SCROLLLOCK" -o "$cmd" == "SPACE" -o "$cmd" == "TAB" \
	-o "$cmd" == "F1" -o "$cmd" == "F2" -o "$cmd" == "F3" -o "$cmd" == "F4" -o "$cmd" == "F5" -o "$cmd" == "F6" -o "$cmd" == "F7" -o "$cmd" == "F8" -o "$cmd" == "F9" -o "$cmd" == "F10" -o "$cmd" == "F11" -o "$cmd" == "F12" ] 
	then
		last_cmd="${cmd,,}"
		execute "$last_cmd $pipe"

	elif [ "$cmd" == "REM" ] 
	then
		execute "$info"

	elif [ "$cmd" == "SHIFT" ] 
	then
		if [ "$info" == "DELETE" -o "$info" == "END" -o "$info" == "HOME" -o "$info" == "INSERT" -o "$info" == "PAGEUP" -o "$info" == "PAGEDOWN" -o "$info" == "SPACE" -o "$info" == "TAB" ] 
		then
			last_cmd="left-shift ${info,,}"
			execute "$last_cmd $pipe"

		elif [ "$info" == *"WINDOWS"* -o "$info" == *"GUI"* ] 
		then
			read -r gui char <<< "$info"
			last_cmd="left-shift left-meta ${char,,}"
			execute "$last_cmd $pipe"

		elif [ "$info" == "DOWNARROW" -o "$info" == "DOWN" ] 
		then
			last_cmd="left-shift down"
			execute "$last_cmd $pipe"

		elif [ "$info" == "LEFTARROW" -o "$info" == "LEFT" ] 
		then
			last_cmd="left-shift left"
			execute "$last_cmd $pipe"

		elif [ "$info" == "RIGHTARROW" -o "$info" == "RIGHT" ] 
		then
			last_cmd="left-shift right"
			execute "$last_cmd $pipe"

		elif [ "$info" == "UPARROW" -o "$info" == "UP" ] 
		then
			last_cmd="left-shift up"
			execute "$last_cmd $pipe"

		else
			execute "($line_num) Parse error: Disallowed $cmd $info"
		fi

	elif [ "$cmd" == "CONTROL" -o "$cmd" == "CTRL" ] 
	then
		if [ "$info" == "BREAK" -o "$info" == "PAUSE" ] 
		then
			last_cmd="left-ctrl pause"
			execute "$last_cmd $pipe"

		elif [ "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-ctrl ${cmd,,}"
			execute "$last_cmd $pipe"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-ctrl escape"
			execute "$last_cmd $pipe"

		elif [ "$info" == "" ]
		then
			last_cmd="left-ctrl"
			execute "$last_cmd $pipe"

		else 
			last_cmd="left-ctrl ${info,,}"
			execute "$last_cmd $pipe"
		fi

	elif [ "$cmd" == "ALT" ] 
	then
		if [ "$info" == "END" -o "$info" == "SPACE" -o "$info" == "TAB" \
		-o "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-alt ${info,,}"
			execute "$last_cmd $pipe"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-alt escape"
			execute "$last_cmd $pipe"

		elif [ "$info" == "" ]
		then
			last_cmd="left-alt"
			execute "$last_cmd $pipe"

		else 
			last_cmd="left-alt ${info,,}"
			execute "$last_cmd $pipe"
		fi

	elif [ "$cmd" == "ALT-SHIFT" ] 
	then
		last_cmd="left-shift left-alt"
		execute "$last_cmd $pipe"

	elif [ "$cmd" == "CTRL-ALT" ] 
	then
		if [ "$info" == "BREAK" -o "$info" == "PAUSE" ] 
		then
			last_cmd="left-ctrl left-alt pause"
			execute "$last_cmd $pipe"

		elif [ "$info" == "END" -o "$info" == "SPACE" -o "$info" == "TAB" -o "$info" == "DELETE" -o "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-ctrl left-alt ${cmd,,}"
			execute "$last_cmd $pipe"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-ctrl left-alt escape"
			execute "$last_cmd $pipe"

		elif [ "$info" == "" ]
		then
			last_cmd="left-ctrl left-alt"
			execute "$last_cmd $pipe"

		else 
			last_cmd="left-ctrl left-alt ${info,,}"
			execute "$last_cmd $pipe"
		fi

	elif [ "$cmd" == "CTRL-SHIFT" ] 
	then
		if [ "$info" == "BREAK" -o "$info" == "PAUSE" ] 
		then
			last_cmd="left-ctrl left-shift pause"
			execute "$last_cmd $pipe"

		elif [ "$info" == "END" -o "$info" == "SPACE" -o "$info" == "TAB" -o "$info" == "DELETE" -o "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-ctrl left-shift ${cmd,,}"
			execute "$last_cmd $pipe"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-ctrl left-shift escape"
			execute "$last_cmd $pipe"

		elif [ "$info" == "" ]
		then
			last_cmd="left-ctrl left-shift"
			execute "$last_cmd $pipe"

		else 
			last_cmd="left-ctrl left-shift ${info,,}"
			execute "$last_cmd $pipe"
		fi

	elif [ "$cmd" == "REPEAT" ] 
	then
		if [ "$last_cmd" == "UNS" -o "$last_cmd" == "" ]
		then
			execute "($line_num) Parse error: Using REPEAT with DELAY, DEFAULTDELAY or BLANK is not allowed."
		else
			for ((  i=0; i<$info; i++  )); do
				if [ "$last_cmd" == "STRING" ] 
				then
					for ((  j=0; j<${#last_string}; j++  )); do
						kbcode=$(convert "${last_string:$j:1}")

						if [ "$kbcode" != "" ]
						then
							execute "$kbcode $pipe"
						fi
					done
				else
					execute "$last_cmd $pipe"
				fi
				execute "usleep $defdelay"
			done
		fi

	elif [ "$cmd" != "" ] 
	then
		execute "($line_num) Parse error: Unexpected $cmd."
	fi

	execute usleep $defdelay
done < "$duckfile"