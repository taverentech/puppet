################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class sslcerts {
  # prints on puppetmaster
  notice(">>> sslcerts class <<<")
  notify{"class sslcerts": }
  # prints on puppet agent (client)
  notify{"Installing example star certs": }
  tag("safe")

  ##FILES
  # Copy entire directory of SSL certs down
  file { "/etc/ssl/example3/":
    ensure  => directory,
    recurse => true,
    source  => "puppet:///modules/base/certs/",
    ignore  => ".svn",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    backup  => ".$::timestamp",
  }

}
