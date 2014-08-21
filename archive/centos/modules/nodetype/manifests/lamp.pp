######################################################
# Example of Apache web server class

class lamp {
  notice(">>> lamp (linux, apache, mysql, php class <<<")

  include httpd
  include mysql::server
  include mysql::client
  include php

  # Configure Apache Vhost configs - remove default
  #file { "default.link":
  #  path   => '/etc/nginx/sites-enabled/default',
  #  ensure => 'absent',
  #}

  # Configure nginux Vhost configs using define
  #httpd::vhost::conf { "lamp.test.example3.net.conf": }
  #httpd::vhost::conf { "lamp.test.example3.net-SSL.conf": }

}
