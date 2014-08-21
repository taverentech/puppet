################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class network {

  notice(">>> network.pp <<<")
  notify{"class network": }
  tag("safe")
  
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
#  if ( $::nodetype != "" and $::pop != "" and $::environment != "") {
    file { "/etc/resolv.conf":
      owner => root,
      group => root,
      mode => 644,
      backup => ".$::timestamp",
      links => follow,
      source => [
        "puppet:///modules/base/resolv.conf_$::fqdn",
        "puppet:///modules/base/resolv.conf_$::domain",
        "puppet:///modules/base/resolv.conf_DEFAULT",
      ]
    }
#  } #end of sanity check

}
