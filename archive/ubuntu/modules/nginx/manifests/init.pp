#######################################################
# NGinx

import "*.pp"

class nginx {
  notice(">>> nginx class <<<")
  notify{"Loading nginx class": }

  #PACKAGES
  #WARNING - before Ubuntu12 nginx was installed from src
  if ($::lsbdistcodename == "precise") {
    package { "nginx": ensure => installed, }
    package { "nginx-common": ensure => installed, }
    package { "nginx-full": ensure => installed, }
  }

  #SERVICES
  service { "nginx":
    enable => true,
    #ensure => running,	# do not want puppet starting it during deploy
    #hasstatus => true,
    #hasrestart => true,
  }

  ##FILES
  file { "/etc/logrotate.d/nginx":
    source => [
      "puppet:///modules/nginx/logrotate.d_nginx_$::fqdn",
      "puppet:///modules/nginx/logrotate.d_nginx_$::nodetype.$::environment",
      "puppet:///modules/nginx/logrotate.d_nginx_$::nodetype",
      "puppet:///modules/nginx/logrotate.d_nginx",
    ],
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

}

class nginx::vhost {
  # These need to be in vhost class, outside conf else they are dups.
    file { "nginx_sites-available":
      path   => "/etc/nginx/sites-available",
      ensure => directory,
      owner   => root,
      group   => root,
      mode    => 755,
    }
    file { "nginx_sites-enabled":
      path   => "/etc/nginx/sites-enabled",
      ensure => directory,
      owner   => root,
      group   => root,
      mode    => 755,
    }
  # Configure nginx Vhost configs
  define conf ( ) {
    $vhost = $title
    file { "$vhost":
      path    => "/etc/nginx/sites-available/${vhost}",
      backup => ".$::timestamp",
      owner   => root,
      group   => root,
      mode    => 644,
      source  => [
        "puppet:///modules/nodetype/nginx/${vhost}_${nodetype}.${environment}",
        "puppet:///modules/nodetype/nginx/${vhost}_${fqdn}",
        "puppet:///modules/nodetype/nginx/${vhost}",
      ],
    }
    file { "$vhost.link":
      path   => "/etc/nginx/sites-enabled/${vhost}",
      ensure => link,
      target => "../sites-available/${vhost}",
      require => File["$vhost"],
    }
  }
  # You can call the define like a function in any nodetype class
  #   where you have included nginux like this:
  #   nginx::vhost { "nameOfFile": }

}
