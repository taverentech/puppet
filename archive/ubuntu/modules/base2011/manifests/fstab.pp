################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

# TODO - finish and test this

class fstab {
  notify{"class fstab": }

  # nested class/define
  define conf ( $value ) {

    # $name is provided by define invocation

    # guid of this entry
    $key = $name

    $context = "/files/etc/fstab"

    augeas { "fstab_conf/$key":
      context => "$context",
      onlyif  => "get $key != '$value'",
      changes => "set $key '$value'",
      notify  => Exec["mount"],
    }

  } 

  file { "fstab_conf":
    name => $operatingsystem ? {
      default => "/etc/fstab",
    },
  }

  exec { "mount -a":
    alias => "mount",
    refreshonly => true,
    subscribe => File["fstab_conf"],
  }

}
