#######################################################
# Support Entitlements
#    Do NOT use for MySQL databases except DEV

class tools-entitlements {
  notice(">>> tools-entitlements class <<<")

  group { "tools": gid    => 4040, }
  realize ( Users::Functions::Localuser["tools"], )
  groups::functions::adduser { tools: unique => 'tools', gname => 'tools', uname => 'tools', }

  if ($::environment == "dev") {
    include users::tools_apps_dev_shell
    include users::tools_apps_dev_sudo-all
    realize ( Users::Functions::Localuser["toolsdev"], )
    groups::functions::adduser { toolsdev: unique => 'toolsdev', gname => 'tools', uname => 'toolsdev', }
  } elsif ($::environment == "test") {
    include users::tools_apps_test_shell
    include users::tools_apps_test_sudo-all
    realize ( Users::Functions::Localuser["toolstest"], )
    groups::functions::adduser { toolstest: unique => 'toolstest', gname => 'tools', uname => 'toolstest', }
  } elsif ($::environment == "stage") {
    realize ( Users::Functions::Localuser["toolsstage"], )
    groups::functions::adduser { toolsstage: unique => 'toolsstage', gname => 'tools', uname => 'toolsstage', }
  } elsif ($::environment == "prod") {
    include users::tools_apps_prod_shell
    include users::tools_apps_prod_sudo-all
    realize ( Users::Functions::Localuser["toolslive"], )
    groups::functions::adduser { toolslive: unique => 'toolslive', gname => 'tools', uname => 'toolslive', }
  } # end of which environment

}
