# Base lscripts local scripts

class base::lscripts {
  notice(">>> base::lscripts settings <<<")
  notify{"class base::lscripts": }

  # Copy down entire source directory
  #   does not remove local extra files wihtout purge
  file { "local_scripts":
    path => "/usr/local/scripts",
    ensure => directory,
    recurse => true,
    source  => "puppet:///modules/base/local_scripts/",
    ignore => ".git",
    owner => 'root', group => 'root', mode  => '0755',
    backup  => ".$::timestamp",
  }
  file { "local_scripts_locks":
    path => "/usr/local/scripts/locks",
    ensure => directory,
    owner => 'root', group => 'root', mode  => '01777',
    require => File["local_scripts"],
  }

} # end of class
