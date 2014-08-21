################################################################
# Base environment configurations
#   HWSCAN - scan hardware and upload to CMDB dropbox

class hwscan {
  notice(">>> hwscan class <<<")
  notify{"class hwscan": }
  tag("safe")

  ##PACKAGE

  ##SERVICE

  ##FILES
  file { "hwscan.sh":
    path       => "/usr/local/bin/hwscan.sh",
    owner      => root,
    group      => root,
    mode       => 755,
    source  => "puppet:///modules/base/hwscan.sh",
  }
  file { "hwscan_cron.d":
    path       => "/etc/cron.d/hwscan",
    owner      => root,
    group      => root,
    mode       => 644,
    source  => "puppet:///modules/base/hwscan_cron.d",
  }

  ##EXECS
  exec { "run-hwscan":
    command     => "/usr/local/bin/hwscan.sh",
    refreshonly => true,
    subscribe   => File["hwscan.sh"],
  }

}
