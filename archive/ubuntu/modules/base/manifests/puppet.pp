#######################################################
# Puppet Client
# runs on precise, maverick

# NOTE - this module only needs to run on centos5 and Ubuntu10+

# Configure puppet agent
class base::puppet {
  if ( $::lsbdistcodename == "precise" ) {
    include base::apt	# just in case node includes only base::puppet
  }
  notify{"Loading base::puppet class": }
  tag("puppet")

  notice(">>> base puppet agent class <<<")

  $minute1 = $::cronoffset
  $minute2 = $minute1 + 30
  notify{"DEBUG: puppet cron offsets are $minute1 and $minute2": }

  # Set puppetmaster by domain to not rely on domain completion
  $puppetmaster = $::pop ? {
    "iad1" => "puppet.iad1.prod.example1.com",
    "sjc1" => "puppet.sjc1.eng.example1.com",
    #failsave - depends on domain completion
    default=> "puppet",
  }
  notify{"DEBUG: puppetmaster for cron is $puppetmaster": }

  ## PACKAGEs
  $puppetpkgs = [
    "puppet",
    "puppet-common",
  ]
  if ( $::osfamily == "Debian" ) {
    package { $puppetpkgs: 
      ensure  => $::lsbdistcodename ? {
        maverick   => "3.1.1-1puppetlabs1",
        precise    => "3.1.1-1puppetlabs1",
        default    => "installed",
      },
    }
  }

  ## FILEs
  # Uses puppetmaster var
  file { "puppet.conf":
    path => "/etc/puppet/puppet.conf",
    content => template("base/puppet/puppet.conf.erb"),
    owner => 'root', group => 'root', mode => '0644',
    backup => ".$::timestamp",
  }
  # Uses puppetmaster var
  file { "cron_puppet-agent":
    path => "/etc/cron.d/puppet-agent",
    ensure => file,
    owner => root, group => root, mode => 644,
    content => template("base/puppet/cron_puppetagent.erb"),
    require => File ["puppet.conf"],
  }
  file { "/etc/default/puppet":
    source => "puppet:///modules/base/puppet/default",
    owner => 'root', group => 'root', mode => '0644',
  }
  file { "/etc/logrotate.d/puppet":
    source => [
      "puppet:///modules/base/puppet/logrotate.d_$::fqdn",
      "puppet:///modules/base/puppet/logrotate.d",
    ],
    owner => 'root', group => 'root', mode => '0644',
  }
  # make /var/lib/puppet readable for running facter -p as non-root
  file { "/var/lib/puppet":
    owner => 'puppet', group => 'puppet', mode => '2755',
  }

  ## SERVICEs
  # Running puppetd via cron instead of service due to memory locks
  service { "puppet":
    enable => false,
    ensure => stopped,
    hasstatus => true,
    hasrestart => true,
  }

} # end class puppet
