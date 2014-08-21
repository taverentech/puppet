#######################################################
# Base environment configurations
#   Things will likely start here, then move to their own module


# NTP client
#  NOTE: on VMs shouldn't run ntpclient, sync VM to host 

class ntpclient {
  notice(">>> ntpclient class <<<")
  notify{"class ntpclient": }
  tag("safe")

  #TODO install ntp client config
  package { "ntp": ensure => installed }
  service { "ntp":
    name => $operatingsystem ? {
      CentOS => "ntp",
      default => "ntp",
    },
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require => Package["ntp"],
  }

}
