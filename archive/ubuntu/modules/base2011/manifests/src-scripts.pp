################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class src-scripts {

  notice(">>> src-scripts.pp <<<")
  notify{"class src-scripts": }
  tag("safe")

  file { "/usr/src/scripts/variables.sh":
    ensure => absent;	# contains mysql password during legacy builds
  }
  #TODO once all nagios checks moved to /usr/lib/nagios/plugins/{ex,bi} remove
  file { "/usr/src/scripts/bi":
    ensure  => directory,
    ignore  => ".svn",
    owner   => "root",
    group   => "root",
    recurse => true,
    mode    => 0755,
  }

}
