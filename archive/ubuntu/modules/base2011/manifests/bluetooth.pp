#######################################################
# bluetooth - stop and disable

class bluetooth {
  notice(">>> bluetooth class <<<")
  notify{"class bluetooth": }
  tag("safe")

  package { "bluetooth":
    ensure     => absent,
  }
  package { "bluez":
    ensure     => absent,
  }

  # stop and disable bluetooth
#  if ($::domain != 'sjc2.example.com') {
#    service { "bluetooth":
#      enable => false,
#      ensure => stopped,
#      hasstatus => true,
#      hasrestart => true,
#    }
#  }

}
