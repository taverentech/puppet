################################################################
# Base environment configurations
# Things will likely start here, then move to their own module

#######################################################
# bluetooth - stop and disable
class base::bluetooth {
  notice(">>> bluetooth.pp <<<")
  notify{"class base::bluetooth": }

  package { "bluetooth":
    ensure     => absent,
  }
  package { "bluez":
    ensure     => absent,
  }

}
