# Base example1 misc configurations

class base::exmample1  {
  notice(">>> base::exmample1 default base OS settings <<<")
  notify{"class base::exmample1 ": }

  ## FILEs
  file { "local_exmample1":
    path => "/usr/local/exmample1",
    ensure => directory,
    owner => 'root', group => 'root', mode  => '0755',
  }
  file { "deploy2":
    path => "/usr/local/exmample1/deploy2",
    ensure => directory,
    owner => 'root', group => 'root', mode  => '0755',
    require => File["local_exmample1"],
  }
  file { "deploy2_etc":
    path => "/usr/local/exmample1/deploy2/etc",
    ensure => directory,
    owner => 'root', group => 'root', mode  => '0755',
    require => File["deploy2"],
  }
  # Manage credentials.dat ONLY IF cluster is defined
  if ( $::cluster != "" and $::cluster != "unknown" ) {
    file { "credentials.dat":
      path    => "/usr/local/exmample1/deploy2/etc/credentials.dat",
      replace => "no",
      ensure  => file,
      backup => ".$::timestamp",
      source  => $::cluster ? {
        "production-euwest1" => "puppet:///modules/base/exmample1/credentials.dat_production",
        "production"         => "puppet:///modules/base/exmample1/credentials.dat_production",
        default              => "puppet:///modules/base/exmample1/credentials.dat_default",
      },
      owner => 'root', group => 'root', mode  => '0644',
      require => File["deploy2_etc"],
    }
  }

  ## SSL cert directory
  file { "exmample1":
    path => "/usr/local/exmample1/ssl",
    ensure => directory,
    owner => 'root', group => 'root', mode  => '0755',
    require => File["local_exmample1"],
  }
  ## Function to install SSL cert file in exmample1 ssl dir
  define sslfile ( $exist ) {
    $sslfile = $name
    file { "$sslfile":
      path    => "/usr/local/exmample1/ssl/$sslfile",
      ensure  => $exist ? {
        0 => absent,
        1 => file,
      },
      backup => ".$::timestamp",
      source  => $exist ? {
        0 => "puppet:///modules/base/exmample1/ssl/source_for_absent",
        1 => "puppet:///modules/base/exmample1/ssl/$sslfile",
      },
      owner => 'root', group => 'root', mode  => '0644',
      require => File["exmample1"],
    }
  } # end of define sslfile

  # Manage SSL certs ONLY IF cluster is defined
  if ( $::cluster == "production" or $::cluster =~ /^production-.*/ ) {
    exmample1::sslfile { "wildcard-exmample1.com.pem": exist => 1 }
    exmample1::sslfile { "wildcard-corp.exmample1.com.pem": exist => 1 }
    exmample1::sslfile { "wildcard-prod.exmample1.com.pem": exist => 1 }
    exmample1::sslfile { "wildcard-api.exmample1.com.pem": exist => 1 }
    exmample1::sslfile { "wildcard-prod.exmample1.com.key": exist => 1 }
    exmample1::sslfile { "wildcard-m.exmample1.com.pem": exist => 1 }
    exmample1::sslfile { "wildcard-lphbs.com.pem": exist => 1 }
  } elsif ( $::cluster == "staging" ) {
    exmample1::sslfile { "wildcard-staging.exmample1.com.pem": exist => 1 }
    exmample1::sslfile { "wildcard-m.staging.exmample1.com.pem": exist => 1 }
#  } elsif ( $::cluster == "qe1" or $::cluster =~ /^qe1-.*/ ) {
#    exmample1::sslfile { "wildcard-qe1.exmample1.com.pem": exist => 1 }
#    exmample1::sslfile { "wildcard-m.qe1.exmample1.com.pem": exist => 1 }
  } else {
    #NO cert files for dev...qe
  }
  # ADD cert filenames (to /usr/local/exmample1/ssl/) for ALL clusters
  exmample1::sslfile { "gd_intermediate.crt": exist => 1 }
  # Remove old cert filenames (from /usr/local/exmample1/ssl/)
  exmample1::sslfile { "exmample1-wildcard.pem": exist => 0 }
  exmample1::sslfile { "corp-wildcard.pem": exist => 0 }
  exmample1::sslfile { "wildcard.m.exmample1.com.pem": exist => 0 }
  example1::sslfile { "staging-wildcard.pem": exist => 0 }

  #make sure /data exist on legacy builds
  file { "/data":
    path => "/data",
    ensure => directory,
    owner => 'root', group => 'root', mode  => '0755',
  }
  #local homedir folder for local users
  file { "data_home":
    path => "/data/home",
    ensure => directory,
    owner => 'root', group => 'root', mode  => '0755',
    require => File["/data"],
  }
  #New tmp dir for applications
  file { "data_tmp":
    path => "/data/tmp",
    ensure => directory,
    owner => 'root', group => 'root', mode  => '01777',
    require => File["/data"],
  }
  #New log dir for applications
  file { "data_log":
    path => "/data/log",
    ensure => directory,
    owner => 'root', group => 'root', mode  => '0755',
    require => File["/data"],
  }
} # end of class
