#!/usr/bin/perl -w

# check_quota.pl Copyright (C) 2011 Frederic Krueger <igetspam@bigfoot.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# you should have received a copy of the GNU General Public License
# along with this program (or with Nagios);  if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA

# Tell Perl what we need to use
use strict;
use Getopt::Std;

use vars qw($opt_a $opt_g $opt_u $opt_v $opt_h $opt_p
            $username $groupname $quota_status $quota_inuse $quota_softlimit $quota_hardlimit
            %exit_codes @rqout @outlist
            $verb_err $out);

$username = "";

# Predefined exit codes for Nagios
%exit_codes   = ('UNKNOWN' ,-1,
                 'OK'      , 0,
                 'WARNING' , 1,
                 'CRITICAL', 2,);

our $bin_repquota = "/usr/sbin/repquota";
if ((!defined($bin_repquota)) or (! -e $bin_repquota))
  { $bin_repquota = `which repquota 2>/dev/null`;	chomp ($bin_repquota); }

# Turn this to 1 to see reason for parameter errors (if any)
$verb_err     = 0;



if ($#ARGV < 0)
{
  &usage;
}
else
{
  getopts('ag:u:p');
}




#
# args
#

our $addperfdata = 0;	# dont add perfdata by default
if (defined($opt_p))
{
  $addperfdata = 1;
}


our $quotapath = "";
if ( (defined($opt_g)) and ($opt_g ne "") )
{
  $groupname = $opt_g;
  if ($groupname =~ /^([^:]+):(.*)$/)
  {
    $groupname = $1;
    $quotapath = $2;
  }
  $groupname =~ s/[^0-9_a-zA-Z]//isg;
}


if ( (defined($opt_u)) and ($opt_u ne "") )
{
  $username = $opt_u;
  if ($username =~ /^([^:]+):(.*)$/)
  {
    $username = $1;
    $quotapath = $2;
  }
  $username =~ s/[^0-9_a-zA-Z]//isg;
}


#
# main
#

my @rqout = ();
if (((defined($username)) and ($username ne "")) or (defined($opt_a)))
{
  my $cmd = "$bin_repquota -v -s -u" . ($quotapath ne "" ? " $quotapath" : " -a");
  @rqout      = split /\n/, `$cmd`;
}
elsif ((defined($groupname)) and ($groupname ne ""))
{
  my $cmd = "$bin_repquota -v -s -g" . ($quotapath ne "" ? " $quotapath" : " -a");
  @rqout      = split /\n/, `$cmd`;	# only /daten/public/ for now
}
else
{
  &usage();
}


# parsing

my $perfdata = "";

foreach my $line (@rqout)
{
  if (defined($opt_a))
  {
    $opt_u = "";	# set to defined
  }
  elsif (defined($opt_u))
  {
    next if (($username ne "") and ($line !~ /$username/i));
  }
  elsif (defined($opt_g))
  {
    next if (($groupname ne "") and ($line !~ /$groupname/i));
  }

  my @dat = split /\s+/, $line;
  next if (($#dat < 7) or ($dat[4] !~ /^\d+/));

  ($username, $quota_status, $quota_inuse, $quota_softlimit, $quota_hardlimit) = ( $dat[0], $dat[1], $dat[2], $dat[3], $dat[4] );

  # convert input \d+G by \d+M (but without the M)
  $quota_inuse = ($quota_inuse =~ /^(.*)G$/i) ? $1*1024*1024*1024 : ($quota_inuse =~ /^(.*)M$/i) ? $1*1024*1024 : ($quota_inuse =~ /^(.*)k$/i) ? $1*1024 : $quota_inuse;
  $quota_softlimit = ($quota_softlimit =~ /^(.*)G$/i) ? $1*1024*1024*1024 : ($quota_softlimit =~ /^(.*)M$/i) ? $1*1024*1024 : ($quota_softlimit =~ /^(.*)k$/i) ? $1*1024 : $quota_softlimit;
  $quota_hardlimit = ($quota_hardlimit =~ /^(.*)G$/i) ? $1*1024*1024*1024 : ($quota_hardlimit =~ /^(.*)M$/i) ? $1*1024*1024 : ($quota_hardlimit =~ /^(.*)k$/i) ? $1*1024 : $quota_hardlimit;

  if ((defined($quota_status)) and (defined($quota_hardlimit)) and ($quota_hardlimit > 1))
  {
    my $retcode = $exit_codes {'UNKNOWN'};
    $quota_status = "OK"		if ($quota_status eq "--");
    $quota_status = "WARNING"	if ($quota_status eq "-+");
    $quota_status = "WARNING"	if ($quota_status eq "+-");
    $quota_status = "CRITICAL"	if ($quota_status eq "++");

    $retcode = $exit_codes{$quota_status};

    if ((defined($opt_u)) and (defined($username)))
    {
      $perfdata .= "user_$username=$quota_inuse;$quota_softlimit;$quota_hardlimit;0; ";
      push @outlist, [ $retcode, sprintf ("%s - %iM / %iM (login: %s)", $quota_status, $quota_inuse/1024/1024, $quota_hardlimit/1024/1024, $username) ];
    }
    elsif (defined($opt_g))	# opt_g
    {
      $perfdata .= "group_$username=${quota_inuse};$quota_softlimit;$quota_hardlimit;0; ";
      push @outlist, [ $retcode, sprintf ("%s - %iM / %iM (group: %s)", $quota_status, $quota_inuse/1024/1024, $quota_hardlimit/1024/1024, $username) ];
    }
  }
}



my $last_exitcode = $exit_codes {'UNKNOWN'};
my $quotafound	= 0;
my $hadoutput = 0;

my $firstlineprinted = 0;
foreach my $out (@outlist)
{
  $quotafound = 1;  $hadoutput = 1;
  if ($last_exitcode < $$out[0]) { $last_exitcode = $$out[0]; }
  print "$$out[1]";
  if ($addperfdata) { if (!$firstlineprinted) { print " | $perfdata"; $firstlineprinted=1; } }
  print "\n";
#  print "got exitcode $$out[0] with data '$$out[1]'\n";
}


my $entfound = 1;		# provide entityfound = yes in case of option "-all" is set
if (! defined($opt_a))
{
  $entfound = ((defined($opt_u)) or (defined($opt_a))) ? (getpwnam ($opt_u)) : (getgrnam ($opt_g));
}


if (! $hadoutput)
{
  if (defined($opt_u))
  {
    if (!$entfound)
    {
      print "UNKNOWN - No such user '$opt_u'\n";
    }
    else
    {
      print "UNKNOWN - No quota for user '$opt_u'\n";
    }
  } # end if user
  elsif (defined($opt_g))
  {
    if (!$entfound)
    {
      print "UNKNOWN - No such group '$opt_g'\n";
    }
    else
    {
      print "UNKNOWN - No quota for group '$opt_g'\n";
    }
  } # end if group
} # end if no userfound or no quotafound


exit $last_exitcode;










# Show usage
sub usage()
{
  print "\ncheck_quota.pl v0.22 - Nagios Plugin\n\n";
  print "usage:\n";
  print " check_quota.pl [-a] [-u <username>] [-g <groupname>]\n\n";
  print "options:\n";
  print " -a           check quota for all users\n";
  print " -g           check quota for a specific group\n";
  print " -u           check quota for a specific user\n";
  print " -p           add perfdata\n";
  print "\nCopyright (C) 2011 Frederic Krueger <igetspam\@bigfoot.com>\n";
  print "check_quota.pl comes with absolutely NO WARRANTY either implied or explicit\n";
  print "This program is licensed under the terms of the\n";
  print "GNU General Public License (check source code for details)\n";
  exit $exit_codes{'UNKNOWN'};
}

