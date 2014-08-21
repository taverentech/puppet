#!/bin/bash

ARGUMENTCOUNT=3

# Nagios exit codes
STATUS_SUCCESS="0"
STATUS_WARNING="1"
STATUS_CRITICAL="2"
STATUS_UNKNOWN="3"

# Sanity check
if [ $# -ne ${ARGUMENTCOUNT} ]; then
  echo "Usage: $0 directory minutes file_count"
  exit ${STATUS_UNKNOWN}
fi

DIRECTORY=$1
MINUTES=$2
FILECOUNT=$3

RESULT=`find ${DIRECTORY} -type f -mmin -${MINUTES} |wc -l`
if [ "$?" != "0" ]; then
  echo "UNKNOWN - $0: find ${DIRECTORY} failed to run!"
  exit ${STATUS_WARNING}
fi

if [ ${RESULT} -gt 0 ]; then
  echo "OK - ${DIRECTORY} contains ${FILECOUNT} modified within ${MINUTES} minutes."
  exit ${STATUS_SUCCESS}
else
  echo "CRITICAL - ${DIRECTORY} contains ${FILECOUNT} modified within ${MINUTES} minutes."
  exit ${STATUS_CRITICAL}
fi
