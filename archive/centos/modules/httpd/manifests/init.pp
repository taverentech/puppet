#######################################################
# Apache

import "*.pp"

class httpd {
  notice(">>> httpd class <<<")
  notify{"Loading httpd class": }

  include httpd::vhost # separated so it can be included separately

  ##PACKAGES
  $httpdpackages = [
      "httpd",
      "mod_ssl",
  ]
  package {
      $httpdpackages: ensure => installed,
  }

  ##SERVICES
  service { "httpd":
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require    => Package["httpd"],
  }

}

class httpd::vhost {

  ##FILES
  # Configure httpd Vhost configs
  define conf ( ) {
    $vhost = $title
    file { "$vhost":
      path    => "/etc/httpd/sites-available/$vhost",
      backup => ".$::timestamp",
      owner   => root,
      group   => root,
      mode    => 644,
      source  => "puppet:///modules/nodetype/httpd/$vhost",
    }
    file { "$vhost.link":
      path   => "/etc/httpd/sites-enabled/$vhost",
      ensure => "link",
      target => "../sites-available/$vhost",
      require => File["$vhost"],
    }
  }
  # You can call the define like a function in any nodetype class
  #   where you have included nginux like this:
  #   httpd::vhost { "nameOfFile": }

}
