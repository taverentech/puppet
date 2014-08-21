#######################################################
# ShoreWall (iptables wrapper)

class shorewall {
  notice(">>> shorewall class <<<")
  notify{"Loading shorewall class": }
  tag("shorewall")

  include shorewall::install

  #modprobe::kern_module { "ip_conntrack": ensure => present }
  sysctl::conf { "net.netfilter.nf_conntrack_max": value => 2000002; }

  ##PACKAGES
  package { "shorewall": ensure => installed }

  ##SERVICES
  service { "shorewall":
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require => Package["shorewall"],
    status => '/sbin/shorewall status',		# needed for debian
  }

  ##FILES
  file { "/etc/init.d/shorewall":
    source  => "puppet:///modules/shorewall/init.d_shorewall",
    owner => 'root',
    group => 'root',
    mode  => '0755',
    require => Package["shorewall"],
    notify => Service["shorewall"],
  }

  file { "/etc/default/shorewall":
    source  => [
      "puppet:///modules/shorewall/default_shorewall_$::fqdn",
      "puppet:///modules/shorewall/default_shorewall",
    ],
    owner => 'root',
    group => 'root',
    mode  => '0644',
    require => Package["shorewall"],
    notify => Service["shorewall"],
  }

  #PROTECT against taking action if factoids are null
  if ( $::nodetype != "" and $::pop != "" and $::environment != "") {
    file { "/etc/shorewall/rules":
      source  => [
        "puppet:///modules/shorewall/rules/$::fqdn",
        "puppet:///modules/shorewall/rules/$::nodetype.$::pop",
        "puppet:///modules/shorewall/rules/$::nodetype.$::environment",
        "puppet:///modules/shorewall/rules/$::nodetype",
        "puppet:///modules/shorewall/rules/DEFAULT",
      ],
      owner => 'root',
      group => 'root',
      mode  => '0644',
      backup => ".$::timestamp",
      require => Package["shorewall"],
      notify => Service["shorewall"],
    }

    file { "/etc/shorewall/tunnels":
      source  => [
        "puppet:///modules/shorewall/tunnels/$::fqdn",
        "puppet:///modules/shorewall/tunnels/$::nodetype.$::pop",
        "puppet:///modules/shorewall/tunnels/$::nodetype.$::environment",
        "puppet:///modules/shorewall/tunnels/$::nodetype",
        "puppet:///modules/shorewall/tunnels/DEFAULT",
      ],
      owner => 'root',
      group => 'root',
      mode  => '0644',
      backup => ".$::timestamp",
      require => Package["shorewall"],
      notify => Service["shorewall"],
    }

    file { "/etc/shorewall/policy":
      source  => [
        "puppet:///modules/shorewall/policy/$::fqdn",
        "puppet:///modules/shorewall/policy/$::nodetype.$::pop",
        "puppet:///modules/shorewall/policy/$::nodetype.$::environment",
        "puppet:///modules/shorewall/policy/$::nodetype",
        "puppet:///modules/shorewall/policy/DEFAULT",
      ],
      owner => 'root',
      group => 'root',
      mode  => '0644',
      backup => ".$::timestamp",
      require => Package["shorewall"],
      notify => Service["shorewall"],
    }

    file { "/etc/shorewall/hosts":
      source  => [
        "puppet:///modules/shorewall/hosts/$::fqdn",
        "puppet:///modules/shorewall/hosts/$::nodetype.$::pop",
        "puppet:///modules/shorewall/hosts/$::nodetype.$::environment",
        "puppet:///modules/shorewall/hosts/$::nodetype",
        "puppet:///modules/shorewall/hosts/DEFAULT",
      ],
      owner => 'root',
      group => 'root',
      mode  => '0644',
      backup => ".$::timestamp",
      require => Package["shorewall"],
      notify => Service["shorewall"],
    }
  } #PROTECT against taking action if factoids are null - END

  #TODO - these files not yet managed
  #interfaces
  #masq
  #routestopped
  #shorewall.conf
  #zones

}

class shorewall::install {
  file { "/etc/shorewall/.defaults.tar":
    source  => "puppet:///modules/shorewall/defaults.tar",
    require => Package["shorewall"],
    owner => 'root',
    group => 'root',
    mode  => '0640',
  }

  exec { "install_shorewall_default_enable":
    command => 'sed -i "s/^startup=0$/startup=1/" /etc/default/shorewall',
    onlyif => 'grep -c ^startup=0$ /etc/default/shorewall',
    require => Package["shorewall"],
  }

  #Update shorewall configs if NICs are bonded
  if $ipaddress == $ipaddress_bond0 {
    notice ("network interface is bonded")
    exec { "update_shorewall_configs_bonded":
      command => 'sed -i -e "s/eth/bond/g" /etc/shorewall/*',
      onlyif => 'grep -c eth[0-9] /etc/shorewall/*',
      require => File["/etc/shorewall/.defaults.tar"],
    }
  }

  exec { "install_shorewall_default_configs":
    command => 'tar -x --directory=/etc/shorewall -f /etc/shorewall/.defaults.tar',
    creates => "/etc/shorewall/defaults_installed",
    require => File["/etc/shorewall/.defaults.tar"],
  }
}

#######################################################
