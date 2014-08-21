#######################################################
# Support

class support-web {
  notice(">>> support-web class <<<")

  include tools-entitlements

  include php
  include apache2
  include apache2::openid

  #Needed for sykpe tool - /var/www/skype-int.example.com/linux-x86-skypekit
  $skypepackages = [
    "libx11-6:i386",
    "libasound2:i386",
    "libxv1:i386",
    "libxss1:i386",
    "libstdc++6:i386",
  ]
  package {
    $skypepackages: ensure => installed,
  }

  exec { "pear-doctrine-dbal21":
    command => "pear channel-discover pear.doctrine-project.org;pear install -f doctrine/DoctrineDBAL",
    unless => "pear info doctrine/DoctrineDBAL",
    require => Package["php-pear"],
  }
  exec { "pear-doctrine-orm21":
    command => "pear channel-discover pear.doctrine-project.org;pear install -f doctrine/DoctrineORM",
    unless => "pear info doctrine/DoctrineORM",
    require => Package["php-pear"],
  }
  exec { "pear-twig":
    command => "pear channel-discover pear.twig-project.org;pear install -f twig/Twig",
    unless => "pear info twig/Twig",
    require => Package["php-pear"],
  }
  exec { "pear-FirePHPCore":
    command => "pear channel-discover pear.firephp.org;pear install -f firephp/FirePHPCore",
    unless => "pear info firephp/FirePHPCore",
    require => Package["php-pear"],
  }

  php::pecl { ['mailparse']: }
  php::pecl { ['xdebug']: }

  group { "fbpaymentparser": gid    => 4007, }
  user { "fbpaymentparser":
    comment => "FB Payment Parser",
    home    => "/home/fbpaymentparser",
    shell   => "/bin/bash",
    gid     => 4007,
    uid     => 4007,
  }
  if ($::environment == "dev") {
  } elsif ($::environment == "test") {
  } elsif ($::environment == "stage") {
  } elsif ($::environment == "prod") {
      # Configure Apache Vhost configs - remove default
      #  NO - this breaks https://support.example.com/admin/Generic/Live/renderdocswikibutton
      #file { "default.link":
      #  path   => '/etc/nginx/sites-enabled/default',
      #  ensure => 'absent',
      #}
      # Configure nginux Vhost configs using define
      apache2::vhost::conf { "skype-int.example.com": }
      apache2::vhost::conf { "support-web1.sjc.example.com": }
      apache2::vhost::conf { "support.example.com": }
    file { "fbpaymentparser.forward":
      path => "/home/fbpaymentparser/.forward",
      source => "puppet:///modules/nodetype/tools/fbpaymentparser.forward",
      owner => 'fbpaymentparser',
      group => 'fbpaymentparser',
      mode  => '0644',
      backup => ".$::timestamp",
      require => [ User["fbpaymentparser"], Group["fbpaymentparser"], ],
    }
  } # end of prod
}
