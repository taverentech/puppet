################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class motd {

  notice(">>> motd class <<<")
  notify{"class motd": }
  tag("safe")

  # Install - used by motd
  package { "toilet": ensure => installed }
  package { "figlet": ensure => installed }

  file { "/etc/motd":
    ensure => symlink,
    target => "/etc/motd.example",
  }

  file { "/etc/motd.tail":
    ensure => absent,
  }

  # Make a copy of /etc/hostname to trigger rebuild of MOTD
  file { "motd.hostname":
    path    => "/etc/motd.hostname",
    source  => "/etc/hostname",
  }

  file { "motd.example":
    path    => "/etc/motd.example",
    owner   => root,
    group   => root,
    mode    => 644,
  }

  file { "build_motd.sh":
    path    => "/usr/local/bin/build_motd.sh",
    owner   => root,
    group   => root,
    mode    => 554,
    source  => "puppet:///modules/base/build_motd.sh",
    require => Package["toilet","figlet"],
  }

  # Trigger refersh of /etc/motd.example if hostname or build_motd changes
  exec { "build_motd":
    command => "build_motd.sh",
    refreshonly => true,
    subscribe => [ File["motd.hostname"], File["build_motd.sh"] ], 
  }

}
