################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module
# runs on precise, maverick

class base::snmp {
  notify{"Loading base::snmp class": }
  notice(">>> base::snmp client class <<<")

  ###############################################################
  ## VARs
  # Set SNMP servers by pop - used by snmpd.conf templates
  $cacti_server = $::pop ? {
    "iad1" => "cacti.sql1.corp.example1.com",
    "sjc1" => "cacti.sql1.corp.example1.com",
    "sql1" => "cacti.sql1.corp.example1.com",
    default=> "cacti.sql1.corp.example1.com",
  }
  notify{"DEBUG: cacti_server is $cacti_server": }
  $graph_server = $::pop ? {
    "iad1" => "graphana.sql1.eng.example1.com",
    "sjc1" => "graphana.sql1.eng.example1.com",
    "sql1" => "graphana.sql1.eng.example1.com",
    default=> "graphana.sql1.eng.example1.com",
  }
  notify{"DEBUG: graph_server is $graph_server": }

  ###############################################################
  ## PACKAGEs
  $snmpclientpkgs = [
    "snmp",
    "snmpd",
  ]
  package { $snmpclientpkgs: ensure => installed }

  ###############################################################
  ## FILEs
  file { 'snmpd.conf':
    content => template("base/snmp_snmpd.conf.erb"),
    path    => '/etc/snmp/snmpd.conf',
    owner   => 'root', group => 'root', mode => '0644',
    backup => ".$::timestamp",
    notify => Service["snmpd"],
  }
  file { 'default_snmpd':
    source => "puppet:///modules/base/default_snmpd",
    path   => '/etc/default/snmpd',
    owner  => 'root', group => 'root', mode => '0644',
    backup => ".$::timestamp",
    notify => Service["snmpd"],
  }

  ###############################################################
  ## SERVICEs
  service { 'snmpd':
    ensure    => running,
    enable    => true,
    name      => 'snmpd',
    hasstatus =>  true,
    require   => [
      File['snmpd.conf','default_snmpd'], 
      Package['snmpd'],
    ]
  }

} # end of class base::snmp
