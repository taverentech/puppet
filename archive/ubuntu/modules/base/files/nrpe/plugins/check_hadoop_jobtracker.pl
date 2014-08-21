#!/usr/bin/perl -w

# Check hadoop jobtracker, using jobtracker web-gui
# Jon Ottar Runde, jru@rundeconsult.no
# Version 0.3 11/2011		- Added more tests and performancedata
# Version 0.2 11/2011		- Bugfixes
# Version 0.1 11/2011           - Initial Version

use strict;
use Getopt::Long;
use vars qw($opt_b $map $reduce $mapcapacity $reducecapacity $avgtasknodes  $blacklisted $excluded $heapused $heapmax $BM $sockaddr $get $ip $http $BU $line $trackers $PROGNAME $warning $status $state $opt_H $opt_h $opt_v $opt_p $opt_w $opt_c $msg);
#use lib "/usr/lib64/nagios/plugins";
use lib "/usr/lib/nagios/plugins" ;
use utils qw(%ERRORS &print_revision &support &usage );
use Socket;
use FileHandle;

sub print_help ();
sub print_usage ();
sub process_arguments();


Getopt::Long::Configure('bundling');
$status=process_arguments();
if ($status){
        print "ERROR:  Processing Arguments\n";
        exit $ERRORS{'WARNING'};
        }

$state = $ERRORS{'OK'};

$get = '/jobtracker.jsp';

$ip = inet_aton($opt_H) || die "UNKNOWN - $opt_H did not resolve\n";
$sockaddr = pack_sockaddr_in($opt_p, $ip);
socket(SOCKET, PF_INET, SOCK_STREAM, 0) || die "CRITICAL - socket error.\n";
connect(SOCKET, $sockaddr) || die "CRITICAL - connect error.\n";
autoflush SOCKET (1);

print SOCKET "GET $get HTTP/1.0\n\n";

while ($line=<SOCKET>) {
	$_ = $line;
	if (/<b>State:.*/) {
		$status = $line;
		$status =~ s/<b>State:<\/b>\ //g;
		$status =~ s/<br>//g;
		chomp $status;
	}

        if (/Cluster\ Summary/) {
                $heapused = $line;
                $heapused =~ s/.*Heap\ Size\ is\ //g;
		$heapused =~ s/B\)<\/h2>.*//g;
		$BU = $heapused;
                $heapused =~ s/\ [M|G|T]B\/.*//g;
		chomp $heapused;
		if ($BU =~ /GB/) { $heapused *= 1024;  }
		if ($BU =~ /TB/) { $heapused *= 1024000;  }
		$heapmax = $line;
                $heapmax =~ s/.*Heap.* [M|G|T]B\///g;
		$BM = $heapmax;
                $heapmax =~ s/\ [M|G|T]B\).*//g;
		if ($BM =~ /GB/) { $heapmax *= 1024;  }
                if ($BM =~ /TB/) { $heapmax *= 1024000;  }
                $heapmax =~ s/\ [M|G|T]B\).*//g;
		chomp $heapmax;
        }
 
	if( /<a href=\"machines.jsp\?type=active\">[0-9]+/){
		$trackers = $&;
		$trackers =~ s/.*machines.jsp\?type=active\">//g;
		$map = $line;
                $map =~ s/<tr><td>//g;
                $map =~ s/<\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td><a\ href=\"machines.jsp\?type=active.*//g;
		chomp $map;
                $reduce = $line;
                $reduce =~ s/<tr><td>[0-9]+<\/td><td>//g;
                $reduce =~ s/<\/td><td>[0-9]+<\/td><td><a\ href=\"machines.jsp\?type=active.*//g;
		chomp $reduce;
                $mapcapacity = $line;
                $mapcapacity =~ s/.*active\">[0-9]+<\/a><\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>//g;
                $mapcapacity =~ s/<\/td><td>[0-9]+<\/td><td>[0-9]+.[0-9]+<\/td><td><a\ href=\"machines.jsp\?type=blacklisted.*//g;
		chomp $mapcapacity;
                $reducecapacity = $line;
                $reducecapacity =~ s/.*active\">[0-9]+<\/a><\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>//g;
                $reducecapacity =~ s/<\/td><td>[0-9]+.[0-9]+<\/td><td><a\ href=\"machines.jsp\?type=blacklisted.*//g;
		chomp $reducecapacity;

                $avgtasknodes = $line;
                $avgtasknodes =~ s/.*active\">[0-9]+<\/a><\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>[0-9]+<\/td><td>//g;
                $avgtasknodes =~ s/<\/td><td><a\ href=\"machines.jsp\?type=blacklisted.*//g;
		chomp $avgtasknodes;
                $blacklisted = $line;
                $blacklisted =~ s/.*type=blacklisted\">//g;
                $blacklisted =~ s/<\/a><\/td><td><a\ href=\"machines.jsp\?type=excluded.*//g;
		chomp $blacklisted;
                $excluded = $line;
                $excluded =~ s/.*type=excluded\">//g;
                $excluded =~ s/<\/a><\/td><\/tr><\/table>//g;
		chomp $excluded;
	}

}

close(SOCKET);


if (not $status eq "RUNNING") {
	$msg = "CRITICAL - Status is $status";
	$state = $ERRORS{'CRITICAL'};
} elsif ($trackers <= $opt_c ){
	$msg = "CRITICAL - Too few TaskTrackers up and running: $trackers";
	$state = $ERRORS{'CRITICAL'};
} elsif ($blacklisted >= $opt_b ){
        $msg = "ERROR - To many blacklisted nodes: $blacklisted";
        $state = $ERRORS{'CRITICAL'};
} elsif ($trackers <= $opt_w ){
	$msg = "WARNING - To few TaskTracker up and running: $trackers";
	$state = $ERRORS{'WARNING'};
}else{
	$msg = "OK - TaskTracker is $status with $trackers machines";
	$state = $ERRORS{'OK'};

}
print "$msg|TaskTrackers=$trackers HeapUsed=$heapused HeapTotal=$heapmax RunningMap=$map RunningReduce=$reduce MapTaskCapacity=$mapcapacity ReduceTaskCapacity=$reducecapacity AvgTaskperNode=$avgtasknodes BlackListedNodes=$blacklisted ExcludedNodes=$excluded \n";
exit $state;



sub process_arguments(){
        GetOptions (
                        "H=s" => \$opt_H, "Host=s"  => \$opt_H,
                        "p=s" => \$opt_p, "Port=s"  => \$opt_p,
                        "w=s" => \$opt_w, "warning=s"  => \$opt_w,
                        "c=s" => \$opt_c, "critical=s" => \$opt_c,
			"b=s" => \$opt_b, "blacklist=s" => \$opt_b,
                        "h"   => \$opt_h, "help"       => \$opt_h,
                        "v"   => \$opt_v, "version"    => \$opt_v
                   );

        if ($opt_v){
                print_revision ($PROGNAME, '$Revision: 0.1 $');
                exit $ERRORS{'OK'};
                }
        if ($opt_h){
                print_help();
                exit $ERRORS{'OK'};
                }
        unless (defined $opt_w && defined $opt_c && defined $opt_H && defined $opt_p){
                print_usage();
                exit $ERRORS{'UNKNOWN'};
                }
	unless (defined $opt_b){
		$opt_b = 1;
		}
         if ( $opt_c >= $opt_w) {
                 print "Warning (-w) cannot be smaller than Critical (-c)!\n";
                 exit $ERRORS{'UNKNOWN'};
                 }
        return $ERRORS{'OK'};

}


sub print_usage () {
        print "Usage: -w <warn> -c <crit> -H <Hostname> -p <Port> [-v version] [-h help]\n";
}


sub print_help () {
        print "check_hadoop_jobtracker v. 0.3\n";
        print "Copyright (c) 2011 Jon Ottar Runde, jru\@rundeconsult.no\n";
        print "See http:\/\/www.rundeconsult.no\/\?p=66 for updated versions and documentation";
        print "\n";
        print_usage();
        print "\n";
        print "Checks several Hadoop hdfs-parameters\n";
        print "-H (--Host)\n";
        print "-p (--Port)\n";
        print "-w (--warning)   = warning limit number of machines\n";
        print "-c (--critical)  = critical limit number of machines  (w > c )\n";
	print "-b (--blacklist)  = Number of blacklisted nodes for CRITICAL warning (default=1)\n";
        print "-h (--help)\n";
        print "-v (--version)\n";
        print "\n\n";
}

