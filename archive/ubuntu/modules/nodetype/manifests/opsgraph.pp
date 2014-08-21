#######################################################
#  opsgraph server configs - dns, ldap

class opsgraph {
  notice(">>> opsgraph class <<<")

  if ($::environment == "dev") {
  } elsif ($::environment == "stage") {
  } elsif ($::environment == "prod") {
    include users::opsgraph_all_prod_shell
    include users::opsgraph_all_prod_sudo-all
  }

}
