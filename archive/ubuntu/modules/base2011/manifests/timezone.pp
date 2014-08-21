################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class timezone {
  notice(">>> timezone class <<<")
  notify{"class timezone": }
  tag("safe")

  package { "tzdata": ensure => latest }

  # Timezone exceptions
  if ( $::fqdn == "opsview.example.com" ) or 
     ( $::fqdn == "opsview-web1.sjc.example.com" ) {
       $mytz = "America/Vancouver"
     } else {
       $mytz = "Etc/UTC"
     }

  file { "timezone":
    path    => "/etc/timezone",
    mode    => 0644,
    content  => "$mytz\n",
    require => Package["tzdata"],
  }

  exec { "dpkg-reconfigure -f noninteractive tzdata":
    subscribe => File["timezone"],
    refreshonly => true,
  }

}
