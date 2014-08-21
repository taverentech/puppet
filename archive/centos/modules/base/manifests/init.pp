################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

import "*.pp"

class base {
  notify{"class base": }

  tag("base")
#  notify{"Loading base class": }

# include other classes in the base module here
  include base::packages
  include issue
  include network
  include nodetype
  #include ntpclient
  include pam_d
  include profile
  include security	# Misc security settings
  include security_limits # does not apply to upstart scripts
  include selinux	# SE Linux
  include sslcerts	# include star certs
  include ssh
  include sudo
  include sysctl	# Updates values with augeas
  include sysstat
  include timezone
  include verify	# for validation only, does nothing
  include yumrepo	# for validation only, does nothing

} # end of class
