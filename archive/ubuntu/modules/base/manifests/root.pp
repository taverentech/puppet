################################################################
# Base environment configurations
# runs on precise, maverick
#
#   Things will likely start here, then move to their own module
class base::root {
  notify{"Loading base::root class": }
  notice(">>> base::root client class <<<")

  ###############################################################
  ## PACKAGEs

  ###############################################################
  ## FILEs
  # DO NOT do recursive chmod
  file { "/root":
    ensure  => directory,
    owner   => root, group => "root", mode => '0700',
    require => [ User["root"], ],
  }
  file { '/root/.ssh':
    ensure => directory,
    owner => root, group => root, mode  => '0700',
    require => File["/root"],
  }
  file { '/root/.ssh/known_hosts':
    owner => root, group => root, mode  => '0600',
    require => File["/root/.ssh"],
  }
  file { '/root/.ssh/authorized_keys':
    owner => root, group => root, mode  => '0600',
    require => File["/root/.ssh"],
  }
  file { '/root/.ssh/authorized_keys2':
    ensure => absent,
  }

  ###############################################################
  ## Users
  #TODO - for now, do only production until clear with engineering
  if ( $::domain == 'iad1.prod.example1.com' or 
      $::domain == 'ash2.example1.com' ) {
    user { 'root':
      ensure   => 'present',
      uid=>'0', gid=>'0', comment=>'root', home=>'/root',shell =>'/bin/bash',
      password => 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    }
  } else {
    user { 'root':
      ensure   => 'present',
      uid=>'0', gid=>'0', comment=>'root', home=>'/root',shell =>'/bin/bash',
    }
  }

  ###############################################################
  ## SERVICEs

  ###############################################################
  ## EXECs

} # end of class base::nscd
