################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class nagios {
  notice(">>> nagios.pp <<<")
  notify{"Loading nagios class": }

  tag("base")
  tag("safe")
  tag("nagios")

  ##PACKAGES
  package { "nagios-nrpe-server": ensure => latest }
  package { "nagios-plugins-basic": ensure => installed }
  # Everything except Debian 5
  if ($::lsbdistcodename == "precise") {
    package { "libnagios-plugin-perl": ensure => installed }
    package { "nagios-plugins-standard": ensure => installed }
  } elsif ($::lsbdistcodename == "lucid") {
    package { "libnagios-plugin-perl": ensure => installed }
  } elsif ($::lsbdistcodename == "squeeze") {
    package { "libnagios-plugin-perl": ensure => installed }
  }


  ##FILES
  # Copy entire directory of plugins down
  file { "/usr/lib/nagios/plugins/":
    ensure  => directory,
    recurse => true,
    source  => "puppet:///modules/nagios/plugins/",
    ignore  => ".svn",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    backup  => ".$::timestamp",
    require => Package["nagios-nrpe-server"],
  }

  # This version supports status - broken on older builds
  file { "init.d_nagios-nrpe-server":
    source => [
      "puppet:///modules/nagios/init.d_nagios-nrpe-server",
    ],
    path  => "/etc/init.d/nagios-nrpe-server",
    owner => root,
    group => root,
    mode => 755,
    backup => ".$::timestamp",
    notify => Service[ "nagios-nrpe-server" ],
    require => Package["nagios-nrpe-server"],
  }

  file { "nrpe.cfg":
    source => [
      "puppet:///modules/nagios/nrpe.cfg_$::fqdn",
      "puppet:///modules/nagios/nrpe.cfg_$::nodetype",
      "puppet:///modules/nagios/nrpe.cfg",
    ],
    path => "/etc/nagios/nrpe.cfg",
    owner => root,
    group => root,
    mode => 444,
    backup => ".$::timestamp",
    notify => Service[ "nagios-nrpe-server" ],
    require => Package["nagios-nrpe-server"],
  }

  file { "nrpe_local.cfg":
    source => [
      "puppet:///modules/nagios/nrpe_local.cfg_$::fqdn",
      "puppet:///modules/nagios/nrpe_local.cfg_$::nodetype",
      "puppet:///modules/nagios/nrpe_local.cfg",
    ],
    path  => "/etc/nagios/nrpe_local.cfg",
    owner => root,
    group => root,
    mode => 444,
    backup => ".$::timestamp",
    links => follow,
    notify => Service[ "nagios-nrpe-server" ],
    require => Package["nagios-nrpe-server"],
  }

  # Copy this entire directory of nrpe.d down
  file { "/etc/nagios/nrpe.d/":
    ensure  => directory,
    recurse => true,
    source  => "puppet:///modules/nagios/nrpe.d/",
    ignore  => ".svn",
    owner   => 'root',
    group   => 'root',
    mode    => '0644', # puppet 'should' chmod +x on the dir
    backup  => ".$::timestamp",
    notify => Service[ "nagios-nrpe-server" ],
    require => Package["nagios-nrpe-server"],
  }

  ##SERVICES
  service { "nagios-nrpe-server":
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require => [
      File["nrpe.cfg"],
      File["nrpe_local.cfg"],
      File["init.d_nagios-nrpe-server"],
    ]
  }

}
