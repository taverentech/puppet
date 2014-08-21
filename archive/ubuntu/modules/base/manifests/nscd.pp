################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module
class base::nscd {
  notify{"Loading base::nscd class": }
  notice(">>> base::nscd client class <<<")

  ###############################################################
  ## PACKAGEs
  $nscdclientpkgs = [ "nscd", ]
  package { $nscdclientpkgs: ensure => installed }

  ###############################################################
  ## FILEs
  file { 'nscd.conf':
    path    => '/etc/nscd.conf',
    source  => 'puppet:///modules/base/nscd.conf',
    owner   => 'root', group => 'root', mode => '0644',
    backup => ".$::timestamp",
    notify => Service["nscd"],
  }

  ###############################################################
  ## SERVICEs
  service { 'nscd':
    ensure    => running,
    enable    => true,
    name      => 'nscd',
    hasstatus =>  true,
    require   => [ File['nscd.conf'], Package['nscd'], ],
  }

} # end of class base::nscd
