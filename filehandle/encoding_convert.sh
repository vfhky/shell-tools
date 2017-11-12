#!/bin/bash

# Created by LEXO, https://www.lexo.ch/blog/2013/01/linux-bash-shell-script-for-recursively-converting-all-files-with-various-charsets-in-a-directory-into-utf-8-shell-skript-fur-das-rekursive-konvertieren-von-allen-files-in-einem-verzeichnis-mit-belie/
# Version 1.0
#
# This bash script converts all files from within a given directory from any charset to UTF-8 recursively
# It takes track of those files that cannot be converted automatically. Usually this happens when the original charset
# cannot be recognized. In that case you should load the corresponding file into a development editor like Netbeans
# or Komodo and apply the UTF-8 charset manually.
#
# This is free software. Use and distribute but do it at your own risk. 
# We will not take any responsibilities for failures and do not provide any support.

# Usage: encoding_convert.sh /home/vfhky/

#checking Parameters
if [ ! -n "$1" ] ; then
	echo "You did not supply any directory at the command line."
	echo "You need to provide the path to the directory that contains the files which you want to be converted"
	echo ""
	echo "Example: $0 /path/to/directory"
	echo ""
	echo "Important hint: You should not run this script from within the same directory where the files are stored"
	echo "that you want to convert right now."
        exit
fi

# This array contains file extensions that need to be checked no matter if the filetype is binary or not.
# Reason: Sometimes it happens that .htm(l), .php, .tpl files etc. have a binary charset type. This script
# does not convert binary file types into utf-8 because it might destroy your data. So we need to include these file types
# into the conversion system manually to tell the conversion that binary files with these special extensions may be converted anyway.
filestoconvert=(h hpp cpp c sh xml kshrc alias app cvs database unix ini bldar bldexe bldkit bldkitmod bldwrk bldwrkmod mak md )

# define colors
# default color
reset="\033[0;00m"
# Successful conversion (green)
success="\033[1;32m"
# No conversion needed (blue)
noconversion="\033[1;34m"
# file skipped because it's not mentioned in the filestoconvert array (white)
fileskipped="\033[1;37m"
# files that could not be converted aka error (red)
fileconverterror="\033[1;31m"

## function to convert all files in a directory recusrively
function convert {
#clear screen first
clear

dir=$1

# Get a recursive file list
files=(`find $dir -type f`);
fileerrors=""

#loop counter
i=0

find "$dir" -type f |while read inputfile
do
        if [ -f "$inputfile" ] ; then
                charset="$(file -bi "$inputfile"|awk -F "=" '{print $2}')"
                if [ "$charset" != "utf-8" ]; then
                        #if file extension is in filestoconvert variable the file will always be converted
                        filename=$(basename "$inputfile")
                        extension="${filename##*.}"
                        # If the current file has not an extension that is listed in the array $filestoconvert the current file is being skipped (no conversion occurs)
                        if in_array $extension "${filestoconvert[@]}" ; then
                                # create a tempfile and remember all of the current file permissions to be able to reapply those to the new converted file after conversion
                                tmp=$(mktemp)
                                owner=`ls -l "$inputfile" | awk '{ print $3 }'`
                                group=`ls -l "$inputfile" | awk '{ print $4 }'`
                                octalpermission=$( stat --format=%a "$inputfile" )
                                echo -e "$success $inputfile\t$charset\t->\tUTF-8 $reset"
                                iconv -f "$charset" -t utf8 "$inputfile" -o $tmp &>2
                                RETVAL=$?
                                if [ $RETVAL > 0 ] ; then
                                        # There was an error converting the file. Remember this and inform the user about the file not being converted at the end of the conversion process.
                                        fileerrors="$fileerrors\n$inputfile"
                                fi
                                mv "$tmp" "$inputfile"
                                #re-apply previous file permissions as well as user and group settings
                                chown $owner:$group "$inputfile"
                                chmod $octalpermission "$inputfile"
                        else
                                echo -e "$fileskipped $inputfile\t$charset\t->\tSkipped because its extension (.$extension) is not listed in the 'filestoconvert' array. $reset"
                        fi
                else
                        echo -e "$noconversion $inputfile\t$charset\t->\tNo conversion needed (file is already UTF-8) $reset"
                fi
	fi
        (( ++i ))
done
echo -e "$success Done! $reset"
echo -e ""
echo -e ""
if [ ! $fileerrors == "" ]; then
	echo -e "The following files had errors (origin charset not recognized) and need to be converted manually (e.g. by opening the file in an editor (IDE) like Komodo or Netbeans:"
	echo -e $fileconverterror$fileerrors$reset
fi
exit 0
} #end function convert()

# Check if a value exists in an array
# @param $1 mixed  Needle  
# @param $2 array  Haystack
# @return  Success (0) if value exists, Failure (1) otherwise} #end function in_array()
# Usage: in_array "$needle" "${haystack[@]}"
in_array() {
    local needle=$1
    local hay=$2
    shift
    for hay; do
#	echo "Hay: $hay , Needle: $needle"
        [[ $hay == $needle ]] && return 0
    done
    return 1
} #end function in_array

#start conversion
convert $1
