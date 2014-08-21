################################################################
# Base environment configurations
# Things will likely start here, then move to their own module

class base::ssh {
  notice(">>> base::ssh class <<<")
  notify{"class base::ssh": }
  tag("accounts")

  $sshpackages = [
    'openssh-client',
    'openssh-server',
  ]
  package { $sshpackages: ensure => installed }

  augeas { "sshd_config":
    context => "/files/etc/ssh/sshd_config",
    changes => [
      "set PasswordAuthentication yes",
      "set UseDNS no",
    ],
    notify => Service["sshd"],
  }

  #TODO get this working
  #define rmgroup ( ) {
  #  $group = $name
  #  augeas { "sshd_config_allow_$group":
  #    context => "/files/etc/ssh/sshd_config",
  #    changes =>  "unset AllowGroups $group",
  #    onlyif  =>  "match AllowGroups/*[.='$group'] size == 1",
  #    notify => Service["sshd"],
  #  }
  #} # end if define

  define addgroup ( ) {
    $group = $name
    augeas { "sshd_config_allow_$group":
      context => "/files/etc/ssh/sshd_config",
      changes =>  "set AllowGroups/1000 $group",
      onlyif  =>  "match AllowGroups/*[.='$group'] size == 0",
      notify => Service["sshd"],
    }
  } # end if define
  addgroup { "root": ; }
  addgroup { "sd": ; }
  #RM needs more testing
  #rmgroup { "sudo": ; }
  #rmgroup { "3d": ; }
  #rmgroup { "test": ; }
  #rmgroup { "sshtestgroup": ; }

  if ( $::cluster == "production" or $::cluster =~ /^production-.*/ ) {
    addgroup { "prodlogin": ; }
  } elsif ( $::cluster == "infra" ) {
    #addgroup { "sd": ; } # Should already be in base above
  } elsif ( $::cluster == "staging" ) {
    addgroup { "staginglogin": ; }
  } elsif ( $::cluster == "qe1" or $::cluster =~ /^qe1-.*/ ) {
    addgroup { "qelogin": ; }
  } elsif ( $::cluster == "dev" or 
            $::cluster == "dev1" or $::cluster == "dev2" or
            $::cluster =~ /^dev1-.*/ ) {
    addgroup { "devlogin": ; }
  } elsif ( $::cluster == "watchtower" ) {
    addgroup { "eng": ; }
    addgroup { "qe": ; }
  }

  service { "sshd":
    name => $operatingsystem ? {
      Debian => "ssh",
      Ubuntu => "ssh",
      default => "sshd",
    },
    require => Augeas["sshd_config"],
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
  }

}
