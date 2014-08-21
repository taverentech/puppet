#######################################################
# Framework Server Class

class framework-all {
  notice(">>> framework-all class <<<")

  # Include full game web server stack
  include mysql
  include nginx
  include php
  include php-fpm
  include memcache
  memcache::conf { "framework-mc-conf": ip => "", mem => "1203"; } #1203MB

  # Configure nginux Vhost configs - remove default
  file { "default.link":
    path   => '/etc/nginx/sites-enabled/default',
    ensure => 'absent',
  }

  if ($::environment == "dev") {
    include users::framework_all_dev_shell
    include users::framework_all_dev_sudo-all
    #nginx::vhost::conf { "framework-all.dev.example.com.conf": }
    #nginx::vhost::conf { "framework-all.dev.example.com-SSL.conf": }
  } elsif ($::environment == "test" or $::environment == "ex") {
  } elsif ($::environment == "stage" or $::environment == "qa") {
  } elsif ($::environment == "prod" or $::environment == "preview") {
  }

}
