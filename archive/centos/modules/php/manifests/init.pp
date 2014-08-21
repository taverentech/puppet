#######################################################
# PHP Client

# Configure php
class php {
  notify{"Loading php class": }
  tag("php")

  notice(">>> php class <<<")

  ##PACKAGES
  $php5packages = [
    "php",
    "php-cli",
    "php-common",
    "php-dba",
    "php-devel",
    "php-mysql",
    "php-pdo",
    "php-pear",
  ]
  package {
      $php5packages: ensure => installed,
  }

  ## FILES
  file { "/etc/httpd/conf.d/php.conf":
    source => [
      "puppet:///modules/php/httpd_php.conf_$::fqdn",
      "puppet:///modules/php/httpd_php.conf_$::domain",
      "puppet:///modules/php/httpd_php.conf",
    ],
    owner => 'root',
    group => 'root',
    mode  => '0644',
    backup => ".$::timestamp",
  }
} # end class php
