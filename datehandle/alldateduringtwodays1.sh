#!/bin/bash
# FileName:      sedawkfindreplace1.sh
# Description:   Print all the date during the two days you inpute.
# Simple Usage:  ./alldateduringtwodays1.sh
# (c) 2017.6.15 vfhky https://typecodes.com/linux/alldateduringtwodays1.html
# https://github.com/vfhky/shell-tools/blob/master/datehandle/alldateduringtwodays1.sh


if [[ $# -le 2 || $# -gt 3 ]]; then
	echo "Usage: $0 2017-04-01 2017-06-14 [-]  or  $0 20170401 20170614 [-] ."
	exit 1
fi

START_DAY=$(date -d "$1" +%s)
END_DAY=$(date -d "$2" +%s)
# The spliter bettwen year, month and day.
SPLITER=${3}


# Declare an array to store all the date during the two days you inpute.
declare -a DATE_ARRAY


function genAlldate
{
	if [[ $# -ne 3 ]]; then
		echo "Usage: genAlldate 2017-04-01 2017-06-14 [-]  or  genAlldate 20170401 20170614 [-] ."
		exit 1
	fi
	
	START_DAY_TMP=${1}
	END_DAY_TMP=${2}
	SPLITER_TMP=${3}
	I_DATE_ARRAY_INDX=0
	
	# while [[ "${START_DAY}" -le "${END_DAY}" ]]; do
	while (( "${START_DAY_TMP}" <= "${END_DAY_TMP}" )); do
		cur_day=$(date -d @${START_DAY_TMP} +"%Y${SPLITER_TMP}%m${SPLITER_TMP}%d")
		DATE_ARRAY[${I_DATE_ARRAY_INDX}]=${cur_day}
		
		# We should use START_DAY_TMP other ${START_DAY_TMP} here.
		START_DAY_TMP=$((${START_DAY_TMP}+86400))
		((I_DATE_ARRAY_INDX++))
		
		#sleep 1
	done
}

# Call the funciotn to generate date during the two days you inpute.
genAlldate "${START_DAY}" "${END_DAY}" "${SPLITER}"


# [Method 1] Traverse the array.
echo -e "[Method 1] Traverse the array."
for SINGLE_DAY in ${DATE_ARRAY[@]};
do
	echo ${SINGLE_DAY}
done


# [Method 2] Traverse the array.
echo -e "\n[Method 2] Traverse the array."
for i in "${!DATE_ARRAY[@]}"; do 
    printf "%s\t%s\n" "$i" "${DATE_ARRAY[$i]}"
done


# [Method 3] Traverse the array.
echo -e "\n[Method 3] Traverse the array."
i=0
while [ $i -lt ${#DATE_ARRAY[@]} ]
do
    echo ${DATE_ARRAY[$i]}
    let i++
done

# If you do not need this array any more, you can unset it.
# unset DATE_ARRAY

exit 0
