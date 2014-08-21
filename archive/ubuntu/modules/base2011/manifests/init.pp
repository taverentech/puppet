################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

import "*.pp"

class base {
  notify{"class base": }

  tag("base")
#  notify{"Loading base class": }

# include other classes in the base module here
  include apt
  include base::packages
  include bluetooth	# disables
  include cron
  include dataeng	# disables
  include grub		# fix TIMEOUT
  include hwscan
  include issue
  #include modprobe
  include motd
  include network	# resolve.conf, hosts
  include nodetype
  include nimbus	# disables
  include ntpclient
  include pam_d
  include profile
  include security	# Misc security settings
  include security_limits # does not apply to upstart scripts
  include scheduler	# set disk to deadline
  include snmp
  include src-scripts	# maintain /usr/src/scripts
  include sslcerts	# include example star certs
  include ssh
  include stor_agent	# disables
  include sudo
  include sysctl	# Updates values with augeas
  include sysstat
  include timezone
  include verify	# for validation only, does nothing

} # end of class
