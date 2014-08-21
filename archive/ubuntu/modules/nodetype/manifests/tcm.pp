#######################################################
# QE tcm Servers

class tcm {
  notice(">>> tcm class <<<")
 
  include qe-apps-entitlements

  if ($::environment == "dev") {
  } elsif ($::environment == "test") {
  } elsif ($::environment == "stage") {
  } elsif ($::environment == "prod") {
  }

}
