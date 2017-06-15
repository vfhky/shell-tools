#!/bin/bash
# FileName:      sedawkfindreplace1.sh
# Description:   Print all the date during the two days you inpute.
# Simple Usage:  ./alldateduringtwodays1.sh
# (c) 2017.6.15 vfhky https://typecodes.com/linux/alldateduringtwodays1.html
# https://github.com/vfhky/shell-tools/blob/master/datehandle/alldateduringtwodays1.sh


if [[ $# != 3 ]]; then
	echo "Usage: $0 2017-04-01 2017-06-14 -  or  $0 20170401 20170614 - ."
	exit 1
fi

start_day=$(date -d "$1" +%s)
end_day=$(date -d "$2" +%s)
# The spliter bettwen year, month and day.
SPLITER=${3}

while (( "${start_day}" <= "${end_day}" )); do
	day=$(date -d @${start_day} +"%Y${SPLITER}%m${SPLITER}%d")
	echo "Handing date=[${day}]."
	
	# We should use start_day other ${start_day} here.
	start_day=$((${start_day}+86400))
	
	#sleep 1
done
