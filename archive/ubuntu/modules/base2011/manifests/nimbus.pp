################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class nimbus {
  notice(">>> nimbus class <<<")
  notify{"class nimbus": }
  tag("safe")

  exec { "disable_nimbus":
    command => "/etc/init.d/nimbus stop;update-rc.d -f nimbus remove",
    onlyif  => "chkconfig nimbus |grep -c on || chkconfig nimbus |grep -c 245",
    require => Package["chkconfig"],
  }

}

