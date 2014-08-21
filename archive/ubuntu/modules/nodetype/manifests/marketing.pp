#######################################################
# Marketing

class marketing {
  notice(">>> marketing class <<<")

  # nginx
  # php-fpm
  # mysql

  if ($::environment == "dev") {

  } elsif ($::environment == "stage") {

  } elsif ($::environment == "prod") {

    include users::marketing_all_prod_shell
    include users::marketing_all_prod_sudo-all

  } # end of which environment

}
