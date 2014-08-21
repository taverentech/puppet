#######################################################
# Puppet Client

import "*.pp"

# Configure puppet client
class puppet {
  notify{"Loading puppet class": }
  tag("puppet")

  notice(">>> puppet client class <<<")

  $minute1 = $::cronoffset
  $minute2 = $minute1 + 30
  notify{"DEBUG: puppet cron offsets are $minute1 and $minute2": }

  file { "cron_puppet-agent":
    path       => "/etc/cron.d/puppet-agent",
    ensure     => file,
    owner      => root,
    group      => root,
    mode       => 644,
    content    => template("puppet/cron_puppetagent.erb"),
    require    => File ["/etc/puppet/puppet.conf"],
  }

  file { "/etc/init.d/puppet":
    source => [
      "puppet:///modules/puppet/init.d_puppet_$::fqdn",
      "puppet:///modules/puppet/init.d_puppet",
    ],
    owner => 'root',
    group => 'root',
    mode  => '0755',
    notify => Service["puppet"],
  }
  file { "/etc/puppet/puppet.conf":
    source => [
      "puppet:///modules/puppet/puppet.conf_$::fqdn",
      "puppet:///modules/puppet/puppet.conf_$::domain",
      "puppet:///modules/puppet/puppet.conf",
    ],
    owner => 'root',
    group => 'root',
    mode  => '0644',
    backup => ".$::timestamp",
    notify => Service["puppet"],
  }
  file { "/etc/logrotate.d/puppet":
    source => [
      "puppet:///modules/puppet/logrotate.d_puppet_$::fqdn",
      "puppet:///modules/puppet/logrotate.d_puppet",
    ],
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }
  # make /var/lib/puppet readable for running facter -p as non-root
  file { "/var/lib/puppet":
    owner => 'puppet',
    group => 'puppet',
    mode  => '2755',
  }

  # Running puppetd via cron instead of service due to memory locks
  service { "puppet":
    enable => false,
    ensure => stopped,
    hasstatus => true,
    hasrestart => true,
  }

} # end class puppet
