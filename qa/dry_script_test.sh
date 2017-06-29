#!/bin/bash

do_dry=0
do_verbose=0
duckfile=""

function usage() { echo "Usage: $0 [-d dryrun -h help -v verbose] <duckfile_to_execute>" 1>&2; exit 1; }

if [[ -z $1 ]]; then
    usage
fi

for duckfile; do true; done
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
 
(( do_dry )) && echo "#####dry mode#####"

myvar=55555

execute "ls ~/"
execute echo \"hello\"
execute echo $myvar
execute echo -e "\"$myvar\t\tRemote\n\n\tOK\""
echo $duckfile