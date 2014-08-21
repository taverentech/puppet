################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class base::nrpe {

 notice(">>> base::nrpe.pp <<<")
 notify{"Loading base::nrpe class": }

 # Skip opsview poc, nagios agent conflicts
 if ( $::fqdn != "blade4-13.sql1.eng.example1.com" ) {

  ##PACKAGES
  $nrpepkgs = [
    "nagios-nrpe-server",
    "nagios-plugins",
    "nagios-plugins-basic",
    "nagios-plugins-standard",
    "libnagios-plugin-perl",
  ]
  package { $nrpepkgs: ensure => installed }


  ##FILES

  # Copy entire directory of plugins down
  file { "nrpe-plugins-dir":
    path    => "/usr/lib/nagios/plugins",
    source  => "puppet:///modules/base/nrpe/plugins/",
    ensure  => directory,
    recurse => true,
    owner   => 'root', group   => 'root', mode    => '0755',
    backup  => ".$::timestamp",
    require => Package["nagios-nrpe-server"],
  }

  #precreate pid dir
  file { "nrpe-pid-dir":
    path    => "/var/run/nagios",
    ensure  => directory,
    recurse => true,
    owner   => 'nagios', group   => 'nagios', mode    => '0644',
    require => Package["nagios-nrpe-server"],
  }

  # This version supports status - broken on older builds
  file { "init.d_nagios-nrpe-server":
    path  => "/etc/init.d/nagios-nrpe-server",
    source => [
      "puppet:///modules/base/nrpe/init.d_nagios-nrpe-server",
    ],
    replace => "no", #TODO remove later after rationalizing
    owner => root, group => root, mode => 755,
    backup => ".$::timestamp",
    notify => Service[ "nagios-nrpe-server" ],
    require => Package["nagios-nrpe-server"],
  }

  file { "nrpe.cfg":
    path => $osfamily ? {
      Debian  => "/etc/nagios/nrpe.cfg",
      default => "/etc/nagios/nrpe.cfg",
    },
    source => [
      "puppet:///modules/base/nrpe/nrpe.cfg_$::fqdn",
      "puppet:///modules/base/nrpe/nrpe.cfg_$::pop",
      "puppet:///modules/base/nrpe/nrpe.cfg",
    ],
    owner => root, group => root, mode => 444,
    backup => ".$::timestamp",
    notify => Service[ "nagios-nrpe-server" ],
    require => Package["nagios-nrpe-server"],
  }

  file { "nrpe_local.cfg":
    path  => "/etc/nagios/nrpe_local.cfg",
    source => [
      "puppet:///modules/base/nrpe/nrpe_local.cfg_$::fqdn",
      "puppet:///modules/base/nrpe/nrpe_local.cfg_$::pop",
      "puppet:///modules/base/nrpe/nrpe_local.cfg",
    ],
    owner => root, group => root, mode => 444,
    backup => ".$::timestamp",
    links => follow,
    notify => Service[ "nagios-nrpe-server" ],
    require => Package["nagios-nrpe-server"],
  }

  # Copy this entire directory of nrpe.d down
  file { "/etc/nagios/nrpe.d/":
    ensure  => directory,
    recurse => true,
    source  => "puppet:///modules/base/nrpe/nrpe.d/",
    # puppet 'should' chmod +x on the dir
    owner   => 'root', group   => 'root', mode    => '0644', 
    backup  => ".$::timestamp",
    notify => Service[ "nagios-nrpe-server" ],
    require => Package["nagios-nrpe-server"],
  }

  #/etc/sudoers.d/nrpe is defined in sudo.pp

  ##SERVICES
  service { "nagios-nrpe-server":
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require => [
      File["init.d_nagios-nrpe-server"],
      File["nrpe.cfg"],
      File["nrpe_local.cfg"],
      File["nrpe-plugins-dir"],
    ]
  }

 } # end of if not host

}
