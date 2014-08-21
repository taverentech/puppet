#!/usr/bin/perl

my $type = "gateway";
($ARGV[0]) && ($type = shift(@ARGV));

%codes = (
	"OK" => 0,
	"WARNING" => 1,
	"CRITICAL" => 2,
	"UNKNOWN" => 3,
	"DEPENDENT" => 4);

my $error = "OK";
my @output = `/opt/example/gs/current/${type}/bin/${type}_monitor.sh 2>/dev/null`;

if($? != 0) {
	$error = "CRITICAL";
}

my @counters = (
"gateway_socket_requests",
"gateway_socket_responses",
"gateway_socket_errors",
"gateway_http_requests",
"gateway_http_auth_errors",
"cpu_process_time",
"gc_parnew_collection_count",
"gc_parnew_collection_time",
"gc_concurrentmarksweep_collection_count",
"gc_concurrentmarksweep_collection_time",
"gc_ps_marksweep_collection_count",
"gc_ps_marksweep_collection_time",
"gc_ps_scavenge_collection_count",
"gc_ps_scavenge_collection_time",
);

my $counterRE = "(".join("|", @counters).")";
foreach my $line (@output) {
	chomp($line);
	if($line =~ /^status=(\S+)$/) {
		if($1 != "ok") {
			$error = "CRITICAL";
		}
	} else {
		if($line =~ m{^$counterRE$}) {
			$line .= "c";
		}
		push(@final, $line);
	}
}

printf("%s - see perfdata|%s\n", $error, join(" ", @final));
exit($codes{$error});
