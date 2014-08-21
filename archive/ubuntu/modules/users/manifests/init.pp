#######################################################
#  Users, Groups, SshKeys

import "*.pp" 
import "auto/*.pp" 

class users {
  notify{"Loading users class": }
  tag("accounts")

  notice(">>> users <<<")  

  if ($::lsbdistcodename == "lucid") {
    package { "mkpasswd": ensure => installed, }
  }

  include users::functions
  include groups::functions
  include groups
  include users::virtual	# Auto-Generated from Service-Now Users
  include users::revoke		# Auto-Generated from Service-Now Entitlements
  include users::default	# Users like sysadmins on every host

}
