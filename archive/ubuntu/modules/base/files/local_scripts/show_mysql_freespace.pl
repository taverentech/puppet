#!/usr/bin/perl -w
# Managed by Puppet

use strict;

use Getopt::Long;
my @options;

# Get output immediately. It won't hurt performance.
use FileHandle;
autoflush STDERR;
autoflush STDOUT;

my $user;
push(@options, "user=s", \$user);

my $pw;
push(@options, "password=s", \$pw);

my $host = "localhost";
push(@options, "host=s", \$host);

#die "Couldn't parse options" if !GetOptions(@options);

#die "Must give -password\n" if !defined($pw);

my $cmd = mysql_cmd("show databases");
open(CMD, $cmd) or die "Couldn't $cmd: $!\n";
my @databases;
my $header = <CMD>;
while ( <CMD> ) {
  s/[\r\n]$//g;
  #print "$_\n";
  push (@databases, $_);
}
close(CMD);

#print "@databases";

my %colmap = ( 'Data_length' => 6,
'Index_length' => 8,
'Engine' => 1,
'Comment' => 17 );

my %size;
my %total_size;
my %engine_map;

my $inno_db_free;
foreach my $db (@databases) {
  print STDERR ".";
  $cmd = mysql_cmd("use $db; show table status");
  
  open(CMD, $cmd) or die "Couldn't $cmd: $!\n";
  my $header = <CMD>;
  my $total_size = 0;
  if (defined($header)) {
    $header =~ s/[\r\n]$//g;
    my @head = split("\t", $header);

    foreach my $col (keys %colmap) {
      die "$db: Expected '$col', found '" . $head[$colmap{$col}] . "'"
      if $head[$colmap{$col}] ne $col;
    }

    while (<CMD>) {
      my @data = split("\t");
      my ($data_length, $index_length) = @data[6,8];
      my ($engine, $comment) = @data[1,17];
      $engine_map{$engine}++;
      $size{$db}{$engine} += $data_length + $index_length;
      $total_size{$db} += $data_length + $index_length;
  
      if ( $comment =~ /InnoDB free: (\d+) kB/ ) {
        die "Found two different inno DB free sized.\n"
        if defined($inno_db_free) && $inno_db_free != $1;
        $inno_db_free = $1;
      }
    }
    close(CMD);
  }
}
print STDERR "\n";

print "NOTE: All numbers are in megabytes (G).\n";
printf("Inno DB free: %.1f\n", ($inno_db_free/1024/1024) )
  if defined($inno_db_free);

printf("%-30s ", "database");
foreach my $engine (sort keys(%engine_map)) {
  printf "%7s ", $engine;
}
printf "%8s", "total";
print "\n";

foreach my $db (sort {$total_size{$b} <=> $total_size{$a}} keys %total_size) {
  printf("%-30s ", $db);
  foreach my $engine (sort keys(%engine_map)) {
  my $size= $size{$db}{$engine};
  $size = 0 if !defined($size);
  printf("%7.1f ", $size/1024/1024/1024);
  }
  printf("%8.1f\n", $total_size{$db}/1024/1024/1024);
}

sub mysql_cmd {
  my $mysql_cmd = shift;

  return "mysql -e '$mysql_cmd'|";
  #return "mysql -u$user -h$host -p$pw -e '$mysql_cmd'|";
}
