#######################################################
#  Stargate server configs -  ssh bastion

class stargate {
  notice(">>> stargate nodetype class <<<")

  if ($::environment == "dev") {

  } elsif ($::environment == "stage") {

  } elsif ($::environment == "prod") {
    include users::all #TODO get this working all_stargate_prod_shell
  }

}
