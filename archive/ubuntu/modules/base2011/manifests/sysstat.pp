################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class sysstat {
  notice(">>> sysstat class <<<")
  notify{"class sysstat": }
  tag("safe")

  package { "sysstat": ensure => installed }

  file { "/etc/cron.d/sysstat":
    source  => "puppet:///modules/base/sysstat_cron.d",
    owner => 'root',
    group => 'root',
    mode  => '0644',
    require => Package["sysstat"],
    notify => Service["sysstat"],
  }

  file { "/etc/init.d/sysstat":
    source  => "puppet:///modules/base/sysstat_init.d",
    owner => 'root',
    group => 'root',
    mode  => '0755',
    require => Package["sysstat"],
    notify => Service["sysstat"],
  }

  file { "/etc/default/sysstat":
    source  => "puppet:///modules/base/sysstat_default",
    owner => 'root',
    group => 'root',
    mode  => '0644',
    require => Package["sysstat"],
    notify => Service["sysstat"],
  }

  service { "sysstat":
    enable => true,
    require => Package["sysstat"],
  }

}

#######################################################
