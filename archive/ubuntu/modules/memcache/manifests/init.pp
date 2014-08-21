#######################################################
# MemCache (mc) Class
#  This class installs and does basic configuratin
#  The nodetype class should do any overrides specific
#    to game-platform

class memcache {
  notice(">>> memcache class <<<")
  notify{"Loading memcache class": }

  tag("memcache")

  # Do on all memcache servers

  realize ( Users::Functions::Localuser["memcache"], )
 
  #PACKAGES
  $memcachepackages = [
    "memcached",
    "libmemcached-tools",
    "libcache-memcached-perl",
  ]
  package {
    $memcachepackages: 
      ensure => installed,
      require => User["memcache"],
  }

  #SERVICES
  service { "memcached":
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require => File["init.d_memcached"],
  }

  #FILES
  define conf ( $mem, $ip ) {
    $memcache_memory = $mem
    if ($memcache_bindip == "") {
      $memcache_bindip = $::ipaddress
    } else {
      $memcache_bindip = $ip
    }
    file { "memcached.conf":
      path       => "/etc/memcached.conf",
      content    => template("memcache/memcached.conf.erb"),
      owner      => root,
      group      => root,
      mode       => 644,
      backup     => ".$::timestamp",
      require => Package["memcached"],
      #notify => Service[ "memcached" ], # NOTE: too dangerous to restart
    }
  }

  file { "init.d_memcached":
    path       => "/etc/init.d/memcached",
    source  => [
      "puppet:///modules/memcache/init.d_memcached",
    ],
    owner      => root,
    group      => root,
    mode       => 755,
    backup     => ".$::timestamp",
    require => [ Package["memcached"],File["start-memcached"] ],
    #notify => Service[ "memcached" ], # NOTE: too dangerous to restart
  }

  # This one supports numa
  file { "start-memcached":
    path       => "/usr/local/sbin/start-memcached",
    source  => [
      "puppet:///modules/memcache/sbin_start-memcached",
    ],
    owner      => root,
    group      => root,
    mode       => 755,
    backup     => ".$::timestamp",
    require => [ Package["memcached"],Package["numactl"], ],
    #notify => Service[ "memcached" ], # NOTE: too dangerous to restart
  }

} # end of memcache class
