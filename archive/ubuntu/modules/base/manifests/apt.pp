################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class base::apt {
  notice(">>> base::apt class <<<")
  notify{"class base::apt": }

  $apt_cron_offset = $::cronoffset + 5

  ###############################################################
  ## PACKAGEs
  $aptpackages = [
    "apt",
    "apt-utils",
    "aptitude",
  ]
  package { $aptpackages: ensure => installed }

  ###############################################################
  ## FILEs

  #Local Mirror for precise sources
  if ( $::lsbdistcodename == "precise" ) {
    file { "apt_sources.list":
      path    => "/etc/apt/sources.list",
      ensure  => file,
      backup => ".$::timestamp",
      source  => $::pop ? {
        "iad1" => "puppet:///modules/base/apt/sources.list_precise_iad1",
        "sjc1" => "puppet:///modules/base/apt/sources.list_precise_sjc1",
        "sql1" => "puppet:///modules/base/apt/sources.list_precise_sql1",
        default=> "puppet:///modules/base/apt/sources.list_precise_sjc1",
      },
      owner => 'root', group => 'root', mode  => '0644',
      notify => Exec["apt-update"],
    }
  }

  #/etc/cron.d/apt-get-update using cron offset 1x per day
  file { "cron_apt-get-update":
    path => "/etc/cron.d/apt-get-update",
    ensure => file,
    owner => root, group => root, mode => 644,
    content => template("base/apt/cron_apt-get-update.erb"),
  }

  #Just a place to download gpg keys too
  file { "apt_mygpg.d":
    path    => "/etc/apt/mygpg.d/",
    ensure  => directory,
    owner => 'root', group => 'root', mode  => '0644',
  }

  #Ubuntu GPG keys 2012
  file { "apt_Ubuntu_CD_Image_2012.gpg":
    path    => "/etc/apt/mygpg.d/Ubuntu_CD_Image_2012.gpg",
    ensure  => file,
    source  => "puppet:///modules/base/apt/Ubuntu_CD_Image_2012.gpg",
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_mygpg.d"],
  }
  file { "apt_Ubuntu_Archive_2012.gpg":
    path    => "/etc/apt/mygpg.d/Ubuntu_Archive_2012.gpg",
    ensure  => file,
    source  => "puppet:///modules/base/apt/Ubuntu_Archive_2012.gpg",
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_mygpg.d"],
  }

  #Cloudera Hadoop sources
  file { "apt_cloudera.gpg":
    path    => "/etc/apt/mygpg.d/cloudera.gpg",
    ensure  => file,
    source  => "puppet:///modules/base/apt/cloudera.gpg",
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_mygpg.d"],
  }

  #Local Cloudera APT sources for Hadoop 
  # Install first time, do not update after-the-fact
  file { "apt_cloudera.list":
    path    => "/etc/apt/sources.list.d/cloudera.list",
    replace => "no",
    ensure  => file,
    source  => $::pop ? {
      "iad1" => "puppet:///modules/base/apt/cloudera_maverick-cdh3u4.list_iad1",
      "sjc1" => "puppet:///modules/base/apt/cloudera_maverick-cdh3u4.list_sjc1",
      "sql1" => "puppet:///modules/base/apt/cloudera_maverick-cdh3.list_sql1",
      default=> "puppet:///modules/base/apt/cloudera_maverick-cdh3u4.list_sjc1",
    },
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_cloudera.gpg"],
    notify => Exec["apt-update"],
  }

  #Local Puppet APT sources for puppet and dependancies
  file { "apt_puppetlabs.gpg":
    path    => "/etc/apt/mygpg.d/puppetlabs.gpg",
    ensure  => file,
    source  => "puppet:///modules/base/apt/puppetlabs.gpg",
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_mygpg.d"],
  }
  file { "apt_puppetlabs.list":
    path    => "/etc/apt/sources.list.d/puppetlabs.list",
    ensure  => file,
    source  => $::pop ? {
      "iad1" => "puppet:///modules/base/apt/puppetlabs.list_iad1",
      "sjc1" => "puppet:///modules/base/apt/puppetlabs.list_sjc1",
      "sql1" => "puppet:///modules/base/apt/puppetlabs.list_sql1",
      default=> "puppet:///modules/base/apt/puppetlabs.list_sjc1",
    },
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_puppetlabs.gpg"],
    notify => Exec["apt-update"],
  }

  #Local hwraid APT sources for megasasctl megacli
  file { "apt_hwraid.gpg":
    path    => "/etc/apt/mygpg.d/hwraid.gpg",
    ensure  => file,
    source  => "puppet:///modules/base/apt/hwraid.gpg",
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_mygpg.d"],
  }
  file { "apt_hwraid.sources.list":
    path    => "/etc/apt/sources.list.d/hwraid.sources.list",
    ensure  => absent,
  }
  file { "apt_hwraid.list":
    path    => "/etc/apt/sources.list.d/hwraid.list",
    ensure  => file,
    source  => $::pop ? {
      "iad1" => "puppet:///modules/base/apt/hwraid.list_sjc1",
      "sjc1" => "puppet:///modules/base/apt/hwraid.list_sjc1",
      "sql1" => "puppet:///modules/base/apt/hwraid.list_sjc1",
      default=> "puppet:///modules/base/apt/hwraid.list_sjc1",
    },
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_hwraid.gpg"],
    notify => Exec["apt-update"],
  }

  #Local Percona APT sources for Percona MySQL and tools
  file { "apt_percona.gpg":
    path    => "/etc/apt/mygpg.d/percona.gpg",
    ensure  => file,
    source  => "puppet:///modules/base/apt/percona.gpg",
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_mygpg.d"],
  }
  file { "apt_percona.list":
    path    => "/etc/apt/sources.list.d/percona.list",
    ensure  => file,
    source  => $::pop ? {
      "iad1" => "puppet:///modules/base/apt/percona.list_iad1",
      "sjc1" => "puppet:///modules/base/apt/percona.list_sjc1",
      "sql1" => "puppet:///modules/base/apt/percona.list_sql1",
      default=> "puppet:///modules/base/apt/percona.list_sjc1",
    },
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_percona.gpg"],
    notify => Exec["apt-update"],
  }

  #Local Percona APT sources for Percona MySQL and tools
  file { "apt_launchpad.gpg":
    path    => "/etc/apt/mygpg.d/launchpad.gpg",
    ensure  => file,
    source  => "puppet:///modules/base/apt/launchpad.gpg",
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_mygpg.d"],
  }
  file { "apt_launchpad.list":
    path    => "/etc/apt/sources.list.d/launchpad.list",
    ensure  => file,
    source  => $::pop ? {
      "iad1" => "puppet:///modules/base/apt/launchpad.list_iad1",
      "sjc1" => "puppet:///modules/base/apt/launchpad.list_sjc1",
      "sql1" => "puppet:///modules/base/apt/launchpad.list_sql1",
      default=> "puppet:///modules/base/apt/launchpad.list_sjc1",
    },
    owner => 'root', group => 'root', mode  => '0644',
    require => File["apt_launchpad.gpg"],
    notify => Exec["apt-update"],
  }

  ###############################################################
  ##EXECs
 
  exec { "apt-update":
    command     => "apt-get update",
    refreshonly => true;
  }

  ## EXECS - trigger gpg key updates on apt repo updates
  exec {"Ubuntu_Archive_2012-apt-gpgkeys":
    command => "apt-key add /etc/apt/mygpg.d/Ubuntu_Archive_2012.gpg",
    refreshonly => true,
    subscribe => File["apt_Ubuntu_Archive_2012.gpg"],
  }

  exec {"Ubuntu_CD_Image_2012-apt-gpgkeys":
    command => "apt-key add /etc/apt/mygpg.d/Ubuntu_CD_Image_2012.gpg",
    refreshonly => true,
    subscribe => File["apt_Ubuntu_CD_Image_2012.gpg"],
  }

  exec {"cloudera-apt-gpgkeys":
    command => "apt-key add /etc/apt/mygpg.d/cloudera.gpg",
    refreshonly => true,
    subscribe => File["apt_cloudera.gpg"],
  }

  exec {"hrwaid-apt-gpgkeys":
    command => "apt-key add /etc/apt/mygpg.d/hwraid.gpg",
    refreshonly => true,
    subscribe => File["apt_hwraid.gpg"],
  }

  exec {"puppetlabs-apt-gpgkeys":
    command => "apt-key add /etc/apt/mygpg.d/puppetlabs.gpg",
    refreshonly => true,
    subscribe => File["apt_puppetlabs.gpg"],
  }

  exec {"percona-apt-gpgkeys":
    command => "apt-key add /etc/apt/mygpg.d/percona.gpg",
    refreshonly => true,
    subscribe => File["apt_percona.gpg"],
  }

  exec {"launchpad-apt-gpgkeys":
    command => "apt-key add /etc/apt/mygpg.d/launchpad.gpg",
    refreshonly => true,
    subscribe => File["apt_launchpad.gpg"],
  }

}

#######################################################
