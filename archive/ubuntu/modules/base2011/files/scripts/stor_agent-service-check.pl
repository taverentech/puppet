#!/usr/bin/perl
use strict;
use warnings;

my @status = qx{ps axwww | grep java | grep StorMan |grep -v grep};

my $exit = 1;

for ( @status ) {
        chomp;
        $exit = 0 if /ManagementAgent/;
}

print "$exit\n";
exit $exit;
#end
