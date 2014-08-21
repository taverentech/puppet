#######################################################
# Base environment configurations
#   Things will likely start here, then move to their own module


# NTP client
#  NOTE: on VMs shouldn't run ntpclient, sync VM to host 

class ntpclient {
  notice(">>> ntpclient class <<<")
  notify{"class ntpclient": }
  tag("safe")

  ##TODO only if you REALLY want to
  include ntpclient::leapsecfix

  #TODO install ntp client config
  package { "ntp": ensure => installed }
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

}

class ntpclient::leapsecfix {

  exec { "leap_second_quickfix":
    command => 'service ntp stop; date -s "`date`" > /tmp/leapsecond_2012_06_30 2>&1; service ntp start',
    creates => "/tmp/leapsecond_2012_06_30",
  }

}
