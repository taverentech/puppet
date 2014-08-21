# Base use profile/shell configuration

class profile {
  notice(">>> profile settings <<<")
  notify{"class profile": }
  tag("accounts")
  tag("safe")

  # Copy down entire source directory
  file { "/etc/skel/":
    source  => "puppet:///modules/base/skel",
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }
  # Copy down entire source directory
  file { "/etc/profile.d/":
    source  => "puppet:///modules/base/profile.d",
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }
  file { "/etc/bash.bashrc":
    source  => "puppet:///modules/base/bash.bashrc",
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }
  file {"prompt.sh":
    path    => "/etc/profile.d/prompt.sh",
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0755,
    source  => [
      "puppet:///modules/base/profile.d/prompt.sh_$::fqdn",
      "puppet:///modules/base/profile.d/prompt.sh_$::environment",
      "puppet:///modules/base/profile.d/prompt.sh_DEFAULT",
    ],
      #"puppet:///modules/base/profile.d/prompt.sh_$::nodetype.$::environment",
    require => File[ "/etc/profile.d/" ],
  }
  file {"title.sh":
    path    => "/etc/profile.d/title.sh",
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0755,
    content    => template("base/profile.d/titlebar.sh.erb"),
    require => File[ "/etc/profile.d/" ],
  }

} # end of class
