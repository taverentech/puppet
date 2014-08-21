################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

# TODO - finish and test this

class base::fstab {
  notify{"fstab.pp": }
  notice(">>> base::fstab class <<<")

  ######################################
  ## FILEs
  file { "fstab_conf":
    name => $operatingsystem ? {
      default => "/etc/fstab",
    },
  }

  ######################################
  ## EXECs
  exec { "mount -a":
    alias => "mount",
    refreshonly => true,
    subscribe => File["fstab_conf"],
  }

  ######################################
  ## FUNCTIONs
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

}
