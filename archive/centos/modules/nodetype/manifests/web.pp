######################################################
# Example of Apache web server class

class web {
  notice(">>> web (linux, apache, php class <<<")

  include httpd
  #include php #TODO - add minimal php class

  #$scalepackages = [
  #  "python2.7",
  #]
  #package {
  #  $scalepackages: ensure => installed,
  #}

      # Configure Apache Vhost configs - remove default
      #file { "default.link":
      #  path   => '/etc/nginx/sites-enabled/default',
      #  ensure => 'absent',
      #}

      # Configure nginux Vhost configs using define
      #httpd::vhost::conf { "web.test.example3.net.conf": }
      #httpd::vhost::conf { "web.test.example3.net-SSL.conf": }

}
