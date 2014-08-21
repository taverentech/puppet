################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class issue {

  notice(">>> issue class <<<")
  notify{"class issue": }
  tag("safe")

  # /etc/issue
  file {"/etc/issue":
    ensure  => file,
    path    => "/etc/issue",
    mode    => 0644,
    content => "Welcome to ${::fqdn},\n IP: ${::ipaddress}, MAC: ${::macaddress},\n ${::lsbdistdescription} example Server\n",
  }

}
