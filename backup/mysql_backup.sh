#!/bin/bash
# MySQL Backup Script v1.0.0
# (c) 2015 vfhky https://typecodes.com/linux/centos7mysqlregularbackup.html
# Reference: https://github.com/chekolyn/bash-scripts/blob/master/mysql-dbs-backup.sh
# https://github.com/vfhky/shell-tools/blob/master/backup/mysql_backup.sh
# https://coding.net/u/vfhky/p/shell-tools/git/blob/master/backup/mysql_backup.sh

# Space separated list of databases
DBLIST="your mysql database name witch you want to backup"

# Backup to this directory
BACKUPDIR=/mydata/backups/data/mysql

# Number of days to keep
NUMDAYS=60

# Some linux command and your mysql configure
FINDCMD="find"
MYSQLCMD="mysql"
MyUSER="your mysql user name"                   # USERNAME
MyPASS="your mysql password"                   # PASSWORD 
MyHOST="localhost"          # Hostname
DUMPCMD="mysqldump -u$MyUSER -h $MyHOST -p$MyPASS --lock-tables --databases "
GZIPCMD="gzip"

# Backup date format,e.g 20150505_2010
BACKUPDATE=`date +%Y%m%d_%H%M`

function USAGE() {
cat << EOF
usage: $0 options

This script backs up a list of MySQL databases.

OPTIONS:
  -h    Show this message
  -a    Backup all databases
  -l    Databases to backup (space seperated)
  -n    Number of days to keep backups
EOF
}

while getopts "hal:n:" opt; do
  case $opt in
    a)
      DBLIST=""
      ;;
    h)
      USAGE
      exit 1
      ;;
    l)
      DBLIST="$OPTARG"
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
if [ ! -n "$DBLIST" ]; then
  DBLIST=`$MYSQLCMD -N -s -e "show databases" | grep -viE '(information_schema|performance_schema|mysql|test)'`

  if [ ! -n "$DBLIST" ]; then
    ERROR "Invalid database list"
  fi
fi

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

NOTICE "Dumping MySQL databases..."
RC=0

for database in $DBLIST; do
  NOTICE "Dumping $database..."
  RUNCMD "$DUMPCMD $database | $GZIPCMD > $BACKUPDIR/$BACKUPDATE.sql.gz"

  RC=$?
  if [ $RC -gt 0 ]; then
    continue;
  fi
done

if [ $RC -gt 0 ]; then
  ERROR "MySQLDump failed!"
else
  NOTICE "Removing dumps older than $NUMDAYS days..."
  RUNCMD "$FINDCMD $BACKUPDIR -name \"*.sql.gz\" -type f -mtime +$NUMDAYS -print0 | xargs -0 rm -fv"

  NOTICE "Listing backup directory contents..."
  RUNCMD ls -la $BACKUPDIR

  NOTICE "MySQLDump is complete!"
fi

# exit 0
