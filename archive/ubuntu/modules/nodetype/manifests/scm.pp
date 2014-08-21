#######################################################
# SCM Servers

class scm {
  notice(">>> scm class <<<")

  include csvn

  if ($::environment == "dev") {
  } elsif ($::environment == "test") {
  } elsif ($::environment == "stage") {
  } elsif ($::environment == "prod") {
  }

}
