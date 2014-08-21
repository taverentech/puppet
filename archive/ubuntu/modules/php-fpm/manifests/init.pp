################################################################
#  PHP-FPM environment configurations

class php-fpm {

  notice(">>> php-fpm <<<")
  notify{"Loading php-fpm class": }

  ##############################################################
  #PACKAGES
  # Optional packages we want installed at build
  $php-fpm-pkgs = [
"php5-gd", "php5-fpm", "php5-mcrypt", "php-soap", "libphp-pclzip", "libphp-jpgraph", "php5-memcached", "php5-memcache", "uuid", "uuid-dev",
  ]

  #WARNING - before Ubuntu12 nginx was installed from src
  if ($::lsbdistcodename == "precise") {
    package { $php-fpm-pkgs: ensure => installed }
  }

  ##FILES
  file { "fpm_php.ini":
    path   => "/etc/php5/fpm/php.ini",
    ensure  => file,
    mode    => 0644,
    owner   => "root",
    group   => "root",
    source  => [
      "puppet:///modules/php-fpm/php.ini_$::nodetype",
      "puppet:///modules/php-fpm/php.ini",
    ],
    backup => ".$::timestamp",
  }

  ##############################################################
  #SERVICES
  service { "php5-fpm":
    name => $::lsbdistcodename ? {
      lucid => "php-fpm",
      default => "php5-fpm",
    },
    enable => true,
    #ensure => running,    # jenkins may stop/start
    #hasstatus => true,
    #hasrestart => true,
  }

  ##############################################################
  #FILES
  file { "/var/log/php":
    ensure  => directory,
    owner   => "www-data",
    group   => "www-data",
    mode    => 775,
    #TODO require => [ User[www-data], Group[www-data] ],
  }
  file { "/var/log/php-fpm":
    ensure  => directory,
    owner   => "www-data",
    group   => "www-data",
    mode    => 775,
    #TODO require => [ User[www-data], Group[www-data] ],
  }

  file { "php5_uuid.ini":
    path   => "/etc/php5/conf.d/uuid.ini",
    ensure  => file,
    mode    => 0644,
    owner   => "root",
    group   => "root",
    content => ";Puppet added for php5 UUID suppport\nextension=uuid.so\n",
  }

  file { "php5-fpm.conf":
    path   => "/etc/php5/fpm/php-fpm.conf",
    ensure  => file,
    mode    => 0644,
    owner   => "root",
    group   => "root",
    source  => "puppet:///modules/php-fpm/php-fpm.conf",
    backup => ".$::timestamp",
  }
  file { "pool.d_www.conf":
    path   => "/etc/php5/fpm/pool.d/www.conf",
    ensure  => file,
    mode    => 0644,
    owner   => "root",
    group   => "root",
    source  => "puppet:///modules/php-fpm/pool.d/www.conf",
    backup => ".$::timestamp",
  }

  ###########################################################
  #EXECS
  exec { "install-uuid.so":
    command => '/usr/src/scripts/patches/uuid-1.0.2/configure && make --directory /usr/src/scripts/patches/uuid-1.0.2 && make --directory /usr/src/scripts/patches/uuid-1.0.2 install',
    unless  => "ls /usr/lib/php5/20??????/uuid.so",
  }

} # end php-fpm class
