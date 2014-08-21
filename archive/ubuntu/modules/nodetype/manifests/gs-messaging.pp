#######################################################
# GS Messaging Servers

class gs-messaging {
  notice(">>> gs-messaging class <<<")

  include rabbitmq

  if ($::environment == "dev") {
    include users::gs_all_dev_shell
    include users::gs_all_dev_sudo-all
  } elsif ($::environment == "stage") {
  } elsif ($::environment == "prod") {
  }

}
