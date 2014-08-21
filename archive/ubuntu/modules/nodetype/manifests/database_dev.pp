#######################################################
# Database Dev configs

class database_dev {
  notice(">>> database_devdev class <<<")

  if ($::environment == "dev") {
    include users::all_database_dev_shell
    include users::all_database_dev_sudo-all
  }

}
