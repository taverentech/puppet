#######################################################
# Base environment configurations
#   Things will likely start here, then move to their own module


# NTP client
#  TODO: on VMs rather than run ntpclient, sync VM to host clock->ntp

class base::ntpclient {
  notice(">>> ntpclient class <<<")
  notify{"class ntpclient": }

  ## PACKAGEs
  package { "ntp": ensure => installed }

#temp disable this on test machines that need clock to be wrong
if ( $::fqdn != "rcct114.sjc1.eng.example1.com" and $::fqdn != "rcct115.sjc1.eng.example1.com" and $::fqdn != "rcct116.sjc1.eng.example1.com" ) {
  ## SERVICEs
  service { "ntp":
    name => $operatingsystem ? {
      Debian => "ntp",
      Ubuntu => "ntp",
      default => "ntp",
    },
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require => Package["ntp"],
  }

  ## FILEs
  # ntp client /etc/ntp.conf, ntp server is /etc/ntp/ntp.conf
  file { "ntp.conf":
    path => "/etc/ntp.conf",
    ensure => file,
    source => [
      "puppet:///modules/base/ntp.conf_$::nodetype",
      "puppet:///modules/base/ntp.conf_$::pop",
      "puppet:///modules/base/ntp.conf_iad1",
    ],
    owner => 'root', group => 'root', mode => '0644',
    backup => ".$::timestamp",
    notify => Service["ntp"],
  }
}
}
