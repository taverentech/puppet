################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class timezone {
  notice(">>> timezone class <<<")
  notify{"class timezone": }
  tag("safe")

  package { "tzdata": ensure => latest }

  # Timezone exceptions
  #$mytz = "Etc/GMT"

  #file { "timezone":
  #  path    => "/etc/timezone",
  #  mode    => 0644,
  #  content  => "$mytz\n",
  #  require => Package["tzdata"],
  #}

}
