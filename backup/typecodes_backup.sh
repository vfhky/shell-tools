#!/bin/bash
# Blog Program Backup Script v1.0.0(applying to backup any linux directory or files)
# (c) 2015 vfhky https://typecodes.com/linux/centos7blogregularbackup.html
# https://github.com/vfhky/shell-tools/blob/master/backup/typcodes-backup.sh
# https://coding.net/u/vfhky/p/shell-tools/git/blob/master/backup/typcodes-backup.sh

# Shell Script Alias Name
PRGNAME="typecodes"

# Backup to this directory
BACKUPDIR=/mydata/backups/data/typecodes
# The blog programs dir
ORGDIR=/usr/share/nginx/html

# Number of days to keep
NUMDAYS=60

# Some linux command
FINDCMD="find"
TARCMD="tar -zcf"

# Backup date format,e.g 20150505_2010
BACKUPDATE=`date +%Y%m%d_%H%M`

function USAGE() {
cat << EOF
usage: $0 options

This script backs up the blog programs(or other files you want).

OPTIONS:
  -h    Show this message
  -a    Backup all files
  -l    Databases to backup (space seperated)
  -n    Number of days to keep backups
EOF
}

while getopts "hal:n:" opt; do
  case $opt in
    a)
      PRGNAME=""
      ;;
    h)
      USAGE
      exit 1
      ;;
    l)
      PRGNAME="$OPTARG"
      ;;
    n)
      NUMDAYS=$OPTARG
      ;;
    \?)
      USAGE
      exit
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

function ERROR() {
  echo && echo "[error] $@"
  exit 1
}

function NOTICE() {
  echo && echo "[notice] $@"
}

function RUNCMD() {
  echo $@
  eval $@
}

# Sanity checks
if [ ! -n "$BACKUPDIR" ]; then
  ERROR "Invalid backup directory"
fi

if [[ ! $NUMDAYS =~ ^[0-9]+$ ]]; then
  ERROR "Invalid number of days: $NUMDAYS"
elif [ "$NUMDAYS" -eq "0" ]; then
  ERROR "Number of days must be greater than zero"
fi

# Lock down permissions
umask 077

# Create directory if needed
RUNCMD mkdir -p -v $BACKUPDIR

if [ ! -d $BACKUPDIR ]; then
  ERROR "Invalid directory: $BACKUPDIR"
fi

RC=0

RUNCMD "cd $ORGDIR && $TARCMD $BACKUPDATE.tar.gz ./ || mv $BACKUPDATE.tar.gz $BACKUPDIR"
RC=$?

if [ $RC -gt 0 ]; then
  ERROR "TypeCodesDump failed!"
  
else
  NOTICE "Removing dumps older than $NUMDAYS days..."
  RUNCMD "$FINDCMD $BACKUPDIR -name \"*.tar.gz\" -type f -mtime +$NUMDAYS -print0 | xargs -0 rm -fv"

  NOTICE "Listing backup directory contents..."
  RUNCMD ls -la $BACKUPDIR

  NOTICE "Dumping TypeCodes Programs is complete!"
  
fi

# exit 0
