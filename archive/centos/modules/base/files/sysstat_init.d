#!/bin/sh
#
# chkconfig: 12345 01 99
# /etc/rc.d/init.d/sysstat
# (C) 2000-2009 Sebastien Godard (sysstat <at> orange.fr)
#
### BEGIN INIT INFO
# Provides:             sysstat
# Required-Start:
# Required-Stop:
# Default-Stop:
# Description: Reset the system activity logs
# Short-Description: reset the system activity logs
### END INIT INFO
#@(#) sysstat-9.0.4 startup script:
#@(#)	 Insert a dummy record in current daily data file.
#@(#)	 This indicates that the counters have restarted from 0.

RETVAL=0
SYSCONFIG_DIR=/etc/sysconfig

# See how we were called.
case "$1" in
  start)
	exitCodeIndicator="$(mktemp /tmp/sysstat-XXXXXX)" || exit 1
	echo -n "Calling the system activity data collector (sadc): "
	  /usr/lib64/sa/sa1 --boot || rm -f ${exitCodeIndicator}

	# Try to guess if sadc was successfully launched. The difficulty
	# here is that the exit code is lost when the above command is
	# run via "su foo -c ..."
	if [ -f "${exitCodeIndicator}" ]; then
		rm -f ${exitCodeIndicator}
	else
		RETVAL=2
	fi
	echo
	;;
  stop|status|restart|reload|force-reload|condrestart|try-restart)
	;;
  *)
	echo "Usage: sysstat {start|stop|status|restart|reload|force-reload|condrestart|try-restart}"
	exit 2
esac
exit ${RETVAL}
