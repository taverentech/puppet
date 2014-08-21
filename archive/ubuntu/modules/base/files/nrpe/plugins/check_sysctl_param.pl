#!/usr/bin/perl
############################# Created and written by Joe DeCello ############### 
#				jdecello@hotmail.com
#	copyright (c) 2014 Joe DeCello
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; 
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# contact the author directly for more information at: shahidiqq@homail.com				
#################################################################################
# keep Check on any sysctl key in kernel
# This plugin requires basic perl plugin on the system.

use strict;
use warnings;

my $exit=0;
&usage unless $ARGV[0];

my $sysctl_param_val = qx{/sbin/sysctl -n $ARGV[0]};
chomp $sysctl_param_val;
if ($? >> 8) {
  print "Unknown: Could not run /sbin/sysctl ".$sysctl_param_val."\n";
  exit 3;
}

if ( !$ARGV[1] || !$ARGV[2]) {
  ########################### Usage of the plugin
  # Usage: check_sysctl_param.pl Param Warning_count Critical_count
  # e.g check_sysctl.pl 30 25 
  print " (Usage) :  $0 sysctl_param warning_count critical_count\n";
  exit 0;
}

my $STATUS;
my $EXIT;
if ($sysctl_param_val > $ARGV[2]) {
  $STATUS = "Critical"; $EXIT=2;
} elsif($sysctl_param_val > $ARGV[1] ) {
  $STATUS = "Warning"; $EXIT=1;
} else {
  $STATUS = "OK"; $EXIT=0;
}

print "${STATUS}: Current $ARGV[0] count is $sysctl_param_val | $ARGV[0]=$sysctl_param_val warning=$ARGV[1] critical=$ARGV[2]\n";
exit ${EXIT};

#############################################################################
sub usage {
   print "Unknown: Required arguments not given!\n\n";
   print "Nagios plugin to check sysctl param value, V1.00\n";
   print "Copyright (c) 2014 Joe DeCello\n\n";
   exit 3;
}
