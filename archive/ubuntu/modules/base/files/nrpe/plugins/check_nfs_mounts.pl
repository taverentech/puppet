#!/usr/bin/perl
#(@) nagios check_mounts plugin
#by Joe DeCello, SiteOps

use strict;

my $debug=1;

my $result=0;
my @results;
my @mounts=qx{mount -t nfs -l};
my $status;

foreach (@mounts) {
	chomp;
	next if /^\s*$/;
#bigfoot:/export/home/jdecello on /netmount/home/jdecello type nfs (rw,nosuid,nodev,hard,intr,addr=172.21.1.3)
	my ($server,undef,$mount,undef,$type,$options)=split(' ',$_);
	next unless $type eq "nfs";
	print "DEBUG: Checking nfs mount $mount\n"
		if $debug;
	qx{mountpoint -q $mount};
	if ($? >> 8) {
		print "DEBUG: $mount check failed\n" if $debug;
		unshift(@results,"$mount NOT mounted,");
		$result++;
	} else {
		push(@results,"$mount mounted,");
	}
}

if ($result ne 0) {
	print "CRITICAL: ";
	$status= 2;
} else {
	print "OK: ";
	$status= 0;
}

print "@results";
print "\n";

exit $status;
