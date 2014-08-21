################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

# Dynamic Config - configuration management before puppet
class base::dyncfg {
  notice(">>> dyncfg class <<<")
  notify{"class dyncfg": }

  file { "/etc/cron.d/dyncfg":
    source  => $::nodetype ? {
      "admin" => "puppet:///modules/base/dyncfg_cron.d_enabled",
      default => "puppet:///modules/base/dyncfg_cron.d_disabled",
    },
    owner => 'root', group => 'root', mode  => '0644',
  }

}

######################################################
