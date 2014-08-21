################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class base::ipmi ($ensure = "present",
  #$ipmiuser = "ADMIN",
  $ipmipassword = "CHANGEMENOW") {

  notice(">>> ipmi.pp <<<")
  notify{"class base::ipmi": }

  if ( $is_virtual != "true" ) {

    #These server IPMI/DRACs are broken
    $run_ipmi = $::fqdn ? {
      "host1.exclude.example.com" => "false",
      default=> "true",
    }
    notify{"DEBUG: run ipmi for $::fqdn is $run_ipmi": }
  
    if ( $run_ipmi == "true" ) {
      Package {
        ensure => $ensure
      }
      case $kernel {
        "Darwin" : {
          debug("no ipmitool package for darwin")
        }
        "Linux" : {
          package { ["ipmitool", "openipmi"] : }
        }
        default : {
          package { "ipmitool" : }
        }
      }
      base::kernel::module {
        ["ipmi_si", "ipmi_devintf", "ipmi_watchdog", "ipmi_msghandler", "ipmi_poweroff"] :
        ensure => $has_ipmi ? {
          "true" => "present",
          default => "absent",
        }
      }
      if $has_ipmi == "true" {
        #exec { "ipmi_set_dhcplan" :
        #  command => "ipmitool lan set ipsrc dhcp",
        #  onlyif => "test $(ipmitool lan print |grep \"IP Address Source\" |cut -f 2 -d : |grep -c DHCP) -eq 0",
        #  logoutput => true,
        #}
        #exec { "ipmi_mod_username" :
        #  command => "ipmitool user set name 2 ${ipmiuser}",
        #  onlyif => "test $(ipmitool user list |tail -1 |awk '{print \$2}'|grep -c ${ipmiuser}) -eq 0",
        #  logoutput => true,
        #}
        exec { "ipmi_set_password" :
          command => "ipmitool user set password 2 ${ipmipassword}",
          unless => "test $(ipmitool user test 2 16 ${ipmipassword}",
          logoutput => false,
        }
        #TODO on HPs, need to set passwd 3
      }

    } # end if broken IPMI servers
  } else {
    notice(">>> NO ipmi setup on virtual machines <<<")
  } # end of if NOT virtual server

} # end of base::ipmi
