#######################################################
#  ops server configs - dns, ldap

class ops {
  notice(">>> ops class <<<")

  #TOOLS group supports LDAP stuff
  include tools-entitlements

  #LDAP service with master/master replication
  include opendj

  if ($::environment == "dev") {
  } elsif ($::environment == "test") {
    file { "/opt/OpenDJ/config/schema/":
      links  => follow,
      owner  => toolstest,
      group  => tools,
      mode   => 2775,
    }
  } elsif ($::environment == "stage") {
  } elsif ($::environment == "prod") {
    file { "/opt/OpenDJ/config/schema/":
      links  => follow,
      owner  => toolslive,
      group  => tools,
      mode   => 2775,
    }
  }

}
