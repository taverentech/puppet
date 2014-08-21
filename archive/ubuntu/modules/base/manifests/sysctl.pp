################################################################
# Base environment configurations
# Things will likely start here, then move to their own module

class base::sysctl {
  notify{"class base::sysctl": }
  notice(">>> base::sysstat class <<<")

# nested class/define
  define conf ( $value ) {

# $name is provided by define invocation

# guid of this entry
    $key = $name

    $context = "/files/etc/sysctl.conf"

    augeas { "sysctl_conf/$key":
      context => "$context",
      onlyif => "get $key != '$value'",
      changes => "set $key '$value'",
      notify => Exec["sysctl"],
    }

  } # end if define

  file { "sysctl_conf":
    path => $osfamily ? {
      Debian => "/etc/sysctl.conf",
      Redhat => "/etc/sysctl.conf",
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

  # RECOMENDED configs we should try/consider - jdecello
  #conf { "net.ipv4.ip_local_port_range": value => '10240 65535'; }
  #conf { "net.ipv4.tcp_max_syn_backlog": value => 8192; }
  #conf { "net.ipv4.tcp_timestamps": value => 0; }
  #conf { "net.ipv4.tcp_max_tw_buckets ": value => 1800000; }
  #conf { "net.ipv4.tcp_syncookies ": value => 0; }
  #conf { "net.ipv4.tcp_tw_reuse": value => 1; }
  #conf { "net.ipv4.tcp_tw_recycle": value => 1; }
  #conf { "net.ipv4.tcp_fin_timeout": value => 20; }

  # rp_filter was set to 0 in production for some unknown reason
  #  Do not update existing production, yet allow it to be set on rebuilds
  if ( $::cluster != "production" and $::cluster != "" ) {
    conf { "net.ipv4.conf.default.rp_filter": value => 1; }
    conf { "net.ipv4.conf.all.rp_filter": value => 1; }
  }

  conf { "net.core.somaxconn": value =>65535; }
  conf { "kernel.core_pattern":  value => 'core.%h.%e.%p'; }
  conf { "vm.swappiness": value => 1; }
  # optimization start - used on hadoop servers
  # increase TCP max buffer size setable using setsockopt()
  conf { "net.ipv4.tcp_rmem": value => "4096 87380 8388608"; }
  conf { "net.ipv4.tcp_wmem": value => "4096 87380 8388608"; }
  # increase Linux auto tuning TCP buffer limits
  # min, default, and max number of bytes to use
  # set max to at least 4MB, or higher if you use very high BDP paths
  conf { "net.core.rmem_max": value => 8388608; }
  conf { "net.core.wmem_max": value => 8388608; }
  conf { "net.core.netdev_max_backlog": value => 5000; }
  conf { "net.ipv4.tcp_window_scaling": value => 1; }
  if ( $::is_virtual == "false" ) {
    #Set only on physical servers
    conf { "net.netfilter.nf_conntrack_max": value => 250000; }
    conf { "net.ipv4.netfilter.ip_conntrack_tcp_timeout_established": value=>3600; }
    conf { "net.netfilter.nf_conntrack_generic_timeout": value=>120; }
  }

} # of of base::sysctl
