#!/bin/bash

# DroidDucky
# Simple Duckyscript interpreter in Bash. Based on android-keyboard-gadget and hid-gadget-test utility.
#
function usage() { echo "Usage: $0 [-h help -d dryrun -v verbose -k {us, fr}] -f <duckfile_to_execute>" 1>&2; exit 1; }
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
key_layout="us" #default layout
last_cmd=""
last_string=""
line_num=0

if [[ -z $1 ]]; then
    usage
fi

while getopts f:k:dhv opt
do
    case $opt in
    (f) duckfile=${OPTARG} ;;
    (d) do_dry=1 ;;
    (v) do_verbose=1 ;;
    (h) usage ;;
    (k) key_layout=${OPTARG} ;;
    (*) printf "Illegal option '-%s'\n" "$opt" && exit 1 ;;
    esac
done

function toAzerty(){
	#echo $1 | sed -e 'y/`123567890-=qwertyuiop[]asdfghjkl;\\êzxcvbnm,.\/~!@#$%^&*()_+QWERTYUIOP{}ASDFGHJKL:"|ÊZXCVBNM<>?/²&é"(-è_çà)=azertyuiop^$qsdfghjklm*<wxcvbn,;:!³1234567890°+AZERTYUIOP¨£QSDFGHJKLM%µ>WXCVBN?.\/§/' -e "y/4'/'ù/"
	echo $1 | sed -e 'y/qawzAQZW/aqzwQAWZ/' -e "y/m,;:!?.\/§()$\-\"M012345679/;m,.\/M<>?5-]63:)!@#$%^&(/" #-e "y/;m,.\/</m,;:!./"
} #function toAzerty

function toLayout(){
	case $key_layout in
	(us) echo "$1" ;;
	(fr) echo "$(toAzerty $1)" ;;
	esac
}

function execute(){
    # if dry run is enabled then simply return 
    (( do_dry && !do_verbose )) && echo "${@}"
    (( !do_dry && do_verbose )) && echo "#${@}"
     
    (( do_dry )) && return 0
        
    # if dry run is disabled, then execute the command
    eval "$@"
} #function execute()

function convert() {
	local kbcode=""
	
	singleCharacter="$1" # trick to keep '*' integrity.
	character="$(toLayout "$singleCharacter")"
	
	# echo "character before toLayout:$1"
	# echo "character:$character"
	if [ "$1" == " " ] #toLayout discards the space
	then
		kbcode='space'
	elif [ "$character" == "!" ]
	then
		kbcode='left-shift 1'
	elif [ "$character" == "." ]
	then
		kbcode='period'
		# [ "$key_layout" == "us" ] && kbcode='period'
		# [ "$key_layout" == "fr" ] && kbcode='left-shift comma'
	elif [ "$character" == "\`" ]
	then
		kbcode='backquote'
	elif [ "$character" == "~" ]
	then
		kbcode='left-shift tilde'
	elif [ "$character" == "+" ]
	then
		kbcode='kp-plus'
	elif [ "$character" == "=" ]
	then
		kbcode='equal'
	elif [ "$character" == "_" ]
	then
		kbcode='left-shift minus'
	elif [ "$character" == "-" ]
	then
		kbcode='minus'
	elif [ "$character" == "\"" ]
	then
		kbcode='left-shift quote'
	elif [ "$character" == "'" ]
	then
		kbcode='quote'
	elif [ "$character" == ":" ]
	then
		kbcode='left-shift semicolon'
	elif [ "$character" == ";" ]
	then
		kbcode='semicolon'
	elif [ "$character" == "<" ]
	then
		kbcode='left-shift comma'
	elif [ "$character" == "," ]
	then
		kbcode='comma'
	elif [ "$character" == ">" ]
	then
		kbcode='left-shift period'
	elif [ "$character" == "?" ]
	then
		kbcode='left-shift slash'
	elif [ "$character" == "\\" ]
	then
		kbcode='backslash'
	elif [ "$character" == "|" ]
	then
		kbcode='left-shift backslash'
	elif [ "$character" == "/" ]
	then
		kbcode='slash'
	elif [ "$character" == "{" ]
	then
		kbcode='left-shift lbracket'
	elif [ "$character" == "}" ]
	then
		kbcode='left-shift rbracket'
	elif [ "$character" == "(" ]
	then
		kbcode='left-shift 9'
	elif [ "$character" == ")" ]
	then
		kbcode='left-shift 0'
	elif [ "$character" == "[" ]
	then
		kbcode='lbracket'
	elif [ "$character" == "]" ]
	then
		kbcode='rbracket'
	elif [ "$character" == "#" ]
	then
		kbcode='left-shift 3'
	elif [ "$character" == "@" ]
	then
		kbcode='left-shift 2'
	elif [ "$character" == "$" ]
	then
		kbcode='left-shift 4'
	elif [ "$character" == "%" ]
	then
		kbcode='left-shift 5'
	elif [ "$character" == "^" ]
	then
		kbcode='left-shift 6'
	elif [ "$character" == "&" ]
	then
		kbcode='left-shift 7'
	elif [ "$character" == "*" ]
	then
		kbcode='kp-multiply'

	else
		case $character in
		[[:upper:]])
			tmp=$character
			kbcode="left-shift ${tmp,,}"
			;;
		*)
			kbcode="$character"
			;;
		esac
	fi

	echo "$kbcode"
} #function convert()

(( do_dry )) && echo "#####dry mode#####"
while IFS='' read -r line || [[ -n "$line" ]]; do
	((line_num++))
	read -r cmd info <<< "$line"
	if [ "$cmd" == "STRING" ] 
	then
		last_string="$info"
		last_cmd="$cmd"

		for ((  i=0; i<${#info}; i++  )); do
			#kbcode=$(toLayout $kbcode) #first convert . to : then convert : to left-shift comma
			kbcode=$(convert "${info:$i:1}")
			
			if [ "$kbcode" != "" ]
			then
				execute "echo $kbcode $pipe"
				#execute "echo $(toLayout $kbcode) $pipe"
			fi
		done
	elif [ "$cmd" == "ENTER" ] 
	then
		last_cmd="enter"
		execute "echo $last_cmd $pipe"
	
	elif [ "$cmd" == "DELAY" ] 
	then
		last_cmd="UNS"
		((info = info*1000))
		execute "usleep $info"

	elif [ "$cmd" == "WINDOWS" -o "$cmd" == "GUI" ] 
	then
		last_cmd="left-meta $(toLayout ${info,,})"
		execute "echo $last_cmd $pipe"

	elif [ "$cmd" == "MENU" -o "$cmd" == "APP" ] 
	then
		last_cmd="menu"
		execute "echo $last_cmd $pipe"

	elif [ "$cmd" == "DOWNARROW" -o "$cmd" == "DOWN" ] 
	then
		last_cmd="down"
		execute "echo $last_cmd $pipe"

	elif [ "$cmd" == "LEFTARROW" -o "$cmd" == "LEFT" ] 
	then
		last_cmd="left"
		execute "echo $last_cmd $pipe"

	elif [ "$cmd" == "RIGHTARROW" -o "$cmd" == "RIGHT" ] 
	then
		last_cmd="right"
		execute "echo $last_cmd $pipe"

	elif [ "$cmd" == "UPARROW" -o "$cmd" == "UP" ] 
	then
		last_cmd="up"
		execute "echo $last_cmd $pipe"

	elif [ "$cmd" == "DEFAULT_DELAY" -o "$cmd" == "DEFAULTDELAY" ] 
	then
		last_cmd="UNS"
		((defdelay = info*1000)) #todo

	elif [ "$cmd" == "BREAK" -o "$cmd" == "PAUSE" ] 
	then
		last_cmd="pause"
		execute "echo $last_cmd $pipe"

	elif [ "$cmd" == "ESC" -o "$cmd" == "ESCAPE" ] 
	then
		last_cmd="escape"
		execute "echo $last_cmd $pipe"

	elif [ "$cmd" == "PRINTSCREEN" ] 
	then
		last_cmd="print"
		execute "echo $last_cmd $pipe"

	elif [ "$cmd" == "CAPSLOCK" -o "$cmd" == "DELETE" -o "$cmd" == "END" -o "$cmd" == "HOME" -o "$cmd" == "INSERT" -o "$cmd" == "NUMLOCK" -o "$cmd" == "PAGEUP" -o "$cmd" == "PAGEDOWN" -o "$cmd" == "SCROLLLOCK" -o "$cmd" == "SPACE" -o "$cmd" == "TAB" \
	-o "$cmd" == "F1" -o "$cmd" == "F2" -o "$cmd" == "F3" -o "$cmd" == "F4" -o "$cmd" == "F5" -o "$cmd" == "F6" -o "$cmd" == "F7" -o "$cmd" == "F8" -o "$cmd" == "F9" -o "$cmd" == "F10" -o "$cmd" == "F11" -o "$cmd" == "F12" ] 
	then
		last_cmd="${cmd,,}"
		execute "echo $last_cmd $pipe"

	elif [ "$cmd" == "REM" ] 
	then
		#execute "echo $info"
		: #do nothing
	elif [ "$cmd" == "SHIFT" ] 
	then
		if [ "$info" == "DELETE" -o "$info" == "END" -o "$info" == "HOME" -o "$info" == "INSERT" -o "$info" == "PAGEUP" -o "$info" == "PAGEDOWN" -o "$info" == "SPACE" -o "$info" == "TAB" ] 
		then
			last_cmd="left-shift ${info,,}"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == *"WINDOWS"* -o "$info" == *"GUI"* ] 
		then
			read -r gui char <<< "$info"
			last_cmd="left-shift left-meta ${char,,}"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "DOWNARROW" -o "$info" == "DOWN" ] 
		then
			last_cmd="left-shift down"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "LEFTARROW" -o "$info" == "LEFT" ] 
		then
			last_cmd="left-shift left"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "RIGHTARROW" -o "$info" == "RIGHT" ] 
		then
			last_cmd="left-shift right"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "UPARROW" -o "$info" == "UP" ] 
		then
			last_cmd="left-shift up"
			execute "echo $last_cmd $pipe"

		else
			execute "echo ($line_num) Parse error: Disallowed $cmd $info"
		fi

	elif [ "$cmd" == "CONTROL" -o "$cmd" == "CTRL" ] 
	then
		if [ "$info" == "BREAK" -o "$info" == "PAUSE" ] 
		then
			last_cmd="left-ctrl pause"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-ctrl ${cmd,,}"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-ctrl escape"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "" ]
		then
			last_cmd="left-ctrl"
			execute "echo $last_cmd $pipe"

		else 
			last_cmd="left-ctrl ${info,,}"
			execute "echo $last_cmd $pipe"
		fi

	elif [ "$cmd" == "ALT" ] 
	then
		if [ "$info" == "END" -o "$info" == "SPACE" -o "$info" == "TAB" \
		-o "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-alt ${info,,}"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-alt escape"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "" ]
		then
			last_cmd="left-alt"
			execute "echo $last_cmd $pipe"

		else 
			last_cmd="left-alt ${info,,}"
			execute "echo $last_cmd $pipe"
		fi

	elif [ "$cmd" == "ALT-SHIFT" ] 
	then
		last_cmd="left-shift left-alt"
		execute "echo $last_cmd $pipe"

	elif [ "$cmd" == "CTRL-ALT" ] 
	then
		if [ "$info" == "BREAK" -o "$info" == "PAUSE" ] 
		then
			last_cmd="left-ctrl left-alt pause"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "END" -o "$info" == "SPACE" -o "$info" == "TAB" -o "$info" == "DELETE" -o "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-ctrl left-alt ${cmd,,}"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-ctrl left-alt escape"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "" ]
		then
			last_cmd="left-ctrl left-alt"
			execute "echo $last_cmd $pipe"

		else 
			last_cmd="left-ctrl left-alt ${info,,}"
			execute "echo $last_cmd $pipe"
		fi

	elif [ "$cmd" == "CTRL-SHIFT" ] 
	then
		if [ "$info" == "BREAK" -o "$info" == "PAUSE" ] 
		then
			last_cmd="left-ctrl left-shift pause"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "END" -o "$info" == "SPACE" -o "$info" == "TAB" -o "$info" == "DELETE" -o "$info" == "F1" -o "$info" == "F2" -o "$info" == "F3" -o "$info" == "F4" -o "$info" == "F5" -o "$info" == "F6" -o "$info" == "F7" -o "$info" == "F8" -o "$info" == "F9" -o "$info" == "F10" -o "$info" == "F11" -o "$info" == "F12" ] 
		then
			last_cmd="left-ctrl left-shift ${cmd,,}"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "ESC" -o "$info" == "ESCAPE" ] 
		then
			last_cmd="left-ctrl left-shift escape"
			execute "echo $last_cmd $pipe"

		elif [ "$info" == "" ]
		then
			last_cmd="left-ctrl left-shift"
			execute "echo $last_cmd $pipe"

		else 
			last_cmd="left-ctrl left-shift ${info,,}"
			execute "echo $last_cmd $pipe"
		fi

	elif [ "$cmd" == "REPEAT" ] 
	then
		if [ "$last_cmd" == "UNS" -o "$last_cmd" == "" ]
		then
			execute "echo ($line_num) Parse error: Using REPEAT with DELAY, DEFAULTDELAY or BLANK is not allowed."
		else
			for ((  i=0; i<$info; i++  )); do
				if [ "$last_cmd" == "STRING" ] 
				then
					for ((  j=0; j<${#last_string}; j++  )); do
						kbcode=$(convert "${last_string:$j:1}")

						if [ "$kbcode" != "" ]
						then
							execute "echo $kbcode $pipe"
						fi
					done
				else
					execute "echo $last_cmd $pipe"
				fi
				execute "usleep $defdelay"
			done
		fi

	elif [ "$cmd" != "" ] 
	then
		execute "echo ($line_num) Parse error: Unexpected $cmd."
	fi

	execute "usleep $defdelay"
done < "$duckfile"
