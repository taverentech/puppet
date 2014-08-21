#!/usr/bin/perl -w

# check_mem_usage Nagios Plugin
#
# TComm - Carlos Peris Pla
#
# This nagios plugin is free software, and comes with ABSOLUTELY 
# NO WARRANTY. It may be used, redistributed and/or modified under 
# the terms of the GNU General Public Licence (see 
# http://www.fsf.org/licensing/licenses/gpl.txt).


# MODULE DECLARATION

use strict;
use Nagios::Plugin;


# FUNCTION DECLARATION

sub CreateNagiosManager ();
sub CheckArguments ();
sub PerformCheck ();
sub UnitConversion ();
sub ConversionFromPercentage ();
sub PerfdataToBytes ();


# CONSTANT DEFINITION

use constant NAME => 	'check_unix_mem_usage';
use constant VERSION => '0.4b';
use constant USAGE => 	"Usage:\ncheck_unix_mem_usage -w <mem_threshold,app_mem_threshold,cache_threshold,swap_threshold> -c <mem_threshold,app_mem_threshold,cache_threshold,swap_threshold>\n".
    "\t\t[-u <unit>] [-m <maxram>] [-p <perthres>] \n".
    "\t\t[-V <version>]\n";
use constant BLURB => 	"This plugin checks the memory status of a UNIX system and compares the values of memory usage,\n".
    "application memory usage and swap with their associated thresholds.\n";
use constant LICENSE => "This nagios plugin is free software, and comes with ABSOLUTELY\n".
    "no WARRANTY. It may be used, redistributed and/or modified under\n".
    "the terms of the GNU General Public Licence\n".
    "(see http://www.fsf.org/licensing/licenses/gpl.txt).\n";
use constant EXAMPLE => "\n\n".
    "Examples:\n".
    "\n".
    "check_unix_mem_usage.pl -u MiB -w 900,800,400,700 -c 1000,900,500,800\n".
    "\n".
    "It returns WARNING if memory usage is higher than 900MiB or if application memory usage is higher than 800MiB or\n".
    "if cache usage is higher than 400MiB or if used swap is higher than 700MiB and CRITICAL if memory usage is higher\n".
    "than 1000MiB or if application memory usage is higher than 900MiB or if cache usage is higher than 500MiB or if \n".
    "used swap is higher than 800MiB.\n".
    "In other cases  it returns OK if check has been performed succesfully.\n\n".
    "Note: thresholds of both WARNING and CRITICAL must be passed in the chosen units.\n".
    "\n\n".
    "check_unix_mem_usage.pl -u MiB -m -p -w 80,80,,80 -c 90,90,,90\n".
    "\n".
    "It returns WARNING if memory usage or if application memory usage or if swap is higher than 80% and CRITICAL if \n".
    "memory usage or if application memory usage or if swap is higher than 90%.\n".
    "In other cases  it returns OK if check has been performed succesfully.\n\n".
    "Note: thresholds of both WARNING and CRITICAL must be passed in percentage. And note that the cache has not been\n".
    "checked.\n";

								
# VARIABLE DEFINITION

my $Nagios;
my $Error;
my $PluginResult;
my $PluginOutput;
my @WVRange;
my @CVRange;
my $Unit;
my $ConvertToUnit=0;
my @MemFLAGS=(1,1);
my @AppFLAGS=(1,1);
my @CacheFLAGS=(1,1);
my @SwapFLAGS=(1,1);


# MAIN FUNCTION

# Get command line arguments
$Nagios = &CreateNagiosManager(USAGE, VERSION, BLURB, LICENSE, NAME, EXAMPLE);
eval {$Nagios->getopts};

if (!$@) {
	# Command line parsed
	if (&CheckArguments($Nagios, \$Error, \$Unit, \$ConvertToUnit, \@WVRange, \@CVRange)) {
		# Argument checking passed
		$PluginResult = &PerformCheck($Nagios, \$PluginOutput, $Unit, $ConvertToUnit, \@WVRange, \@CVRange)
	}
	else {
		# Error checking arguments
		$PluginOutput = $Error;
		$PluginResult = UNKNOWN;
	}
	$Nagios->nagios_exit($PluginResult,$PluginOutput);
}
else {
	# Error parsing command line
	$Nagios->nagios_exit(UNKNOWN,$@);
}

		
	
# FUNCTION DEFINITIONS

# Creates and configures a Nagios plugin object
# Input: strings (usage, version, blurb, license, name and example) to configure argument parsing functionality
# Return value: reference to a Nagios plugin object

sub CreateNagiosManager() {
	# Create GetOpt object
	my $Nagios = Nagios::Plugin->new(usage => $_[0], version =>  $_[1], blurb =>  $_[2], license =>  $_[3], plugin =>  $_[4], extra =>  $_[5]);
	
	# Add argument units
	$Nagios->add_arg(spec => 'units|u=s',
				help => 'Output units based on IEEE 1541 standard. By default in percentage value. Format: unit (default: %)',
				default => '%',
				required => 0);
								
	
	# Add argument percentage threshold
	$Nagios->add_arg(spec => 'perthres|p',
				help => 'Warning and critical thresholds in percentage.',
				required => 0);				
								
	
	# Add argument maxram
	$Nagios->add_arg(spec => 'maxram|m',
				help => 'Show the MaxRam value in perfdata.',
				required => 0);				
	
	# Add argument warning
	$Nagios->add_arg(spec => 'warning|w=s',
				help => "Warning threshold (using selected unit as magnitude). Format: <mem_threshold,app_mem_threshold,cache_threshold,swap_threshold>",
				required => 1);
	# Add argument critical
	$Nagios->add_arg(spec => 'critical|c=s',
				help => "Critical threshold (using selected unit as magnitude). Format: <mem_threshold,app_mem_threshold,cache_threshold,swap_threshold>",
				required => 1);
								
	# Return value
	return $Nagios;
}


# Checks argument values and sets some default values
# Input: Nagios Plugin object
# Output: reference to Error description string, Memory Unit, Swap Unit, reference to WVRange ($_[4]), reference to CVRange ($_[5])
# Return value: True if arguments ok, false if not

sub CheckArguments() {
	my ($Nagios, $Error, $Unit, $ConvertToUnit, $WVRange, $CVRange) = @_;
	my $commas;
	my $units;
	my $i;
	my $firstpos;
	my $secondpos;
	my $flag;
	
	# Check units list
	$units = $Nagios->opts->units;
	if ($units eq "") {
		${$Unit} = "%";
	}
	elsif (!($units =~ /^((B)|(KiB)|(MiB)|(GiB)|(TiB)|(%))$/)){
		${$Error} = "Invalid unit in $units, this must to be percentage or a unit expressed under the IEEE 1541 standard.";
		return 0;
	}
	else {
		${$Unit} = $units;
	}
		
	# Check argument perthres
	if (defined($Nagios->opts->perthres)){
		${ConvertToUnit} = 1;
	}				

	
	# Check Warning thresholds list
	$commas = $Nagios->opts->warning =~ tr/,//; 
	if ($commas !=3){
		${$Error} = "Invalid Warning list format. Three commas are expected.";
		return 0;
	}
	else{
		$i=0;
		$firstpos=0;
		my $warning=$Nagios->opts->warning;
		while ($warning =~ /[,]/g) {
			$secondpos=pos $warning;
			if ($secondpos - $firstpos==1){
				@{$WVRange}[$i] = "~:";
				&FlagSet(0, $i)
			}		
			else{
				@{$WVRange}[$i] = substr $Nagios->opts->warning, $firstpos, ($secondpos-$firstpos-1);
			}
			$firstpos=$secondpos;
			$i++
		}
		if (length($Nagios->opts->warning) - $firstpos==0){#La coma es el ultimo elemento del string
			@{$WVRange}[$i] = "~:";
			&FlagSet(0, $i)
		}
		else{
			@{$WVRange}[$i] = substr $Nagios->opts->warning, $firstpos, (length($Nagios->opts->warning)-$firstpos);
		}	
		
		if (@{$WVRange}[0] !~/^(@?(\d+(\.\d+)?|(\d+|~):(\d+(\.\d+)?)?))?$/){
			${$Error} = "Invalid Memory Warning threshold in @{$WVRange}[0]";
			return 0;
		}if (@{$WVRange}[1] !~/^(@?(\d+(\.\d+)?|(\d+|~):(\d+(\.\d+)?)?))?$/){
			${$Error} = "Invalid Application Memory Warning threshold in @{$WVRange}[1]";
			return 0;
		}
		if (@{$WVRange}[2] !~/^(@?(\d+(\.\d+)?|(\d+|~):(\d+(\.\d+)?)?))?$/){
			${$Error} = "Invalid Cache Warning threshold in @{$WVRange}[2]";
			return 0;
		}
		if (@{$WVRange}[3] !~/^(@?(\d+(\.\d+)?|(\d+|~):(\d+(\.\d+)?)?))?$/){
			${$Error} = "Invalid Swap Warning threshold in @{$WVRange}[3]";
			return 0;
		}
	}
	
	# Check Critical thresholds list
	$commas = $Nagios->opts->critical =~ tr/,//; 
	if ($commas !=3){
		${$Error} = "Invalid Critical list format. Three commas are expected.";
		return 0;
	}
	else{
		$i=0;
		$firstpos=0;
		my $critical=$Nagios->opts->critical;
		while ($critical  =~ /[,]/g) {
			$secondpos=pos $critical ;
			if ($secondpos - $firstpos==1){
				@{$CVRange}[$i] = "~:";
				&FlagSet(1, $i)
			}		
			else{
				@{$CVRange}[$i] =substr $Nagios->opts->critical, $firstpos, ($secondpos-$firstpos-1);
			}
			$firstpos=$secondpos;
			$i++
		}
		if (length($Nagios->opts->critical) - $firstpos==0){#La coma es el ultimo elemento del string
			@{$CVRange}[$i] = "~:";
			&FlagSet(1, $i)
		}
		else{
			@{$CVRange}[$i] = substr $Nagios->opts->critical, $firstpos, (length($Nagios->opts->critical)-$firstpos);
		}		

		if (@{$CVRange}[0] !~/^(@?(\d+(\.\d+)?|(\d+|~):(\d+(\.\d+)?)?))?$/) {
			${$Error} = "Invalid Critical threshold in @{$CVRange}[0]";
			return 0;
		}
		if (@{$CVRange}[1] !~/^(@?(\d+(\.\d+)?|(\d+|~):(\d+(\.\d+)?)?))?$/) {
			${$Error} = "Invalid Application Critical threshold in @{$CVRange}[1]";
			return 0;
		}
		if (@{$CVRange}[2] !~/^(@?(\d+(\.\d+)?|(\d+|~):(\d+(\.\d+)?)?))?$/) {
			${$Error} = "Invalid Cache Critical threshold in @{$CVRange}[2]";
			return 0;
		}
		if (@{$CVRange}[3] !~/^(@?(\d+(\.\d+)?|(\d+|~):(\d+(\.\d+)?)?))?$/) {
			${$Error} = "Invalid Swap Critical threshold in @{$CVRange}[3]";
			return 0;
		}
	}
	
	return 1;
}

# Set the value of the flag to indicate that the values are to be checked
# Input: Warning(0) or Critical(1), Mem
sub FlagSet() {
	my ($WoC, $Mem) = @_;
	
	if ($Mem == 0) {
		$MemFLAGS[$WoC] = 0;
	}
	elsif ($Mem == 1) {
		$AppFLAGS[$WoC] = 0;
	}
	elsif ($Mem == 2) {
		$CacheFLAGS[$WoC] = 0;
	}
	elsif ($Mem == 3) {
		$SwapFLAGS[$WoC] = 0;
	}
}


# Performs whole check: 
# Input: Nagios Plugin object, reference to Plugin output string, Memory Unit, Swap Unit, referece to WVRange, reference to CVRange
# Output: Plugin output string
# Return value: Plugin return value

sub PerformCheck() {
	my ($Nagios, $PluginOutput, $Unit, $ConvertToUnit, $WVRange, $CVRange) = @_;
	my @Request;
	my $ProcMeminfo;
	my $Line;
	my @DataInLine;
	my $MemTotal;
	my $MaxRam;
	my $MemFree;
	my $MemUsed;
	my $MemPercentageUsed;
	my $MemUsedPerfdata;
 	my $MemWarningPerfdata;
 	my $MemCriticalPerfdata;
 	my $MemMaxPerfdata;
	my $Buffers;
	my $SwapCached;
	my $CacheTotal;
	my $CacheFree = 0;
	my $CacheUsed;
	my $CachePercentageUsed;
	my $CacheUsedPerfdata;
 	my $CacheWarningPerfdata;
 	my $CacheCriticalPerfdata;
 	my $CacheMaxPerfdata;
	my $AppMemTotal;
	my $AppMemFree;
 	my $AppMemUsed;
	my $AppMemPercentageUsed;
 	my $AppMemUsedPerfdata;
 	my $AppMemWarningPerfdata;
 	my $AppMemCriticalPerfdata;
 	my $AppMemMaxPerfdata;
	my $SwapTotal;
	my $SwapFree;
	my $SwapUsed;
	my $SwapPercentageUsed;
	my $SwapUsedPerfdata;
 	my $SwapWarningPerfdata;
 	my $SwapCriticalPerfdata;
 	my $SwapMaxPerfdata;
 	my $Colons;
 	my $i;
 	my $firstpos;
 	my $secondpos;
 	my $threshold;
 	my @ThresholdLevels;
 	my $MinPerfdata = 0;
 	my $PerformanceData="";
 	my $MemPluginOutput = "";
 	my $AppMemPluginOutput = "";
 	my $CachePluginOutput = "";
 	my $SwapPluginOutput = "";
 	my $PluginReturnValue = UNKNOWN;
 	my $MemPluginReturnValue;
 	my $AppMemPluginReturnValue;
 	my $CachePluginReturnValue;
 	my $SwapPluginReturnValue;
 	my $OkFlag = 0;
 	my $WarningFlag = 0;
 	my $CriticalFlag = 0;
 	${$PluginOutput}="";
 	
 	# Recovering status memory values
 	$ProcMeminfo = "/proc/meminfo";
 	open(PROCMEMINFO, $ProcMeminfo);
 	while (<PROCMEMINFO>) {
 		$Line = $_;
 		chomp($Line);
 		$Line =~ s/ //g;
 		@DataInLine = split(/:/, $Line);
 		if ($DataInLine[0] eq 'MemTotal') {
 			if( length($DataInLine[1]) > 2) { $MemTotal = substr($DataInLine[1], 0, length($DataInLine[1])-2); }
 			else { $MemTotal = $DataInLine[1]; }
 			$MaxRam = $MemTotal * 1024.0; # The MaxRam in Bytes
 		}
 		if ($DataInLine[0] eq 'MemFree') {
 			if( length($DataInLine[1]) > 2) { $MemFree = substr($DataInLine[1], 0, length($DataInLine[1])-2); }
 			else { $MemFree = $DataInLine[1]; }
 		}
 		if ($DataInLine[0] eq 'Buffers') {
 			if( length($DataInLine[1]) > 2) { $Buffers = substr($DataInLine[1], 0, length($DataInLine[1])-2); }
 			else { $Buffers = $DataInLine[1]; }
 		}
 		if ($DataInLine[0] eq 'Cached') {
 			if( length($DataInLine[1]) > 2) { $CacheUsed = substr($DataInLine[1], 0, length($DataInLine[1])-2); }
 			else { $CacheUsed = $DataInLine[1]; }
 		}
 		if ($DataInLine[0] eq 'SwapCached') {
 			if( length($DataInLine[1]) > 2) { $SwapCached = substr($DataInLine[1], 0, length($DataInLine[1])-2); }
 			else { $SwapCached = $DataInLine[1]; }
 		}
 		if ($DataInLine[0] eq 'SwapTotal') {
 			if( length($DataInLine[1]) > 2) { $SwapTotal = substr($DataInLine[1], 0, length($DataInLine[1])-2); }
 			else { $SwapTotal = $DataInLine[1]; }
 		}
 		if ($DataInLine[0] eq 'SwapFree') {
 			if( length($DataInLine[1]) > 2) { $SwapFree = substr($DataInLine[1], 0, length($DataInLine[1])-2); }
 			else { $SwapFree = $DataInLine[1]; }
 		}
 	}
 	close PROCMEMINFO;
 	
 	# Memory
 	$MemUsed = $MemTotal - $MemFree;
 	# Cache
 	$CacheTotal = $MemTotal;
 	# Memory used by Applications
 	$AppMemTotal = $MemTotal * 0.95;
 	$AppMemUsed = $MemUsed - ($Buffers + $CacheUsed + $SwapCached);
        $AppMemFree = $AppMemTotal - $AppMemUsed;
 	# Swap
 	$SwapUsed = $SwapTotal - $SwapFree;
 	
	# Applying units (the values are recovered in KiB)
	# Memory:
	$MemPercentageUsed = &UnitConversion($Unit, \$MemTotal, \$MemFree, \$MemUsed);
	# If thresholds in percentage and units not in percentage convert thresholds in units
	if (defined($Nagios->opts->perthres)) {
		(@{$WVRange}[0], @{$CVRange}[0]) = &ConversionFromPercentage($Unit, $MemTotal, @{$WVRange}[0], @{$CVRange}[0]);
	}
	($MemUsedPerfdata, $MemWarningPerfdata, $MemCriticalPerfdata, $MemMaxPerfdata) = &PerfdataToBytes($Unit, $MemTotal, $MemFree, $MemUsed, @{$WVRange}[0], @{$CVRange}[0]);
	# Memory used by Applications:
	$AppMemPercentageUsed = &UnitConversion($Unit, \$AppMemTotal, \$AppMemFree, \$AppMemUsed);
	# If thresholds in percentage and units not in percentage convert thresholds in units
	if (defined($Nagios->opts->perthres)) {
		(@{$WVRange}[1], @{$CVRange}[1]) = &ConversionFromPercentage($Unit, $AppMemTotal, @{$WVRange}[1], @{$CVRange}[1]);
	}
	($AppMemUsedPerfdata, $AppMemWarningPerfdata, $AppMemCriticalPerfdata, $AppMemMaxPerfdata) = &PerfdataToBytes($Unit, $AppMemTotal, $AppMemFree, $AppMemUsed, @{$WVRange}[1], @{$CVRange}[1]);
	# Cache:
	$CachePercentageUsed = &UnitConversion($Unit, \$CacheTotal, \$CacheFree, \$CacheUsed);
	# If thresholds in percentage and units not in percentage convert thresholds in units
	if (defined($Nagios->opts->perthres)) {
		(@{$WVRange}[2], @{$CVRange}[2]) = &ConversionFromPercentage($Unit, $CacheTotal, @{$WVRange}[2], @{$CVRange}[2]);
	}
	($CacheUsedPerfdata, $CacheWarningPerfdata, $CacheCriticalPerfdata, $CacheMaxPerfdata) = &PerfdataToBytes($Unit, $CacheTotal, $CacheFree, $CacheUsed, @{$WVRange}[2], @{$CVRange}[2]);
	# Swap:
	$SwapPercentageUsed = &UnitConversion($Unit, \$SwapTotal, \$SwapFree, \$SwapUsed);
	# If thresholds in percentage and units not in percentage convert thresholds in units
	if (defined($Nagios->opts->perthres)) {
		(@{$WVRange}[3], @{$CVRange}[3]) = &ConversionFromPercentage($Unit, $SwapTotal, @{$WVRange}[3], @{$CVRange}[3]);
	}
	($SwapUsedPerfdata, $SwapWarningPerfdata, $SwapCriticalPerfdata, $SwapMaxPerfdata) = &PerfdataToBytes($Unit, $SwapTotal, $SwapFree, $SwapUsed, @{$WVRange}[3], @{$CVRange}[3]);



	if ($MemFLAGS[0] || $MemFLAGS[1]) {
		# Adding (only) memory status to MemPluginOutput
		$MemUsed = sprintf("%.2f", $MemUsed);
		$MemPercentageUsed = sprintf("%.2f", $MemPercentageUsed);
		$MemTotal = sprintf("%.2f", $MemTotal);
		if ($Unit ne "%") {
			$MemPluginOutput .= "Memory usage: $MemUsed$Unit ($MemPercentageUsed%) of $MemTotal$Unit";
		}
		else {
	
			$MemPluginOutput .= "Memory usage: $MemUsed$Unit";
		}
	}
	
	if ($AppFLAGS[0] || $AppFLAGS[1]) {
		# Adding (only) applications memory status to AppMemPluginOutput
		$AppMemUsed = sprintf("%.2f", $AppMemUsed);
                $AppMemPercentageUsed = sprintf("%.2f", $AppMemPercentageUsed);
	        $AppMemTotal = sprintf("%.2f", $AppMemTotal);
		if ($Unit ne "%") {
			$AppMemPluginOutput .= "Application memory usage: $AppMemUsed$Unit ($AppMemPercentageUsed%) of $AppMemTotal$Unit";
		}
		else {
			$AppMemPluginOutput .= "Application memory usage: $AppMemUsed$Unit";
		}
	}
	
	if ($CacheFLAGS[0] || $CacheFLAGS[1]){
		# Adding cache status to CachePluginOutput
		$CacheUsed = sprintf("%.2f", $CacheUsed);
	        $CachePercentageUsed = sprintf("%.2f", $CachePercentageUsed);
	        $CacheTotal = sprintf("%.2f", $CacheTotal);
	        if ($Unit ne "%") {
			$CachePluginOutput .= "Cache usage: $CacheUsed$Unit ($CachePercentageUsed%) of $CacheTotal$Unit";
		}
		else {
			$CachePluginOutput .= "Cache usage: $CacheUsed$Unit";
		}
	}
	
	if ($SwapFLAGS[0] || $SwapFLAGS[1]) {
		# Adding swap status to SwapPluginOutput
		$SwapUsed = sprintf("%.2f", $SwapUsed);
	        $SwapPercentageUsed = sprintf("%.2f", $SwapPercentageUsed);
	        $SwapTotal = sprintf("%.2f", $SwapTotal);
		if ($Unit ne "%") {
			$SwapPluginOutput .= "Swap usage: $SwapUsed$Unit ($SwapPercentageUsed%) of $SwapTotal$Unit";
		}
		else {
			$SwapPluginOutput .= "Swap usage: $SwapUsed$Unit";
		}
	}

	if ($MemFLAGS[0] || $MemFLAGS[1]) {
		# Checking Memory State
		$MemPluginReturnValue = $Nagios->check_threshold(check => $MemUsed,warning => @{$WVRange}[0],critical => @{$CVRange}[0]);
		if ($MemPluginReturnValue eq OK){
			$OkFlag = 1;
			$MemPluginOutput .= ", ";
		}
		elsif ($MemPluginReturnValue eq WARNING) {
			$MemPluginOutput .= " (warning threshold is set to @{$WVRange}[0]$Unit), ";
			$WarningFlag = 1;
		}
		elsif ($MemPluginReturnValue eq CRITICAL) {
			$MemPluginOutput .= " (critical threshold is set to @{$CVRange}[0]$Unit), ";
			$CriticalFlag = 1;
		}
	}

	if ($AppFLAGS[0] || $AppFLAGS[1]) {
		# Checking Applications Memory State
		$AppMemPluginReturnValue = $Nagios->check_threshold(check => $AppMemUsed,warning => @{$WVRange}[1],critical => @{$CVRange}[1]);
		if ($AppMemPluginReturnValue eq OK){
			$OkFlag = 1;
			$AppMemPluginOutput .= ", ";
		}
		elsif ($AppMemPluginReturnValue eq WARNING) {
			$AppMemPluginOutput .= " (warning threshold is set to @{$WVRange}[1]$Unit), ";
			$WarningFlag = 1;
		}
		elsif ($AppMemPluginReturnValue eq CRITICAL) {
			$AppMemPluginOutput .= " (critical threshold is set to @{$CVRange}[1]$Unit), ";
			$CriticalFlag = 1;
		}
	}

	if ($CacheFLAGS[0] || $CacheFLAGS[1]){
		# Checking Cache State
		$CachePluginReturnValue = $Nagios->check_threshold(check => $CacheUsed,warning => @{$WVRange}[2],critical => @{$CVRange}[2]);
		if ($CachePluginReturnValue eq OK){
			$OkFlag = 1;
			$CachePluginOutput .= ", ";
		}
		elsif ($CachePluginReturnValue eq WARNING) {
			$CachePluginOutput .= " (warning threshold is set to @{$WVRange}[2]), ";
			$WarningFlag = 1;
		}
		elsif ($CachePluginReturnValue eq CRITICAL) {
			$CachePluginOutput .= " (critical threshold is set to @{$CVRange}[2]$Unit), ";
			$CriticalFlag = 1;
		}
	}

	if ($SwapFLAGS[0] || $SwapFLAGS[1]) {
		# Checking Swap State
		$SwapPluginReturnValue = $Nagios->check_threshold(check => $SwapUsed,warning => @{$WVRange}[3],critical => @{$CVRange}[3]);
		if ($SwapPluginReturnValue eq OK){
			$OkFlag = 1;
			$SwapPluginOutput .= ", ";
		}
		elsif ($SwapPluginReturnValue eq WARNING) {
			$SwapPluginOutput .= " (warning threshold is set to @{$WVRange}[3]), ";
			$WarningFlag = 1;
		}
		elsif ($SwapPluginReturnValue eq CRITICAL) {
			$SwapPluginOutput .= " (critical threshold is set to @{$CVRange}[3]$Unit), ";
			$CriticalFlag = 1;
		}
	}
	
	# Establishing PluginReturnValue
	if ($CriticalFlag) {
		$PluginReturnValue = CRITICAL;
	}
	elsif ($WarningFlag) {
		$PluginReturnValue = WARNING;
	}
	elsif ($OkFlag) {
		$PluginReturnValue = OK;
	}

	# Adding Memory status tu PluginOutput
	#${$PluginOutput} .= "$MemPluginOutput$AppMemPluginOutput$CachePluginOutput$SwapPluginOutput";
	if ($MemFLAGS[0] || $MemFLAGS[1]) { ${$PluginOutput} .= "$MemPluginOutput"; }
	if ($AppFLAGS[0] || $AppFLAGS[1]) { ${$PluginOutput} .= "$AppMemPluginOutput"; }
	if ($CacheFLAGS[0] || $CacheFLAGS[1]){ ${$PluginOutput} .= "$CachePluginOutput"; }
	if ($SwapFLAGS[0] || $SwapFLAGS[1]) { ${$PluginOutput} .= "$SwapPluginOutput"; }
	
	
	# Adding Performance data to PerformanceData
	if ($MemFLAGS[0] || $MemFLAGS[1]) {
		# Memory performance data
		$PerformanceData .= "MemUsed=$MemUsedPerfdata";
		if ($Unit eq '%') {
			$PerformanceData .= "%;";
		}
		else {
			$PerformanceData .= "B;";
		}
		$PerformanceData .= "$MemWarningPerfdata;$MemCriticalPerfdata;$MinPerfdata;$MemMaxPerfdata";
	}
	if ($AppFLAGS[0] || $AppFLAGS[1]) {
		# Performance data of the Memory used by Applications
		$PerformanceData .= " AppMemUsed=$AppMemUsedPerfdata";
		if ($Unit eq '%') {
			$PerformanceData .= "%;";
		}
		else {
			$PerformanceData .= "B;";
		}
		$PerformanceData .= "$AppMemWarningPerfdata;$AppMemCriticalPerfdata;$MinPerfdata;$AppMemMaxPerfdata";
	}
	if ($CacheFLAGS[0] || $CacheFLAGS[1]){
		# Cache performance data
		$PerformanceData .= " CacheUsed=$CacheUsedPerfdata";
		if ($Unit eq '%') {
			$PerformanceData .= "%;";
		}
		else {
			$PerformanceData .= "B;";
		}
		$PerformanceData .= "$CacheWarningPerfdata;$CacheCriticalPerfdata;$MinPerfdata;$CacheMaxPerfdata";
	}
	if ($SwapFLAGS[0] || $SwapFLAGS[1]) {
		# Swap performance data
		$PerformanceData .= " SwapUsed=$SwapUsedPerfdata";
		if ($Unit eq '%') {
			$PerformanceData .= "%;";
		}
		else {
			$PerformanceData .= "B;";
		}
		$PerformanceData .= "$SwapWarningPerfdata;$SwapCriticalPerfdata;$MinPerfdata;$SwapMaxPerfdata";	 
	}   
	
	# Max Ram performance data
	if (defined($Nagios->opts->maxram)) {
		if ($Unit ne '%') {
			$PerformanceData .= " MaxRam=$MaxRam";
			$PerformanceData .= "B";
		}
	}
	
	
	chop( ${$PluginOutput} );
	chop( ${$PluginOutput} );
	# Output with performance data:
	${$PluginOutput} .= " | $PerformanceData";

 	#${$PluginOutput} = $PluginOutput;
 	return $PluginReturnValue;
}


# Convierte las unidades de las variables
# Input: Unit to be converted, Total, Free, Used
# Return: Percentage used

sub UnitConversion() {
	my ($UnitToConversion, $Total, $Free, $Used) = @_;
	my $PercentageUsed;
	my $ConversionFactor;
	my $TotalDivisor = (${$Total} > 0) ? ${$Total} : 1.0;

	# Calculating the percentage use
	$PercentageUsed = (${$Used} * 100.0) / $TotalDivisor;

	if ($UnitToConversion ne "%") {
		# Applying units (the values are recovered in KiB)
		if ($UnitToConversion eq "B") {
			# Conversion from Kibibytes to Bytes
			$ConversionFactor = 1024.0;
		} # End of treatment Bytes
		elsif ($UnitToConversion eq "KiB") {
			$ConversionFactor = 1.0;
		} # End of treatment Kibibytes
		if ($UnitToConversion eq "MiB") {
			# Conversion from Kibibytes to Mebibytes
			$ConversionFactor = 1.0 / 1024.0;
		} # End of treatment Mebibytes
		if ($UnitToConversion eq "GiB") {
			# Conversion from Kibibytes to Gibibytes
			$ConversionFactor = 1.0 / (1024.0 * 1024.0);
		} # End of treatment Gibibytes
		if ($UnitToConversion eq "TiB") {
			# Conversion from Kibibytes to Tebibytes
			$ConversionFactor = 1.0 / (1024.0 * 1024.0 * 1024);
		} # End of treatment Tebibytes
		
		# Applying the conversion
		${$Total} *= $ConversionFactor;
		${$Free} *= $ConversionFactor;
		${$Used} *= $ConversionFactor;
	}
	else {
		# Conversion from Kibibytes to percentage value
		${$Free} = (${$Free} * 100.0) / $TotalDivisor;
		${$Used} = (${$Used} * 100.0) / $TotalDivisor;
		${$Total} = 100.0;
	} # End of treatment Percentage
	
	return $PercentageUsed;
}


# Convierte las unidades de los umbrales
# Input: Unit to be converted, Total, Warning Thresholds, Critical Thresholds
# Return: Warning and Critical thresholds in units

sub ConversionFromPercentage() {
	my ($Unit, $Total, $WarningThreshold, $CriticalThreshold) = @_;
	my $WarningThresholdInUnits;
	my $CricitalThresholdInUnits;
	my $Colons;
	my $i;
	my $firstpos;
	my $threshold;
	my $secondpos;
	my @ThresholdLevels;
	
	if ($Unit ne "%") {		
			# Establishing both warning and critical perfdata in units
			# Warning
			if( $WarningThreshold ne '~:' || $WarningThreshold ne '@~:' ) {
				$Colons = $WarningThreshold =~ tr/://; 
				if ($Colons !=1){
					$WarningThresholdInUnits = ($Total * $WarningThreshold) / 100.0;
				}
				else {	
					$i=0;
					$firstpos=0;
					$threshold = $WarningThreshold;
					while ($threshold =~ /[:]/g) {
						$secondpos=pos $threshold;
						if ($secondpos - $firstpos==1){
							$ThresholdLevels[$i] = "";
						}		
						else{
							$ThresholdLevels[$i] = substr $WarningThreshold, $firstpos, ($secondpos-$firstpos-1);
						}
						$firstpos=$secondpos;
						$i++
					}
					if (length($WarningThreshold) - $firstpos==0){#La coma es el ultimo elemento del string
						$ThresholdLevels[$i] = "";
					}
					else{
						$ThresholdLevels[$i] = substr $WarningThreshold, $firstpos, (length($WarningThreshold)-$firstpos);
					}
					
					if ($ThresholdLevels[0] ne '~' && $ThresholdLevels[0] ne '@~') {
						$ThresholdLevels[0] = ($Total * $ThresholdLevels[0]) / 100.0;
					}
					if ($ThresholdLevels[1] ne '') {
						$ThresholdLevels[1] = ($Total * $ThresholdLevels[1]) / 100.0;
					}
					$WarningThresholdInUnits = "$ThresholdLevels[0]:$ThresholdLevels[1]";
				}
			}
			# Critical
			if( $CriticalThreshold ne '~:' || $CriticalThreshold ne '@~:' ) {
				$Colons = $CriticalThreshold =~ tr/://; 
				if ($Colons !=1){
					$CricitalThresholdInUnits = ($Total * $CriticalThreshold) / 100.0;
				}
				else {	
					$i=0;
					$firstpos=0;
					$threshold = $CriticalThreshold;
					while ($threshold =~ /[:]/g) {
						$secondpos=pos $threshold;
						if ($secondpos - $firstpos==1){
							$ThresholdLevels[$i] = "";
						}		
						else{
							$ThresholdLevels[$i] = substr $CriticalThreshold, $firstpos, ($secondpos-$firstpos-1);
						}
						$firstpos=$secondpos;
						$i++
					}
					if (length($CriticalThreshold) - $firstpos==0){#La coma es el ultimo elemento del string
						$ThresholdLevels[$i] = "";
					}
					else{
						$ThresholdLevels[$i] = substr $CriticalThreshold, $firstpos, (length($CriticalThreshold)-$firstpos);
					}
					
					if ($ThresholdLevels[0] ne '~' && $ThresholdLevels[0] ne '@~') {
						$ThresholdLevels[0] = ($Total * $ThresholdLevels[0]) / 100.0;
					}
					if ($ThresholdLevels[1] ne '') {
						$ThresholdLevels[1] = ($Total * $ThresholdLevels[1]) / 100.0;
					}
					$CricitalThresholdInUnits = "$ThresholdLevels[0]:$ThresholdLevels[1]";
				}
			}					
	}
	else {
		# Establishing both warning and critical perfdata
	 	$WarningThresholdInUnits = $WarningThreshold;
	 	$CricitalThresholdInUnits = $CriticalThreshold;
	} # End of treatment Percentage
	
	return ($WarningThresholdInUnits, $CricitalThresholdInUnits);
}


# Inicializa las variables de Perfdata en Bytes
# Input: Unit to convert from, Total, Free, Used, Warning threshold, Critical threshold
# Return: UsedPerfdata, WarningPerfdata, CriticalPerfdata, MaxPerfdata

sub PerfdataToBytes() {
	my ($UnitToConvertFrom, $Total, $Free, $Used, $WarningThreshold, $CriticalThreshold) = @_;
	my $ConversionFactor;
	my $UsedPerfdata;
	my $WarningPerfdata;
	my $CriticalPerfdata;
	my $MaxPerfdata;
	my $Colons;
	my $i;
	my $firstpos;
	my $threshold;
	my $secondpos;
	my @ThresholdLevels;
	
	$Used = sprintf("%.2f", $Used);
	if ($UnitToConvertFrom ne "%") {
		# Applying units (the values are recovered in KiB)
		# Performance data needed in Bytes
		if ($UnitToConvertFrom eq "B") {
			# Conversion from Kibibytes to Bytes
			$ConversionFactor = 1.0;
		} # End of treatment Bytes
		elsif ($UnitToConvertFrom eq "KiB") {
			$ConversionFactor = 1024.0;
		} # End of treatment Kibibytes
		if ($UnitToConvertFrom eq "MiB") {
			# Conversion from Kibibytes to Mebibytes
			$ConversionFactor = 1024.0 * 1024.0;
		} # End of treatment Mebibytes
		if ($UnitToConvertFrom eq "GiB") {
			# Conversion from Kibibytes to Gibibytes
			$ConversionFactor = 1024.0 * 1024.0 * 1024.0;
		} # End of treatment Gibibytes
		if ($UnitToConvertFrom eq "TiB") {
			# Conversion from Kibibytes to Tebibytes
			$ConversionFactor = 1024.0 * 1024.0 * 1024.0;
		} # End of treatment Tebibytes
		
		
		if ($UnitToConvertFrom eq "B") {
			$MaxPerfdata = $Total;
			$UsedPerfdata = $Used;
			# Establishing both warning and critical perfdata
		 	$WarningPerfdata = $WarningThreshold;
		 	$CriticalPerfdata = $CriticalThreshold;		
		} # End of treatment Bytes
		else {
			$MaxPerfdata = $Total * $ConversionFactor;
			$UsedPerfdata = $Used * $ConversionFactor;
			# Establishing both warning and critical perfdata
			# Warning
			if( $WarningThreshold ne '~:' || $WarningThreshold ne '@~:' ) {
				$Colons = $WarningThreshold =~ tr/://; 
				if ($Colons !=1){
					$WarningPerfdata = $WarningThreshold * $ConversionFactor;
				}
				else {	
					$i=0;
					$firstpos=0;
					$threshold = $WarningThreshold;
					while ($threshold =~ /[:]/g) {
						$secondpos=pos $threshold;
						if ($secondpos - $firstpos==1){
							$ThresholdLevels[$i] = "";
						}		
						else{
							$ThresholdLevels[$i] = substr $WarningThreshold, $firstpos, ($secondpos-$firstpos-1);
						}
						$firstpos=$secondpos;
						$i++
					}
					if (length($WarningThreshold) - $firstpos==0){#La coma es el ultimo elemento del string
						$ThresholdLevels[$i] = "";
					}
					else{
						$ThresholdLevels[$i] = substr $WarningThreshold, $firstpos, (length($WarningThreshold)-$firstpos);
					}
					
					if ($ThresholdLevels[0] ne '~' && $ThresholdLevels[0] ne '@~') {
						$ThresholdLevels[0] *= $ConversionFactor;
					}
					if ($ThresholdLevels[1] ne '') {
						$ThresholdLevels[1] *= $ConversionFactor;
					}
					$WarningPerfdata = "$ThresholdLevels[0]:$ThresholdLevels[1]";
				}
			}
			# Critical
			if( $CriticalThreshold ne '~:' || $CriticalThreshold ne '@~:' ) {
				$Colons = $CriticalThreshold =~ tr/://; 
				if ($Colons !=1){
					$CriticalPerfdata = $CriticalThreshold * $ConversionFactor;
				}
				else {	
					$i=0;
					$firstpos=0;
					$threshold = $CriticalThreshold;
					while ($threshold =~ /[:]/g) {
						$secondpos=pos $threshold;
						if ($secondpos - $firstpos==1){
							$ThresholdLevels[$i] = "";
						}		
						else{
							$ThresholdLevels[$i] = substr $CriticalThreshold, $firstpos, ($secondpos-$firstpos-1);
						}
						$firstpos=$secondpos;
						$i++
					}
					if (length($CriticalThreshold) - $firstpos==0){#La coma es el ultimo elemento del string
						$ThresholdLevels[$i] = "";
					}
					else{
						$ThresholdLevels[$i] = substr $CriticalThreshold, $firstpos, (length($CriticalThreshold)-$firstpos);
					}
					
					if ($ThresholdLevels[0] ne '~' && $ThresholdLevels[0] ne '@~') {
						$ThresholdLevels[0] *= $ConversionFactor;
					}
					if ($ThresholdLevels[1] ne '') {
						$ThresholdLevels[1] *= $ConversionFactor;
					}
					$CriticalPerfdata = "$ThresholdLevels[0]:$ThresholdLevels[1]";
				}
			}					
		} # End of treatment of other
	}
	else {
		# Conversion from Kibibytes to percentage value
		# Performance data needed in percentage value
		$MaxPerfdata = 100.0;
		$UsedPerfdata = $Used;
		# Establishing both warning and critical perfdata
	 	$WarningPerfdata = $WarningThreshold;
	 	$CriticalPerfdata = $CriticalThreshold;
	} # End of treatment Percentage
	
	return ($UsedPerfdata, $WarningPerfdata, $CriticalPerfdata, $MaxPerfdata);
}
