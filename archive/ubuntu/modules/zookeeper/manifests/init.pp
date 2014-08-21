################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class zookeeper {
  notice(">>> zookeeper.pp <<<")
  notify{"Loading zookeeper class": }

  tag("zookeeper")

  ##PACKAGES

  ##FILES
  include zookeeper::libdir

  ##SERVICES
  #service { "zookeeper":
  #  enable => true,
  #  ensure => running,
  #  hasstatus => true,
  #  hasrestart => true,
  #  require => [
  #    File["zookeeper.cfg"],
  #    File["init.d_zookeeper"],
  #  ]
  #}

}

class zookeeper::libdir {
  ##FILES
  # Copy entire directory of plugins down
  file { "/usr/local/zookeeper-3.4.3/":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
  file { "/usr/local/zookeeper-3.4.3/lib/":
    ensure  => directory,
    recurse => true,
    source  => "puppet:///modules/zookeeper/zookeeper-3.4.3/lib/",
    ignore  => ".svn",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    backup  => ".$::timestamp",
    #require => Package["zookeeper"], - there is no 3.4.3 package yet
  }
}
