################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class apt {
  notice(">>> apt class <<<")
  notify{"class apt": }
  tag("safe")

  $aptpackages = [
    "apt",
    "apt-utils",
    "aptitude",
  ]
  package { $aptpackages: ensure => latest }

  exec { "apt-update":
    command     => "apt-get update",
    refreshonly => true;
  }

  file { "apt_example.list":
    path    => "/etc/apt/sources.list.d/example.list",
    source  => $::lsbdistcodename ? {
      "precise" => "puppet:///modules/base/apt_example.precise",
      "lucid"   => "puppet:///modules/base/apt_example.lucid",
      "squeeze" => "puppet:///modules/base/apt_example.squeeze",
      "lenny"   => "puppet:///modules/base/apt_example.lenny",
      #for any broken hosts out there, like opsgraph.dc
      default   => "puppet:///modules/base/apt_example.lucid",
    },
    owner => 'root',
    group => 'root',
    mode  => '0644',
    notify => Exec["apt-update"],
  }

  #TODO - manage /etc/apt/sources.list by distro+pop

  file { "apt_percona.list":
    path    => "/etc/apt/sources.list.d/percona.list",
    ensure  => absent,
# SWITCHED to install Percona from apt.example.com ONLY
#    source  => $::lsbdistcodename ? {
#      "lenny"    => "puppet:///modules/base/apt_percona.lenny",
#      "squeeze"  => "puppet:///modules/base/apt_percona.squeeze",
#      "lucid"    => "puppet:///modules/base/apt_percona.lucid",
#      "precise"  => "puppet:///modules/base/apt_percona.precise",
#      default    => "puppet:///modules/base/apt_percona.precise",
#    },
#    owner => 'root',
#    group => 'root',
#    mode  => '0644',
    notify => Exec["apt-update"],
  }

  file { "apt_mongodb.list":
    path    => "/etc/apt/sources.list.d/mongodb.list",
    ensure  => absent,
# SWITCHED to install Percona from apt.example.com ONLY
#    source  => $::lsbdistcodename ? {
#      default     => "puppet:///modules/base/apt_mongodb.list",
#    },
#    owner => 'root',
#    group => 'root',
#    mode  => '0644',
    notify => Exec["apt-update"],
  }
  ## EXECS - trigger gpg key updates on apt repo updates
  exec {"example-apt-gpgkeys":
    command => "wget http://apt.example.com/gpg.key -O - | apt-key add -",
    refreshonly => true,
    subscribe => File["apt_example.list"],
  }
  exec {"mongodb-apt-gpgkeys":
    command => "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10",
    refreshonly => true,
    subscribe => File["apt_mongodb.list"],
  }
  exec {"percona-apt-gpgkeys":
    command => "gpg --keyserver pgpkeys.mit.edu --recv-key 1C4CBDCDCD2EFD2A && gpg -a --export 1C4CBDCDCD2EFD2A | apt-key add -",
    refreshonly => true,
    subscribe => File["apt_percona.list"],
  }


}

#######################################################
