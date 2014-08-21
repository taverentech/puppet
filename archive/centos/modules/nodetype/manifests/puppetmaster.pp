#######################################################
# Puppetmaster SERVER

class puppet_server {
  tag("puppetmaster")
  notice(">>> puppetmaster server class <<<")

  include httpd
  include puppetmaster

#  file { "/etc/default/puppetmaster":
#    source => [
#      "puppet:///modules/puppet/default_puppetmaster_$::fqdn",
#      "puppet:///modules/puppet/default_puppetmaster",
#    ],
#    owner => 'root',
#    group => 'root',
#    mode  => '0644',
#  }
  file { "/etc/cron.d/puppetmaster":
    source => [
      "puppet:///modules/puppet/cron_puppetmaster_$::fqdn",
      "puppet:///modules/puppet/cron_puppetmaster",
    ],
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

# TODO - disable and switch to passenger
#  service { "puppetmaster":
#    enable => true,
#    ensure => running,
#    hasstatus => true,
#    hasrestart => true,
#    require => File["/etc/default/puppetmaster"],
#  }

#  package { "puppetmaster":
#      ensure => $::lsbdistcodename ? {
#        default   => "2.7.11-1puppetlabs1",
#      }
#  }
#  package { "puppetmaster-common":
#      ensure => $::lsbdistcodename ? {
#        default   => "2.7.11-1puppetlabs1",
#      }
#  }

} # end class puppetmaster
