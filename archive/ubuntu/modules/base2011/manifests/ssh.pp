################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class ssh {
  notice(">>> ssh class <<<")
  notify{"class ssh": }
  tag("accounts")
  tag("safe")

  $sshpackages = [
    'ssh',
    'openssh-client',
    'openssh-server',
  ]
  package { $sshpackages: ensure => latest }

  augeas { "sshd_config":
    context => "/files/etc/ssh/sshd_config",
    changes => [
      "set PasswordAuthentication no",
      "set UseDNS no",
    ],
    notify => Service["sshd"],
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

