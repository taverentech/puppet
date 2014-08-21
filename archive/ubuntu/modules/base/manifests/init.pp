################################################################
# Base environment configurations
# Things will likely start here, then move to their own module

################################################################
# Full base environment configurations
class base {
  notify{"base init.pp": }
  notify{"Loading base class": }
  tag("full")

  # SEE http://confluence/Puppet+Base

  # All flavors of linux
  include base::puppet		# ALL systems for inventory
  # Ubuntu maverick 10.xx OR precise 12.04
  #   WARNING: includes 3 of 6 admin hosts
  if ( $::lsbdistcodename == "precise"  or
       $::lsbdistcodename == "maverick") {
    include base::backuppc
    include base::lscripts
    include base::example1
    include base::profile
    include base::root		# root crypt string in shadow
    include base::rootkeys	# root ssh keys add/remove specific entries
    include base::rsyslog
    include base::snmp
    include base::timezone	# UTC for all per Chris
    include base::security_limits # does not apply to upstart scripts
    include base::scheduler	# Kernel/Disk scheduler set to deadline
    include base::ssh
    include base::sudo
    include base::sysctl	# Updates values with augeas
    include base::sysstat
  }
  # Ubuntu precise 12.04 only
  if ( $::lsbdistcodename == "precise" ) {
    include base::apt
    include base::autofs
    include base::packages
    include base::bluetooth
    include base::cron
    include base::dyncfg
    include base::fstab
    include base::grub
    include base::ipmi
    include base::network
    include base::nrpe
    include base::nscd		# cache host,user,group
    include base::ntpclient
    include base::ldap
    include base::perfstats	# Environment specific
  } # end of if precise

} # end of class
