#######################################################
# ActiveMQ

class activemq {

  include java::openjre6

  notify{"Loading activemq class": }

  ## Packages
  $activemqpackages = [
    "activemq",
  ]
  package { $activemqpackages: 
    ensure => installed,
    require => [ User["activemq"], Group["activemq"], Package["openjdk-6-jre"], ],
  }

  ## Files
  #TODO need /etc/activemq/instances-available/
  #file { "/etc/activemq/activemq.xml":
  #  source => "puppet:///modules/activemqcfg/activemq.xml",
  #  owner => root,
  #  group => root,
  #  mode => 444,
  #  notify => Service["activemq"],
  #}

  ## Services
  service { "activemq":
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Package["activemq"],
  }

  ## User/group
  group { "activemq": gid => 4112, }
  user { "activemq":
    comment => "Active MQ",
    home    => "/var/lib/activemq",
    shell   => "/bin/false",
    gid     => 4112,
    uid     => 4112,
  }
  file { "/var/lib/activemq":
    ensure  => directory,
    owner   => "activemq",
    group   => "activemq",
    mode    => 755,
    require => [ User["activemq"], Group["activemq"] ],
  }

}
