#######################################################
# Support MySQL Database Servers

class support-db {
  notice(">>> support-db class <<<")

  include tools-entitlements
  include php
  include mongodb # server
  include mysql # server

  if ($::environment == "dev") {

  } elsif ($::environment == "test") {

  } elsif ($::environment == "stage") {

  } elsif ($::environment == "prod") {

  } # end of which environment

}
