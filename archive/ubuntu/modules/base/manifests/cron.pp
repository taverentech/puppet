################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class base::cron {
  notice(">>> cron.pp <<<")
  notify{"class base::cron": }

  ##PACKAGE
  package { "cron":
    ensure     => installed,
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
