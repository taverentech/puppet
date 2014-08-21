#######################################################
# Apache

import "*.pp"

class apache2 {
  notify{"Loading apache2 class": }
  include apache2::vhost # separated so it can be included separately

  ##PACKAGES
  package { "apache2": ensure => installed, }

  ##SERVICES
  service { "apache2":
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require    => Package["apache2"],
  }

}

class apache2::vhost {

  ##FILES
  # Configure apache2 Vhost configs
  define conf ( ) {
    $vhost = $title
    file { "$vhost":
      path    => "/etc/apache2/sites-available/$vhost",
      backup => ".$::timestamp",
      owner   => root,
      group   => root,
      mode    => 644,
      source  => "puppet:///modules/nodetype/apache2/$vhost",
    }
    file { "$vhost.link":
      path   => "/etc/apache2/sites-enabled/$vhost",
      ensure => "link",
      target => "../sites-available/$vhost",
      require => File["$vhost"],
    }
  }
  # You can call the define like a function in any nodetype class
  #   where you have included nginux like this:
  #   apache2::vhost { "nameOfFile": }

}
