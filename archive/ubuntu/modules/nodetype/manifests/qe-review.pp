#######################################################
# QE Dev apache/Mysql Servers

class qe-review {
  notice(">>> qe-all class <<<")

  include qe-apps-entitlements

  include mysql # server
  include apache2
  include apache2::openid

  if ($::environment == "dev") {
    include users::qe_all_dev_shell
    include users::qe_all_dev_sudo-all
  } elsif ($::environment == "stage") {
  } elsif ($::environment == "prod") {
  }

}
