################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class snmp {
  notice(">>> snmp class <<<")
  notify{"class snmp": }
  tag("safe")

  include snmp::client

  if ($::domain == "sjc2.foobare.com") {
  	include snmp::server
  }

}

class snmp::client {
  notice(">>> snmp client class <<<")

  package { "snmp":
    ensure     => latest,
  }

}

#Setup only for sjc2 right now
class snmp::server {
  notice(">>> snmp server class <<<")

  ##PACKAGE
  package { "snmpd":
    ensure     => latest,
  }

  ##SERVICE
  service { "snmpd":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    status     => '/etc/init.d/snmpd status | grep "snmpd is running"',
    require    => Package ["snmpd"],
  }

  ##FILES
  file { "snmpd.conf":
    path       => "/etc/snmp/snmpd.conf",
    owner      => root,
    group      => root,
    mode       => 600,
    require => Package["snmpd"],
  }

  ##EXECS
  exec { "sjc2-snmpd-add-checkraid":
    command => 'echo "#foobare - enable opsview monitor via nrpe\ncom2sec local 192.168.10.39 foobarseccom\nextend .1.3.6.1.4 dellraid /usr/bin/sudo /usr/lib/nagios/plugins/ex/check_dell_raid.sh" >> /etc/snmp/snmpd.conf',
    unless  => "grep foobareseccom /etc/snmp/snmpd.conf",
    require => File["snmpd.conf"],
    notify  => Service["snmpd"],
  }
  #temp change /usr/src/scripts/common/ to /usr/lib/nagios/plugins/ex/
  exec { "sjc2-snmpd-fix-raidpath":
    command => 'sed -i -e "s#/usr/src/scripts/common/#/usr/lib/nagios/plugins/ex/#" /etc/snmp/snmpd.conf',
    onlyif  => "grep /usr/src/scripts/common/ /etc/snmp/snmpd.conf",
    require => File["snmpd.conf"],
    notify  => Service["snmpd"],
  }

}
