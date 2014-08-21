#######################################################
# QE Dev and Apps server Entitlements
#    Do NOT use for MySQL database nodetypes

class qe-apps-entitlements {
  notice(">>> qe-apps-entitlements class <<<")

  if ($::environment == "dev") {
    #realize ( Users::Functions::Localuser["qedev"], )
    include users::qe_all_dev_shell
    include users::qe_all_dev_sudo-all
  } elsif ($::environment == "test" or $::environment == "dev") {
    #realize ( Users::Functions::Localuser["qetest"], )
    #include users::qe_apps_test_shell
    #include users::qe_apps_test_sudo-all
  } elsif ($::environment == "stage" or $::environment == "qa") {
    #realize ( Users::Functions::Localuser["qestage"], )
    #include users::qe_apps_stage_shell
    #include users::qe_apps_stage_sudo-all
  } elsif ($::environment == "prod" or $::environment == "preview") {
    #realize ( Users::Functions::Localuser["qelive"], )
    include users::qe_apps_prod_shell
    include users::qe_apps_prod_sudo-all
  }

}
