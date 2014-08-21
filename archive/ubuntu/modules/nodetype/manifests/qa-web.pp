#######################################################
# QA Web servers

class qa-web {
  notice(">>> qa-web class <<<")

  if ($::environment == "dev") {

  } elsif ($::environment == "stage") {

  } elsif ($::environment == "prod") {

    include users::qa_apps_prod_shell
    include users::qa_apps_prod_sudo-all

  } # end of which environment

}
