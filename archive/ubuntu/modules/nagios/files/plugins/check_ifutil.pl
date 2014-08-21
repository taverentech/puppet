#!/usr/bin/perl -w

#use strict;
use warnings;
use Getopt::Long;

use constant BITS  => 8;
use constant BYTES => 1;

my $iface     = "";
my $bandwidth = "";
my $warning   = "";
my $critical  = "";
my $percent   = "";

GetOptions(
    "i|interface=s" => \$iface,
    "w|warning=s"   => \$warning,
    "c|critical=s"  => \$critical,
    "b|bandwidth=s" => \$bandwidth,
    "p|percent"     => \$percent
);

my $bitmod = BYTES;

my $tmpfile = "/tmp/traffic";
my $output  = "";
my $line    = "";

my %status = ( 'OK'       => 0, 
               'WARNING'  => 1, 
               'CRITICAL' => 2, 
               'UNKNOWN'  => 3 
           );
my $exit_status = $status{OK}; 

my %data = ( 'time'    => 0, 'last_time'    => 0, 
             'rxbytes' => 0, 'last_rxbytes' => 0,
             'txbytes' => 0, 'last_txbytes' => 0
         );

my %speed = ( 'tx' => 0, 
              'rx' => 0, 
              'interval' => 0 
          );

usage() if ( !$iface ); 

open ( NET, "</proc/net/dev" ) or die ( "Can't open /proc/net/dev: $!" );
while ( <NET> ) {
    chomp();
    if ( $_ =~ /^\s*$iface\:\s*(\d+)(?:\s*(?:\d+)){7}\s*(\d+)(?:\s*(?:\d+)){7}\s*$/ ) {
        $data{time} = time - 1; 
        $data{rxbytes} = $1; 
        $data{txbytes} = $2;
        last;
    }
}
close( NET );

if ( $data{time} == 0 && $data{rxbytes} == 0 && $data{txbytes} == 0 ) {
    exit $status{UNKNOWN};
}

if ( open( TMP, "<$tmpfile-$iface" ) ) {
    my @line = <TMP>; chomp( @line );
    ( $data{last_time}, $data{last_rxbytes}, $data{last_txbytes} ) = split( ":", $line[0] );
}

if ( open( TMP, ">$tmpfile-$iface" ) ) {
    print( TMP "$data{time}:$data{rxbytes}:$data{txbytes}\n" );
    close( TMP ); 
}

$data{last_time} = $data{time} if ( !$data{last_time} || $data{last_time} > $data{time} );
$data{last_rxbytes} = $data{rxbytes} if ( !$data{last_rxbytes} || $data{last_rxbytes} > $data{rxbytes} );
$data{last_txbytes} = $data{txbytes} if ( !$data{last_txbytes} || $data{last_txbytes} > $data{txbytes} );

$speed{interval} = $data{time} - $data{last_time} + 1;
$speed{rx} = ( $data{rxbytes} - $data{last_rxbytes} ) / $speed{interval};
$speed{tx} = ( $data{txbytes} - $data{last_txbytes} ) / $speed{interval};

$output = "RX Bytes: ". bytes2human($data{rxbytes}) ."B, TX Bytes: ". bytes2human($data{txbytes}) ."B; ";
$output .= sprintf( "RX Speed: %s%sps, TX Speed: %s%sps; ", 
           bytes2human($speed{rx}*$bitmod), ($bitmod==BITS)?"b":"B", bytes2human($speed{tx}*$bitmod), ($bitmod==BITS)?"b":"B" );

        $output .= "OK";

$output .= " bandwidth utilization";
$output .= sprintf( " | rx=%.0f;; tx=%.0f;;", 
           $speed{rx}*$bitmod, 
           $speed{tx}*$bitmod );

print "$output\n";
exit( $exit_status );


# helper function
sub bytes2human {
    my $bytes = shift;
    return 0 if !$bytes;

    my @units = ( '','K','M','G','T' );
    my $offset = 0;

    while ( $bytes > 1024 ){
        $bytes = $bytes / 1024;
        $offset++;
    }
    return sprintf( "%2.0f%s", $bytes, $units[$offset] );
}

sub human2bytes {
    my $value = shift;
    return 0 if ( !$value || $value !~ /^(\d+)(\w)$/ );
    my ($number, $scale) = ($1,$2);

    my $bitmod = ( $scale =~ /[kmg]/ ) ? BITS : BYTES;
    my @units = ( '','K','M','G','T' );
    my $offset = 0;

    while( $units[$offset] ne "\u$scale" && $offset <= scalar(@units) ) {
        $number *= 1024;
        $offset++;
    }

    return $number/$bitmod;
}

sub usage {
    print <<EOU;

    Usage: $0 -i <interface>

    -i, --interface STRING
        Network interface name (example: eth0)
EOU
    exit $status{UNKNOWN};
}

