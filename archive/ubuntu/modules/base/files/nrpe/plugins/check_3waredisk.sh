#!/bin/sh

##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation, either version 3 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with check_bacula.pl.  If not, see <http://www.gnu.org/licenses/>.

# Asko Tamm asko@ultrasoft.ee
# Silver Salonen silver@ultrasoft.ee

# tw_cli is 3ware CLI utility, available from 3ware homepage

# changelog:

# version 1.2 (04.Jan.2010)
# * diskstatus(), unitstatus(), unitdiskstatus() -- don't return anything, use global variable $exitstatus instead
# * diskstatus(), unitstatus(), unitdiskstatus() -- use 1 for warning, 2 for critical
# * delete duplicate code

# (13.Dec.2006)
# * change /usr/local/3ware/tw_cli to FreeBSD's official /usr/local/sbin/tw_cli

# version 1.1 (20.Apr.2005)
# * added RAID array individual disk checking, because RAID disk failure 
# * doesn't show in non-RAID disk check (problem fixed in 3WARE CLI util version 2.00.02.008)

# version 1.0 (24.Dec.2004)

# plugin return codes:
# 0	OK
# 1	Warning
# 2	Critical
# 3	Unknown

#twcli="/usr/local/sbin/tw_cli"
#twcli="/root/x86_64/tw_cli"
#twcli="/usr/lib/nagios/plugins/tw_cli"
twcli="/usr/sbin/tw-cli"

if [ ! -f $twcli ] ; then
	echo "3ware CLI utility not found! Aborting!"
	exit 3
fi

print_usage() {
	echo "Usage: $0 [-h] [--help] <controller id> <drive id> <drive description>"
	echo "or: $0 [-h] [--help] <controller id> <unit id> <unit description> isarray"
	echo "or: $0 [-h] [--help] <controller id> <unit id> <unit description> isarray <unit disk id>"
	echo "example1: $0 c0 p1 \"system mirror disk 1\""
	echo "example2: $0 c0 u0 \"system raid array\" isarray"
	echo "example3: $0 c0 u0 \"system raid array disk 1\" isarray u0-1"
}

print_help() {
	print_usage
	echo ""
	echo "This plugin checks the status of hard disks connected to 3ware raid controller."
	echo ""
	exit 3
}

diskstatus () { # usage: diskstatus <controller id> <drive id>
	local controllerid="$1"
	local disk="$2"
	statusmsg=` sudo $twcli info $controllerid $disk | grep "$disk " | tr -s " " "\t" | cut -f 2`
	if [ "$statusmsg" = "OK" ]; then
		exitstatus=0
	else
		exitstatus=2
	fi
}

unitstatus () { # usage: unitstatus <controller id> <array unit id>
	local controllerid="$1"
	local unit="$2"
	statusmsg=`sudo $twcli info $controllerid $disk | grep "$unit " | tr -s " " "\t" | cut -f 3` 
	if [ "$statusmsg" = "OK" ]; then
		exitstatus=0
	elif [ "$statusmsg" = "VERIFYING" ]; then
		# exitstatus=1
		exitstatus=0
	else
		exitstatus=2
	fi
}

unitdiskstatus () { # usage: unitdiskstatus <controller id> <array unit id> <array unit disk id>
	local controllerid="$1"
	local disk="$2"
	local unitdisk="$3"
	statusmsg=`sudo $twcli info $controllerid $disk | grep "$unitdisk " | tr -s " " "\t" | cut -f 3`
	if [ "$statusmsg" = "OK" ]; then
		exitstatus=0
	else
		exitstatus=2
	fi
}

controllerid="$1"
disk="$2"
desc="$3"
checkunit="$4"

if ( [ ! "$controllerid" ] ) || ( [ ! "$disk" ] ); then
	print_usage
	exit 3
fi

case "$controllerid" in
	--help)
		print_help
		exit 3
	;;
	-h)
		print_help
		exit 3
	;;
	*)
		if [ ! "$disk" ] || [ ! "$desc" ]; then # if description of process isn't given
			print_usage
			exit 3
		fi
		if [ "$checkunit" != "isarray" ]; then
			diskstatus $1 $2
		elif [ "$5" = "" ]; then
			unitstatus $1 $2
		else 
			unitdiskstatus $1 $2 $5
		fi
		echo "$desc status is $statusmsg"
		exit $exitstatus
	;;
esac
