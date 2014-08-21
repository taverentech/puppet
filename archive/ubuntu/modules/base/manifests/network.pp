################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class base::network {
  notify{"network.pp": }
  notice(">>> base::network class <<<")

  $dns_sjc1_ns1 = "172.20.4.2"
  $dns_sjc1_ns2 = "172.20.5.2"
  $dns_sql1_ns1 = "172.16.0.21"
  $dns_sql1_ns2 = "172.16.0.22"
  $dns_iad1_ns1 = "10.0.1.21"
  $dns_iad1_ns2 = "10.0.1.21"

  if ( $::pop == "sjc1" ) {
    $dns_ns1 = $dns_sjc1_ns1
    $dns_ns2 = $dns_sjc1_ns2
    $dns_searchpath = "sjc1.eng.example1.com example1.com"
  } elsif ( $::pop == "iad1" ) {
    $dns_ns1 = $dns_iad1_ns1
    $dns_ns2 = $dns_iad1_ns2
    $dns_searchpath = "iad1.prod.example1.com ash2.example2.com iad1.staging.example1.com example1.com"
  } else {
    $dns_ns1 = $dns_sjc1_ns1
    $dns_ns2 = $dns_sjc1_ns2
    $dns_searchpath = "example1.com"
  }
  ##PACKAGES

  ##SERVICES

  ##FILES

  file { "/etc/hosts":
    owner => root,
    group => root,
    mode => 644,
    backup => ".$::timestamp",
  }
  host {'self':
      ensure       => present,
      name         => $::fqdn,
      host_aliases => $::hostname,
      ip           => $::ipaddress,
      comment      => "Managed by Puppet",
  }
    
  #PROTECT against taking action if factoids are null
  #  TODO - for now, do not update resolve.conf in iad1
  if ( $::pop != "" and $::pop != "iad1") {
    file { "/etc/resolv.conf":
      owner => root, group => root, mode => 644,
      backup => ".$::timestamp",
      links => follow,
      content => template("base/resolv.conf.erb"),
    }
  } #end of sanity check
} #end of class
