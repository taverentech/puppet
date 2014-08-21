#######################################################
# Support MongoDB Server

class tools-basedata {
  notice(">>> tools-basedata class <<<")

  include tools-entitlements

  include php
  include mongodb # server

  if ($::environment == "dev") {
  } elsif ($::environment == "test") {
  } elsif ($::environment == "stage") {
  } elsif ($::environment == "prod") {
  } # end of which environment

}
