################################################################
# Base environment configurations
# Things will likely start here, then move to their own module

class base::grub {
  notify{"class base::grub": }
  notice(">>> base::grub class <<<")

  ###############################################################
  ## PACKAGEs
  $grubpkgs = [
    "grub-pc",
    "grub2",
  ]
  package { $grubpkgs: ensure => installed }

  ###############################################################
  ## DEFINEs
  define conf ( $value ) {

    # $name is provided by define invocation

    # guid of this entry
    $key = $name

    $context = "/files/etc/default/grub"

    augeas { "default_grub/$key":
      context => "$context",
      onlyif  => "get $key != '$value'",
      changes => "set $key '$value'",
      notify  => Exec["update-grub"],
    }

  } # end of define 

  ###############################################################
  ## FILEs
  file { "default_grub":
    path    => "/etc/default/grub",
    require => Package["grub-pc"],
  }

  ###############################################################
  ## FILEs
  exec { "update-grub":
    command => "/usr/sbin/update-grub2",
    refreshonly => true,
    subscribe => File["default_grub"],
  }

  ####################################################################
  # DEFAULT GRUB configurations
  grub::conf { "GRUB_TIMEOUT": value => "15"; }
  #Unsetting these brings back the grub menu with countdown set above
  grub::conf { "GRUB_HIDDEN_TIMEOUT": value => ""; }
  grub::conf { "GRUB_HIDDEN_TIMEOUT_QUIET": value => ""; }

} # end of class
