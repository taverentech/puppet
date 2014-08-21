#!/usr/bin/perl -w

# Check hadoop hdfs data, using web-gui
# Joe DeCello, jdecello@hotmail.com
# Version 0.5 02/2014		- Bugfix, script expected data-size in TB, when free space became PB, things broke.
# Jon Ottar Runde, jru@rundeconsult.no
# Version 0.4 02/2012		- Bugfix, script expected data-size in TB, when free space became GB, things broke.
# Version 0.3 11/2011		- Use perl-Socket instead of links
# Version 0.2 11/2011		- Bugfixes
# Version 0.1 11/2011		- Initial Version

use strict;
use Getopt::Long;
use vars qw($ip $sockaddr $get $PROGNAME $warning $status $state @Data $line $opt_x $opt_u $opt_H $opt_h $opt_v $opt_p $opt_w $opt_c $pctfree $msg $dfsused $nondfsused $dfstotal $dfsremaining $livenodes $deadnodes $underreplicated $files $blocks);
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

$get = '/dfshealth.jsp';
$ip = inet_aton($opt_H) || die "UNKNOWN - $opt_H did not resolve\n";
$sockaddr = pack_sockaddr_in($opt_p, $ip);
socket(SOCKET, PF_INET, SOCK_STREAM, 0) || die "CRITICAL - socket error.\n";
connect(SOCKET, $sockaddr) || die "CRITICAL - connect error.\n";
autoflush SOCKET (1);
print SOCKET "GET $get HTTP/1.0\n\n";

while ($line=<SOCKET>) {
	if ($line =~ /<tr class.*<br>/) {
		$dfsused = $line;
		$dfsused =~ s/.*>\ DFS Used<td id=\"col2\">\ :<td id=\"col3\">\ //g;
		$dfsused =~ s/\ [PTGM]B<tr\ class=\"rowNormal\">\ <td\ id=\"col1\">\ Non\ DFS.*//g;
		chomp $dfsused;
                $nondfsused = $line;
                $nondfsused =~ s/.*\ Non\ DFS\ Used<td\ id=\"col2\">\ :<td\ id=\"col3\">\ //g;
                $nondfsused =~ s/\ [PTGM]B<tr\ class=\"rowAlt\">\ <td\ id=\"col1\">\ DFS\ Remaining<.*//g;
                chomp $nondfsused;
		$dfstotal = $line;
		$dfstotal =~ s/.*\ Capacity<td\ id=\"col2\">\ :<td\ id=\"col3\">\ //g;
                $dfstotal =~ s/\ [PTGM]B<tr\ class=\"rowAlt\">\ <td\ id=\"col1\">\ DFS\ Used.*//g;
		chomp $dfstotal;
                $dfsremaining = $line;
                $dfsremaining =~ s/.*DFS\ Remaining<td\ id=\"col2\">\ :<td\ id=\"col3\">\ //g;
		if ($dfsremaining =~ /\ PB<tr.*/) {
                        $dfsremaining =~ s/\ PB<tr\ class=\"rowNormal\">\ <td\ id=\"col1\">\ DFS\ Used.*//g;
                        chomp $dfsremaining;
                        $dfsremaining = ($dfsremaining * 1024); # Convert to TB
                }
		if ($dfsremaining =~ /\ TB<tr.*/) {
                        $dfsremaining =~ s/\ TB<tr\ class=\"rowNormal\">\ <td\ id=\"col1\">\ DFS\ Used.*//g;
                        chomp $dfsremaining;
                }
                if ($dfsremaining =~ /\ GB<tr.*/) {
                        $dfsremaining =~ s/\ GB<tr\ class=\"rowNormal\">\ <td\ id=\"col1\">\ DFS\ Used.*//g;
                        chomp $dfsremaining;
                        $dfsremaining = ($dfsremaining / 1024); # Convert to TB
                }
                if ($dfsremaining =~ /\ MB<tr.*/) {
                        $dfsremaining =~ s/\ MB<tr\ class=\"rowNormal\">\ <td\ id=\"col1\">\ DFS\ Used.*//g;
                        chomp $dfsremaining;
                        $dfsremaining = ($dfsremaining / 1024 / 1024 ); # Convert to TB
                }

                chomp $dfsremaining;
                $livenodes = $line;
                $livenodes =~ s/.*Live\ Nodes<\/a>\ <td\ id=\"col2\">\ :<td\ id=\"col3\">\ //g;
		$livenodes =~ s/<tr\ class=\"rowAlt\">\ <td\ id=\"col1\">\ <a\ href=\"dfsnodelist.jsp\?whatNodes=DEAD.*//g;
                chomp $livenodes;
                $deadnodes = $line;
                $deadnodes =~ s/.*Dead\ Nodes<\/a>\ <td\ id=\"col2\">\ :<td\ id=\"col3\">\ //g;
		$deadnodes =~ s/<tr\ class=\"rowNormal\">\ <td\ id=\"col1\">\ <a\ href=\"dfsnodelist.jsp\?whatNodes=DECOMM.*//g;
                chomp $deadnodes;
                $underreplicated = $line;
                $underreplicated =~ s/.*Under-Replicated\ Blocks<td\ id=\"col2\">\ :<td\ id=\"col3\">\ //g;
		$underreplicated =~ s/<\/table><\/div><br>.*//g;
                chomp $underreplicated;
	}
        if ($line =~ /WARNING/) {
                $warning = $line;
                $warning =~ s/.*about\ //g;
		$warning =~ s/\ missing.*//g;
                chomp $warning;
        }
        if ($line =~ /directories/) {
                $files = $line;
                $files =~ s/<b>\ //g;
		$files =~ s/\ files\ and\ directories.*//g;
                $blocks = $line;
                $blocks =~ s/\ blocks.*//g;
                $blocks =~ s/.*directories,\ //g;
		chomp $files;
                chomp $blocks;
        }

}

close(SOCKET);

$pctfree = ( $dfsremaining / $dfstotal ) * 100;
$pctfree = sprintf ("%.0f", $pctfree);
$state = $ERRORS{'OK'};
$msg = "OK: HDFS is OK at $pctfree % free space with no dead nodes, and $underreplicated Under-replicated blocks";

if ($pctfree < $opt_w ){
        $msg = "WARNING: Free space $pctfree % is less then warning limit $opt_w %";
        $state=$ERRORS{'WARNING'};
        }

if ($underreplicated > $opt_x ){
        $msg = "WARNING: Under-replicated blocks are more than warning limit $opt_x  %";
        $state=$ERRORS{'WARNING'};
        }

if ($pctfree < $opt_c ){
        $msg = "ERROR: Free space $pctfree % is less then error limit $opt_c %"; 
        $state=$ERRORS{'CRITICAL'};
        }

if ($underreplicated > $opt_u ){
        $msg = "ERROR: Under-replicated blocks are more than error limit $opt_u %";
        $state=$ERRORS{'CRITICAL'};
        }

if ($deadnodes > 0 ){
        $msg = "CRITICAL: Dead Nodes detected: $deadnodes\nMore info http://$opt_H:$opt_p/dfsnodelist.jsp?whatNodes=DEAD";
        $state=$ERRORS{'CRITICAL'};
        }

if ($warning){
        $msg = "CRITICAL: Missing blocks, about: $warning Run fsck";
        $state=$ERRORS{'CRITICAL'};
        }


if ($warning  and $deadnodes > 0){
        $msg = "CRITICAL: Dead Nodes: $deadnodes and missing blocks, about: $warning -Run fsck";
        $state=$ERRORS{'CRITICAL'};
        }



print "$msg|PctFree=$pctfree livenodes=$livenodes deadnodes=$deadnodes underreplicated=$underreplicated dfstotal=$dfstotal dfsused=$dfsused dfsremaining=$dfsremaining Files_and_Directories=$files DataBlocks=$blocks nondfsused=$nondfsused \n";
exit $state;



sub process_arguments(){
        GetOptions (
			"H=s" => \$opt_H, "Host=s"  => \$opt_H,
                        "p=s" => \$opt_p, "Port=s"  => \$opt_p,
                        "x=s" => \$opt_x, "unreplicatedwarn=s"  => \$opt_x,
                        "u=s" => \$opt_u, "unreplicatedcritical=s"  => \$opt_u,
                        "w=s" => \$opt_w, "warning=s"  => \$opt_w,
                        "c=s" => \$opt_c, "critical=s" => \$opt_c,
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
        unless (defined $opt_w && defined $opt_c && defined $opt_H && defined $opt_p && defined $opt_x && defined $opt_u ){
                print_usage();
                exit $ERRORS{'UNKNOWN'};
                }
         if ( $opt_w <= $opt_c) {
                 print "Warning (-w) cannot be smaller than Critical (-c)!\n";
                 exit $ERRORS{'UNKNOWN'};
                 }
        return $ERRORS{'OK'};

}


sub print_usage () {
        print "Usage: -w <warn> -c <crit> -x <Unreplicated blocks warn> -u <Unreplicated blocks crit> -H <Hostname> -p <Port> [-v version] [-h help]\n";
}


sub print_help () {
        print "check_hadoop_hdfs v. 0.3\n";
        print "Copyright (c) 2011 Jon Ottar Runde, jru\@rundeconsult.no\n";
	print "See http:\/\/www.rundeconsult.no\/\?p=38 for updated versions and documentation";
        print "\n";
        print_usage();
        print "\n";
        print "Checks several Hadoop hdfs-parameters\n";
        print "-H (--Host)\n";
        print "-p (--Port)\n";
        print "-w (--warning)   = warning for DFS Usage\n";
        print "-c (--critical)  = critical limit for DFS Usage  (w < c )\n";
        print "-x (--unreplicatedwarn) = Warning limit for Unreplicated blocks\n";
        print "-u (--unreplicatedcritical) = Error limit for Unreplicated blocks\n";
        print "-h (--help)\n";
        print "-v (--version)\n";
        print "\n\n";
}


