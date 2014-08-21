################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module
class base::autofs {
  notify{"Loading base::autofs class": }
  notice(">>> base::autofs client class <<<")

  ###############################################################
  ## VARs
  # Set nfs_homedir_server by pop - used by auto.home,auto.nfs templates
  $nfs_homedir_server = $::pop ? {
    "iad1" => "fs1.iad1.example1.com",
    "sjc1" => "fs1.sjc1.example1.com",
    default=> "fs1",
  }
  notify{"DEBUG: nfs_homedir_server is $nfs_homedir_server": }

  ###############################################################
  ## PACKAGEs
  $nfsclientpkgs = [
    "autofs5",
    "nfs-common",
    "rpcbind",
  ]
  package { $nfsclientpkgs: ensure => installed }

  ###############################################################
  ## FILEs
  file { 'idmapd.conf':
    source  => $::pop ? {
      "iad1" => 'puppet:///modules/base/idmapd.conf_iad1',
      "sjc1" => 'puppet:///modules/base/idmapd.conf_sjc1',
      "sql1" => 'puppet:///modules/base/idmapd.conf_sql1',
      default=> 'puppet:///modules/base/idmapd.conf',
    },
    path    => '/etc/idmapd.conf',
    owner   => 'root', group => 'root', mode => '0644',
    notify => Service["autofs","idmapd"],
  }
  file { 'default_nfs-common':
    source  => 'puppet:///modules/base/default_nfs-common',
    path    => '/etc/default/nfs-common',
    owner   => 'root', group => 'root', mode => '0644',
    notify => Service["autofs","idmapd"],
  }
  file { 'auto_master':
    source  => 'puppet:///modules/base/auto.master',
    path    => '/etc/auto.master',
    owner   => 'root', group => 'root', mode => '0644',
    notify => Service["autofs","idmapd"],
  }
  file { 'auto_misc':
    source  => 'puppet:///modules/base/auto.misc',
    path    => '/etc/auto.misc',
    owner   => 'root', group => 'root', mode => '0644',
    notify => Service["autofs","idmapd"],
  }
  file { 'auto_net':
    source  => 'puppet:///modules/base/auto.net',
    path    => '/etc/auto.net',
    owner   => 'root', group => 'root', mode => '0755',
    notify => Service["autofs","idmapd"],
  }
  file { 'auto_smb':
    source  => 'puppet:///modules/base/auto.smb',
    path    => '/etc/auto.smb',
    owner   => 'root', group => 'root', mode => '0755',
    notify => Service["autofs","idmapd"],
  }
  file { 'auto_nfs':
    content => template("base/auto.nfs.erb"),
    path    => '/etc/auto.nfs',
    owner   => 'root', group => 'root', mode => '0644',
    notify => Service["autofs","idmapd"],
  }
  file { 'auto_home':
    content => template("base/auto.home.erb"),
    path    => '/etc/auto.home',
    owner   => 'root', group => 'root', mode => '0644',
    notify => Service["autofs","idmapd"],
  }

  ###############################################################
  ## SERVICEs
  service { 'autofs':
    ensure    => running,
    enable    => true,
    name      => 'autofs',
    hasstatus =>  true,
    require   => [
      File['idmapd.conf','default_nfs-common','auto_master', 'auto_misc', 'auto_smb', 'auto_net', 'auto_nfs', "auto_home"], 
      Package['autofs5'],
    ]
  }
  service { 'idmapd':
    ensure    => running,
    enable    => true,
    name      => 'idmapd',
    hasstatus => true,
    require   => Package['nfs-common'],
  }
  service { 'rpcbind':
    #ensure    => running, # not sure this is really needed
    enable    => true,
    name      => 'rpcbind-boot',
    hasstatus => true,
    require   => Package['nfs-common','rpcbind'],
  }

} # end of class base::autofs
