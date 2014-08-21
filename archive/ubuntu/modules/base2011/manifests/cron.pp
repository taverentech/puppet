################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class cron {
  notice(">>> cron.pp <<<")
  notify{"class cron": }
  tag("safe")

  ##PACKAGE
  package { "cron":
    ensure     => latest,
  }

  ##SERVICE
  service { "cron":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package ["cron"],
  }

  ##FILES
  file { "/etc/cron.d":
    owner => root,
    group => root,
    mode => 644,
    recurse => true,
  }

}
