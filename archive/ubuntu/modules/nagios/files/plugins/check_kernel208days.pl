#!/usr/bin/perl

#use warnings;
#use diagnostics;
use strict;
use Getopt::Std;

my %opt;
getopts( 'dh', \%opt );
&usage() if exists $opt{ h };
my $usercmds=$opt{ u } if exists $opt{ u };
my $debug=1 if exists $opt{ d };
print "DEBUG: $debug\n" if $debug;

my $uptime=`uptime`; chomp $uptime; $uptime =~ s/^.*up (.*),.*,.*:.*$/$1/;
print "Uptime: $uptime\n" if $debug;
my $uptimeDays=1;
if ($uptime =~ /(\d+) days/) {
	$uptimeDays=$1;
}
print "Uptime Days: $uptimeDays\n" if $debug;
my $lgUptime=0;
$lgUptime=1 if $uptimeDays > 199;
print "Uptime isBad: $lgUptime\n" if $debug;

my $cpuvendor=`cat /proc/cpuinfo |grep ^vendor_id|head -1 |awk -F': ' '{print \$2}'`;
chomp $cpuvendor; my $kernel=`uname -r`; chomp $kernel;
print "CPU Vendor: $cpuvendor\n" if $debug;
my $isIntel=0;
$isIntel=1 if ($cpuvendor =~ /intel/i);
print "CPU isIntel: $isIntel\n" if $debug;

my $badKernel=0;
#2.6.26-2-amd64
$kernel =~ m/^(\d+)\.(\d+)\.(\d+)-(\d+)-(.*)$/;
my ($kver,$kmaj,$kmin,$klvl,$knam) = ($1,$2,$3,$4,$5);
print "Kernel: $kernel\n" if $debug;
#$badKernel=1 if ($kver == 2 and $kmaj == 6 and $kmin == 32 and $klvl < 50 and $knam eq "generic");
#$badKernel=1 if ($kver == 2 and $kmaj == 6 and $kmin >= 28 and $kmin <= 33 and $knam eq "generic");
$badKernel=1 if ($kver == 2 and $kmaj == 6 and $kmin == 32 and $klvl < 50 );
$badKernel=1 if ($kver == 2 and $kmaj == 6 and $kmin >= 28 and $kmin <= 33 );
print "Kernel isBad: $badKernel\n" if $debug;

my $status="";
#if ($badKernel and $isIntel and $uptimeDays > 199) {
if ($badKernel and $uptimeDays > 199) {
	$status="CRITICAL";
	print "$status: host running $kernel on $cpuvendor for $uptimeDays days\n";
	exit 2;
#} elsif ($badKernel and $isIntel and $uptimeDays > 169) {
} elsif ($badKernel and $uptimeDays > 169) {
	$status="WARNING";
	print "$status: host running $kernel on $cpuvendor for $uptimeDays days\n";
	exit 1;
} else {
	$status="OK";
	print "$status: host running $kernel on $cpuvendor for $uptimeDays days\n";
}
exit 0;

# Subroutines
sub usage {
  print "USAGE: $0 -h {for help}\n";
  print " or  : $0 -d           To print debug info\n";
  exit 1;
}

