################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class sudo {
  notice(">>> sudo class <<<")
  notify{"class sudo": }
  tag("accounts")

  package { sudo: ensure => latest }

  ##FILES
  file { "sudoers":
    path    => "/etc/sudoers",
    backup => ".$::timestamp",
    owner   => root,
    group   => root,
    mode    => 440,
  }
  file { "sudoers.pending":
    path    => "/etc/sudoers.pending",
    owner   => root,
    group   => root,
    mode    => 440,
    source  => [
      "puppet:///modules/base/sudoers_$::fqdn",
      "puppet:///modules/base/sudoers_$::nodetype.$::environment",
      "puppet:///modules/base/sudoers_$::nodetype",
      "puppet:///modules/base/sudoers",
    ],
    require => File["sudoers.d"],
  }
  file { "sudoers.d":
    path    => "/etc/sudoers.d",
    ensure  => directory,
    recurse => true,
    owner   => root,
    group   => root,
    require => Package["sudo"],
  }
  # Trigger refersh of /etc/sudoers if new /etc/sudoers.pending passes sanity check
  exec { "update-sudoers":
    command => "cp -p /etc/sudoers.pending /etc/sudoers",
    refreshonly => true,
    onlyif    => "visudo -c -f /etc/sudoers.pending",
    subscribe => [ File["sudoers.pending"], ], 
  }
}

