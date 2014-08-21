#######################################################
# build Servers

class build {
  notice(">>> build class <<<")

  include jenkins

  if ($::lsbdistcodename == "precise") {
    include php
  
    $buildpackages = [
      "imagemagick",
      "libgmp3-dev",
      "xsltproc",
      "npm",
    ]
    #"build-essential", # already in base
    package { $buildpackages: ensure => installed }
  
    exec { "pear-phpdoc":
      command => "pear channel-discover pear.phpdoc.org;pear install -f phpdoc/phpDocumentor-alpha",
      unless => "pear info phpdoc/phpDocumentor-alpha",
      require => Package["php-pear"],
    }
    exec { "npm-yuidocjs":
      command => "npm -g install yuidocjs",
      unless => "npm -g list |grep -c yuidocjs",
      require => Package["npm"],
    }
  } # end of precise

  if ($::environment == "dev") {

    include users::build_all_dev_shell
    include users::build_all_dev_sudo-all

  } elsif ($::environment == "test") {

    include users::build_all_test_shell
    include users::build_all_test_sudo-all

  } elsif ($::environment == "stage") {

    include users::build_all_stage_shell
    include users::build_all_stage_sudo-all

  } elsif ($::environment == "prod") {

    include users::build_all_prod_shell
    include users::build_all_prod_sudo-all

  } # end of which environment

} # end of build class
