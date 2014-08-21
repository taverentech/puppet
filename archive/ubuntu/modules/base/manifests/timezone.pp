################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module
class base::timezone {
  notify{"Loading base::timezone class": }
  notice(">>> base::timezone client class <<<")

  ###############################################################
  ## PACKAGEs
  package { 'tzdata': ensure => latest }

 if ($::pop != "sql1") {
  ###############################################################
  ## FILEs
  file { 'timezone':
    content => "Etc/UTC\n",
    path    => '/etc/timezone',
    owner   => 'root', group => 'root', mode => '0644',
    backup => ".$::timestamp",
    require => Package["tzdata"],
  }

  ###############################################################
  ## SERVICEs

  ###############################################################
  ## EXECs

  #NOTE this is debian/ubuntu specific
  exec {"update-timezone":
    command => "dpkg-reconfigure --frontend noninteractive tzdata",
    refreshonly => true,
    subscribe => File["timezone"],
  }
 } #end if site not SQL1 - due to watchtower having many Pacific systems

} # end of class base::nscd
