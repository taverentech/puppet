################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class selinux {
  notify{"class selinux": }

  file { "selinux_config":
    path    => "/etc/selinux/config",
    owner   => root,
    group   => root,
    mode    => 644,
    source  => [
      "puppet:///modules/base/selinux_config",
    ],
  }

  exec { "selinux-disable":
    command => "setenforce 0",
    onlyif    => "sestatus |grep -v -c -E 'disabled|permissive'",
  }

}
