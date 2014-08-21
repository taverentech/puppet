#!/bin/bash
# Managed by Puppet
# by Andy Siu

d2h () {
        if [ $# != 1 ]; then
                echo "Usage: d2h <num> : convert <num> from decimal to hex"
                return 1;
        fi


        local n=$1
        local ret=""

        local t
        local hd

	if [ $n -lt 10 ]; then
		ret=0$n
	elif [ $n -lt 16 ]; then
	        while [ $n != 0 ]; do
                t=$[$n%16]
                hd=""
                case $t in
                        [0-9]) hd="$t" ;;
                        10)    hd=A ;;
                        11)    hd=B ;;
                        12)    hd=C ;;
                        13)    hd=D ;;
                        14)    hd=E ;;
                        15)    hd=F ;;
                esac
                if [ ! $hd ]; then
                        echo "error in value"
                        return 0
                fi

                ret=0$hd$ret;
                n=$[$n>>4] ;
        done
	else	
        while [ $n != 0 ]; do
                t=$[$n%16]
                hd=""
                case $t in
                        [0-9]) hd="$t" ;;
                        10)    hd=A ;;
                        11)    hd=B ;;
                        12)    hd=C ;;
                        13)    hd=D ;;
                        14)    hd=E ;;
                        15)    hd=F ;;
                esac
                if [ ! $hd ]; then
                        echo "error in value"
                        return 0
                fi

		ret=$hd$ret;
                n=$[$n>>4] ;
        done
	fi
	

        echo $ret
}

	  ipaddress=$1

	   let ip1=`echo $ipaddress|awk -F . '{print $1}'`
           let ip2=`echo $ipaddress|awk -F . '{print $2}'`
           let ip3=`echo $ipaddress|awk -F . '{print $3}'`
           let ip4=`echo $ipaddress|awk -F . '{print $4}'`
           hex="`d2h $ip1``d2h $ip2``d2h $ip3``d2h $ip4`"
           echo $hex

