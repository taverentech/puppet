################################################################
#  PHP environment configurations

class php {
  notice(">>> php.pp <<<")
  notify{"Loading php class": }

  if ($::nodetype == "bym-fb-web") or
     ($::nodetype == "wc-fb-web") or
     ($::nodetype == "bp-fb-web") or
     ($::nodetype == "framework-all") {
    include php53
  } else {
    include php54
  }

  define pear() {
    exec { "pear-${name}": 
      command => "pear install -f ${name}",
      unless => "pear -q list |grep -c ${name}", 
    }
  }
  define pecl() {
    exec { "install-pecl-${name}":
      command => "printf '\n\n\n\n\n' | pecl install ${name}",
      unless => "pecl list ${name}",
      #require => Package["php-pear"],  Dependancy breaks on lucid w/o pkgs
    }
  }
}

class php53 {
  notify{"Loading EMPTY php53 class": }
}

class php54 {
  notify{"Loading php54 class": }

  ##PACKAGES
  $defphppkgs = [
    "php-pear","php5","php5-cli","php5-common","php5-curl","php5-dev",
    "php5-mysql", 
  ]

  #####################################################
  #WARNING - before Ubuntu12 php was installed from src
  if ($::lsbdistcodename == "precise") {
    package { $defphppkgs: ensure => installed }
  }
  #####################################################
  php::pear { ['System_Daemon']: }

  php::pecl { ['mongo']: }
  file { "php5_mongo.ini":
    path   => "/etc/php5/conf.d/mongo.ini",
    ensure  => file,
    mode    => 0644,
    owner   => "root",
    group   => "root",
    content => ";Puppet added for php5 Mongo suppport\nextension=mongo.so\n",
  }
  php::pecl { ['memcache']: }
  #pecl install puts one in as 20-memcache.ini already on Ubuntu12
  #file { "php5_memcache.ini":
  #  path   => "/etc/php5/conf.d/memcache.ini",
  #  ensure  => file,
  #  mode    => 0644,
  #  owner   => "root",
  #  group   => "root",
  #  content => ";Puppet added for php5 memache suppport\nextension=memcache.so\n",
  #}

}

class php::stomp {
  notice(">>> php::stomp <<<")
  notify{"Loading php::stomp class": }
  file { "stomp.so":
    path    => "/usr/lib/php5/20100525/stomp.so",
    ensure  => file,
    mode    => 0644,
    owner   => "root",
    group   => "root",
    source  => "puppet:///modules/php/stomp.so",
  }
  file { "conf.d_stomp.ini":
    path    => "/etc/php5/conf.d/stomp.ini",
    ensure  => file,
    mode    => 0644,
    owner   => "root",
    group   => "root",
    source  => "puppet:///modules/php/conf.d/stomp.ini",
    backup  => ".$::timestamp",
    require => File["stomp.so"],
  }
} # end of php::stomp class
