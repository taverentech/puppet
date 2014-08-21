################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module
class base::sudo {
  notify{"Loading base::sudo class": }
  notice(">>> base::sudo client class <<<")

  ###############################################################
  ## PACKAGEs
  $sudoclientpkgs = [ "sudo", ]
  package { $sudoclientpkgs: ensure => installed }

  ###############################################################
  ## FILEs
  file { "sudoers.d":
    path    => "/etc/sudoers.d",
    ensure  => directory,
    owner   => 'root', group   => 'root', mode    => '0644',
    require => Package["sudo"],
  }
  file { 'sudoers_sd':
    path    => '/etc/sudoers.d/sd',
    source  => 'puppet:///modules/base/sudoers.d/sd',
    owner   => 'root', group => 'root', mode => '0440',
    require => File["sudoers.d"],
  }
  file { 'sudoers_nrpe':
    path    => '/etc/sudoers.d/nrpe',
    source  => 'puppet:///modules/base/sudoers.d/nrpe',
    owner   => 'root', group => 'root', mode => '0440',
    require => File["sudoers.d"],
  }
  if ( $::cluster == "production" or $::nodetype == "archive" or $::nodetype == "datanode" ) {
    $clustersudogroup = "prodsudo"
  } elsif ( $::cluster =~ /^production-.*/ ) {
    $clustersudogroup = "prodsudo"
  } elsif ( $::cluster == "infra" ) {
    $clustersudogroup = "unknown" # sd already in by default
  } elsif ( $::cluster == "staging" ) {
    $clustersudogroup = "stagingsudo"
  } elsif ( $::cluster == "qe1" or 
            $::cluster =~ /^qe1-.*/ ) {
    $clustersudogroup = "qesudo"
  } elsif ( $::cluster == "dev" or 
            $::cluster == "dev1" or $::cluster == "dev2" or
            $::cluster =~ /^dev1-.*/ ) {
    $clustersudogroup = "devsudo"
  } elsif ( $::cluster == "watchtower" ) {
    $clustersudogroup = "eng"
  } else {
    $clustersudogroup = "unknown"
  }
  file { 'sudoers_cluster':
    path    => '/etc/sudoers.d/cluster',
    content => $clustersudogroup ? {
      "unknown" => "#######################\n## Managed by Puppet ##\n#######################\n#Unknown cluster\n",
      "devsudo" => "#######################\n## Managed by Puppet ##\n#######################\n%$clustersudogroup ALL=(ALL) NOPASSWD:ALL\n",
      "eng    " => "#######################\n## Managed by Puppet ##\n#######################\n%$clustersudogroup ALL=(ALL) NOPASSWD:ALL\n",
      default   => "#######################\n## Managed by Puppet ##\n#######################\n%$clustersudogroup ALL=(ALL) ALL\n",
    },
    owner   => 'root', group => 'root', mode => '0440',
    require => File["sudoers.d"],
  }

  ###############################################################
  ## SERVICEs

  ###############################################################
  ## EXECs

} # end of class base::sudo
