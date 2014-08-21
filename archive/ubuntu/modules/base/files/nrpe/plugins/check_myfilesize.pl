#!/usr/bin/perl
############################# Created and written by Shahid Iqbal ############### 
#				shahidiqq@hotmail.com
#	copyright (c) 2008 Shahid Iqbal
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
# keep Check on any file in any directory
# This plugin requires basic perl plugin on the system.

use strict;
use warnings;

my $exit=0;
my $ check_myfilesize = -s "$ARGV[0]";



if ( !$ARGV[1] || !$ARGV[2])
{
########################### Usage of the plugin
# Usage: check_myfilesize.pl filename Critical_size in bytes Warning_size in bytes
# e.g check_myfilesize.pl test.txt 30 25 
print " (Usage) :  check_myfilesize.pl Filename critical_size warning_size   \n";
exit 0;
}

######################### Case 1 if State is Critical
if ($check_myfilesize > $ARGV[1])
{
print "Critical: Current file size is ".$ check_myfilesize."bytes\n";
exit 2;
}

######################## Case 2 if State is Warning
if($check_myfilesize > $ARGV[2] )
{
print "Warning: Current file size is  ".$check_myfilesize."bytes\n";
exit 1;
}

######################## Case 3 if State is OK
if($check_myfilesize < $ARGV[2] && $check_myfilesize < $ARGV[1])
{
print "OK: Current file size is ".$check_myfilesize."bytes\n";
exit 0;
}

sub usage {
   print "Required arguments not given!\n\n";
   print "Nagios plugin to check file size , V1.00\n";
   print "Copyright (c) 2008 Shahid Iqbal \n\n";
}
