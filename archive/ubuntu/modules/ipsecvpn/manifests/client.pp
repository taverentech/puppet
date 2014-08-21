################################################################
# exVPN CLIENT configurations

class exvpn::config {
  notice(">>> exvpn config class <<<")

  $exvpnpackages = [
    "ipsec-tools",
    "strongswan",
  ]
  package { $exvpnpackages: ensure => latest }

  if($::pop != "") {
    file { "ipsec.conf":
      path       => "/etc/ipsec.conf",
      ensure     => file,
      owner      => root,
      group      => root,
      mode       => 600,
      backup     => ".$::timestamp",
      content    => template("exvpn/ipsec.conf.erb"),
      require    => Package ["ipsec-tools","strongswan"],
      notify     => Service["exvpn"],
    }
    file { "ipsec_ex_secrets":
      path       => "/etc/ipsec.secrets",
      ensure     => file,
      owner      => root,
      group      => root,
      mode       => 600,
      backup     => ".$::timestamp",
      source => [
        "puppet:///modules/exvpn/ipsec.secrets_$::fqdn",
        "puppet:///modules/exvpn/ipsec.secrets_$::pop.example.com",
        "puppet:///modules/exvpn/ipsec.secrets_DEFAULT",
      ],
      require    => Package ["ipsec-tools","strongswan"],
      notify     => Service["exvpn"],
    }
    file { "/etc/ipsec.d/ex":
      path       => "/etc/ipsec.d/ex",
      ensure     => directory,
      owner      => root,
      group      => root,
      mode       => 700,
      require    => Package ["ipsec-tools","strongswan"],
    }
    file { "ipsec_ex_conf":
      path       => "/etc/ipsec.d/ex/$::pop.example.com.conf",
      ensure     => file,
      owner      => root,
      group      => root,
      mode       => 600,
      backup     => ".$::timestamp",
      content    => template("exvpn/ipsec_ex_$::pop.example.com.conf.erb"),
      require    => File ["/etc/ipsec.d/ex"],
      notify     => Service["exvpn"],
    }
  }
}

class exvpn::service {
  notice(">>> exvpn service class <<<")

  service { "exvpn":
    name       => "ipsec",
    ensure     => running,
    enable     => true,
    status     => 'service ipsec status |grep -c ESTABLISHED',
    start      => 'service ipsec restart',
    restart    => 'service ipsec restart',
    require    => Package ["ipsec-tools","strongswan"],
  }

}
# END
