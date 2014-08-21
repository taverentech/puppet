#######################################################
# Message (chat) servers

class message {
  notice(">>> message class <<<")

  if ($::environment == "dev") {

    include users::message_all_dev_shell
    include users::message_all_dev_sudo-all

  } elsif ($::environment == "prod") {

    include users::message_all_prod_shell
    include users::message_all_prod_sudo-all

  } # end of which environment

}
