#!/bin/bash
#
# This is a generic wrapper that takes two arguement, the command and the max allowed instances of it.  Based
# on that lock files are created, zombies lock files dealt with, etc.
#
# Author: Chris Robertson
# Date: November 21, 2013
# Version: 1.0

LockDir="/usr/local/scripts/locks"
usage="$0 -n <num of instances> -c <\"quoted command\">"
AlertEmail="team.sd@example1.com"
DEBUG=N

while getopts ":n:c:d" opts 
do
  case "${opts}" in
    n)
       MAX_NUM=${OPTARG}
       ;;
    c)
       CMD=${OPTARG}
       ;;
    d)
       DEBUG=Y
       ;;
    *)
       echo $usage
       exit 1
       ;;
  esac
done

if [ $DEBUG == Y ]
then
  echo ====
  echo MAX_NUM=$MAX_NUM
  echo CMD=$CMD
  echo ====
fi

if [ ! -d $LockDir ]
then
  echo "Lock directory ($LockDir) doesn't appear to exist.  Exiting."
  exit 1
fi

#strip the leading path info from our command
ShortCMD=`echo $CMD | awk '{print $1}' | awk -F\/ '{print $NF}'`

if [ $DEBUG == Y ]
then
  echo ====
  echo ShortCMD=$ShortCMD
  echo ====
fi

# Test for concurrent runs and see if we're allowed to start.
RunCount=0
LockFiles=`find $LockDir -name "${ShortCMD}*"`
LockShort=`echo $LockFiles | awk '{print $1}'`
if [ $DEBUG == Y ]
then
  echo ====
  echo Lock files: $LockFiles
  echo "if [ ! -z $LockShort ]"
  echo ====
fi

if [ ! -z $LockShort ]
then
for lock in `find $LockDir -name "${ShortCMD}*"`
do
  PID=`cat $lock`
  if [ $DEBUG == Y ]
  then
    echo ====
    echo Checking lock file: $LockDir/$lock
    echo PID=$PID
    echo ====
  fi
  
  if [ x`ps axuf | grep -v grep | grep $PID | awk '{print $2}'` == x$PID ]
  then
    RunCount=`expr $RunCount + 1`
  else
    #stale lock file, delete it
    rm $lock
    if [ $? != 0 ]
    then
      echo "Unable to delete stale lock file.  Unpredictable results may occur."
    fi
  fi
done

if [ $DEBUG == Y ]
then
  echo ====
  echo RunCount=$RunCount
  echo ====
fi
fi

if [ $DEBUG == Y ]
then
  echo ====
  echo LockFile=$LockDir/${ShortCMD}-$$.lock
  echo ====
fi

if [ $RunCount -gt $MAX_NUM ]
then
  echo "Unable to continue, too many concurrent processes for $CMD" | mail -s "ERROR: Too many $ShortCMD" $AlertEmail
  exit 1
else
  # EVERYTHING AFTER THIS POINT MUST DELETE THE LOCK FILE WHEN EXITING
  echo $$ > $LockDir/${ShortCMD}-$$.lock
fi

$CMD

rm $LockDir/${ShortCMD}-$$.lock

