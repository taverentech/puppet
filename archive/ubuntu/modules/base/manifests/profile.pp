# Base use profile/shell configuration

class base::profile {
  notice(">>> profile settings <<<")
  notify{"class profile": }
  tag("accounts")

  ###############################################################
  ## FILEs

  # Copy down entire source directory
  file { "/etc/skel/":
    source  => "puppet:///modules/base/skel",
    ensure => directory,
    owner => 'root', group => 'root', mode  => '0644',
  }
  file { "/etc/bash.bashrc":
    source  => "puppet:///modules/base/bash.bashrc",
    backup => ".$::timestamp",
    owner => 'root', group => 'root', mode  => '0644',
  }
  file { "/etc/profile":
    source  => "puppet:///modules/base/profile",
    backup => ".$::timestamp",
    owner => 'root', group => 'root', mode  => '0644',
  }
  file { "/etc/login.defs":
    source  => "puppet:///modules/base/login.defs",
    backup => ".$::timestamp",
    owner => 'root', group => 'root', mode  => '0644',
  }

  file { "/etc/profile.d/":
    ensure => directory,
    owner => 'root', group => 'root', mode  => '0755',
  }
  file {"prompt.sh":
    path    => "/etc/profile.d/prompt.sh",
    ensure  => file,
    owner   => root, group => root, mode => 0755,
    content    => template("base/profile.d/prompt.sh.erb"),
    require => File[ "/etc/profile.d/" ],
  }
  file {"title.sh":
    path    => "/etc/profile.d/title.sh",
    ensure  => file,
    owner   => root, group => root, mode => 0755,
    content    => template("base/profile.d/titlebar.sh.erb"),
    require => File[ "/etc/profile.d/" ],
  }
} # end of class
