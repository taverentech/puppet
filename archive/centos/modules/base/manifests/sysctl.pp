################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class sysctl {
  notify{"class sysctl": }

  # nested class/define
  define conf ( $value ) {

    # $name is provided by define invocation

    # guid of this entry
    $key = $name

    $context = "/files/etc/sysctl.conf"

    augeas { "sysctl_conf/$key":
      context => "$context",
      onlyif  => "get $key != '$value'",
      changes => "set $key '$value'",
      notify  => Exec["sysctl"],
    }

  } 

  file { "sysctl_conf":
    name => $operatingsystem ? {
      default => "/etc/sysctl.conf",
    },
  }

  exec { "sysctl":
    command => "sysctl -p",
    refreshonly => true,
    subscribe => File["sysctl_conf"],
  }

  ####################################################################
  # DEFAULT kernel configurations

  conf { "net.ipv4.tcp_max_syn_backlog": value => 8192; }
  conf { "net.ipv4.ip_local_port_range": value => '10240 65535'; }
  conf { "net.core.somaxconn": value => 1024; }
  conf { "net.ipv4.tcp_timestamps": value => 0; }
  conf { "net.ipv4.tcp_window_scaling": value => 1; }
  conf { "net.ipv4.tcp_max_tw_buckets ": value =>  1800000; }
  conf { "net.ipv4.tcp_syncookies ": value =>  0; }
  conf { "net.ipv4.tcp_tw_reuse": value => 1; }
  conf { "net.ipv4.tcp_tw_recycle": value => 1; }
  conf { "net.ipv4.tcp_fin_timeout": value => 20; }
  conf { "vm.swappiness": value => 0; }

}
