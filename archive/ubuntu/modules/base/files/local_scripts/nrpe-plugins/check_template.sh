#!/bin/bash
#(@) Joe DeCello - nagios npre plugin bash template

# Nagios exit codes
STATUS_SUCCESS="0"
STATUS_WARNING="1"
STATUS_CRITICAL="2"
STATUS_UNKNOWN="3"

# Setup
ARGUMENTCOUNT=3
ARG1=$1
ARG2=$2
ARG3=$3
COMMAND="command ${ARG1} ${ARG2}"

# Sanity check
if [ $# -ne ${ARGUMENTCOUNT} ]; then
  echo "Usage: $0 ${ARG1} ${ARG2} ${ARG3}"
  exit ${STATUS_UNKNOWN}
fi

# Run command
RESULT=`${COMMAND}`
if [ "$?" != "0" ]; then
  echo "UNKNOWN - $0: ${COMMAND} returned ${RESULT}!"
  exit ${STATUS_WARNING}
fi

# Check command result
if [ ${RESULT} -eq ${ARG3} ]; then
  echo "OK - ${COMMAND} Successful"
  exit ${STATUS_SUCCESS}
else
  echo "CRITICAL - ${COMMAND} returned with issue"
  exit ${STATUS_CRITICAL}
fi
