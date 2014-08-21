#!/usr/bin/perl
#(@) nagios check_mounts plugin
#by Joe DeCello, SiteOps

use strict;

my $debug=0;

my $result=0;
my @results;
my $fstab="/etc/fstab";
my $status;

open FSTAB, "$fstab" or die $!;
while (<FSTAB>) {
	chomp;
	next if /^\s*$/;
	next if /^\s*#/;
	my (undef,$mount)=split(' ',$_);
	next if $mount eq "swap";
	print "DEBUG: Checking mount $mount\n"
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
close (FSTAB);

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
