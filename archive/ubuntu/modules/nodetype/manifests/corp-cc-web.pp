#######################################################
#  corp-cc-web server configs

#TODO - PROD is hand installed
#	work through stage first and new prod before making configs universal
class corp-cc-web {
  notice(">>> corp-cc-web nodetype class <<<")

  if ($::environment == "dev") {
    realize ( Users::Functions::Localuser["ccdev"], )
  } elsif ($::environment == "test") {
    realize ( Users::Functions::Localuser["cctest"], )
  } elsif ($::environment == "stage") {

    realize ( Users::Functions::Localuser["ccstage"], )
    include users::corp-cc_web_stage_shell
    include users::corp-cc_web_stage_sudo-all

    #############################################################
    # TODO carefully include apache2,mysql - stage only for now #
    #############################################################
    include apache2
    include mysql

    #apache2::vhost::conf { "corp-cc-web.stage.symcpe.com": }

  } elsif ($::environment == "prod") {

    realize ( Users::Functions::Localuser["cclive"], )
    include users::corp-cc_web_prod_shell
    include users::corp-cc_web_prod_sudo-all

  }

}
