#######################################################
# Debuglog Web server configs

class debuglog-web {
  notice(">>> debuglog-web class <<<")

  if ($::environment == "dev") {

  } elsif ($::environment == "prod") {

    host {'memcache':
      ensure       => present,
      name         => "memcache",
      ip           => "10.54.48.3",
      comment      => "Managed by Puppet",
    }
    host {'memcach2':
      ensure       => present,
      name         => "memcach2",
      ip           => "10.54.48.5",
      comment      => "Managed by Puppet",
    }

  } # end of prod

} # end of class
