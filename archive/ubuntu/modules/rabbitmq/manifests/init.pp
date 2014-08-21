#######################################################
# RabbitMQ
#   http://www.rabbitmq.com/install-debian.html

#import "*.pp" - only if we have another manifests in same dir

class rabbitmq {
  notify{"Loading rabbitmq class": }
  tag("rabbitmq")

  ## USERS and GROUPS
  user { "rabbitmq" :
    comment => "RabbitMQ",
    home    => "/var/lib/rabbitmq",
    shell   => "/bin/false",
    gid     => 4005,
    uid     => 4005,
    require => [ Group["rabbitmq"] ],
  }

  group { "rabbitmq" : gid    => 4005, }

  ## PACKAGES
  package { "rabbitmq": 
    name    => "rabbitmq-server",
    ensure  => "2.8.4-1", 
    require => [ User["rabbitmq"], Group["rabbitmq"], ],
  }

  ## FILES
  # datadir
  file { "/var/lib/rabbitmq" :
    ensure  => directory,
    owner   => "rabbitmq",
    group   => "rabbitmq",
    mode    => 755,
    require => [ User["rabbitmq"], Group["rabbitmq"] ],
  }
  # logdir and logs
  file { "/var/log/rabbitmq" :
    ensure  => directory,
    owner   => "rabbitmq",
    group   => "rabbitmq",
    mode    => 755,
    require => [ User["rabbitmq"], Group["rabbitmq"] ],
  }
  file { "/var/log/rabbitmq/rabbitmq@${::hostname}.log" :
    ensure  => present,
    owner   => "rabbitmq",
    group   => "rabbitmq",
    mode    => 644,
    require => [ File["/var/log/rabbitmq"], ],
  }
  file { "/var/log/rabbitmq/rabbitmq@${::hostname}-sasl.log" :
    ensure  => present,
    owner   => "rabbitmq",
    group   => "rabbitmq",
    mode    => 644,
    require => [ File["/var/log/rabbitmq"], ],
  }
  #configurations
  file { "rabbitmq" :
    path    => "/etc/rabbitmq",
    ensure  => directory,
    owner   => "root",
    group   => "root",
    mode    => 755,
    require => [ User["rabbitmq"], Group["rabbitmq"], ],
    #require => [ User["rabbitmq"], Group["rabbitmq"], Package["rabbitmq"], ],
  }
  file { "rabbitmq_enabled_plugins" :
    path    => "/etc/rabbitmq/enabled_plugins",
    source => "puppet:///modules/rabbitmq/rabbitmq_enabled_plugins",
    owner   => "root",
    group   => "root",
    mode    => 644,
    require => [ User["rabbitmq"], Group["rabbitmq"], File["rabbitmq"], ],
  }
  file { "rabbitmq.conf.d" :
    path    => "/etc/rabbitmq/rabbitmq.conf.d",
    ensure  => directory,
    owner   => "root",
    group   => "root",
    mode    => 755,
    require => [ User["rabbitmq"], Group["rabbitmq"], ],
    #require => [ User["rabbitmq"], Group["rabbitmq"], Package["rabbitmq"], ],
  }
# TODO need RABBITMQ_NODENAME=rabbitmq@messagingN N is 1 to 4
#   use augeas, split this up in rabbitmq and nodetype class
#  file { "rabbitmq.conf.d_messaging.conf" :
#    path    => "/etc/rabbitmq/rabbitmq.conf.d/messaging.conf",
#    source => "puppet:///modules/rabbitmq/rabbitmq.conf.d_messaging.config",
#    owner   => "root",
#    group   => "root",
#    mode    => 644,
#    require => [ User["rabbitmq"], Group["rabbitmq"], ],
#    #require => [ User["rabbitmq"], Group["rabbitmq"], Package["rabbitmq"], ],
#  }
  #apt sources
  file { "apt_rabbitmq.list" :
    ensure => absent,
    path   => "/etc/apt/sources.list.d/rabbitmq.list",
#    source => "puppet:///modules/rabbitmq/apt_rabbitmq.list",
#    owner  => "root",
#    group  => "root",
#    mode   => "0644",
    notify => Exec["apt-update"],
  }

  ## SERVICES
  service { "rabbitmq" :
    name       => "rabbitmq-server",
    enable     => true,
    #ensure     => running, # do not stop/start
    hasstatus  => true,
    hasrestart => true,
    require    => [ Package["rabbitmq"], File["/var/log/rabbitmq"], ],
  }

  ## EXECS
  exec { "rabbitmq-apt-gpgkeys" :
    command => "wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc && apt-key add rabbitmq-signing-key-public.asc",
    refreshonly => true,
    subscribe => File["apt_rabbitmq.list"],
  }

} # end of class rabbitmq
