################################################################
# Base environment configurations
#   Updating files in /etc/pam.d/

class pam_d {

  notice(">>> pamd class <<<")
  notify{"class pam_d": }
  tag("safe")

  exec { "echo 'session required pam_limits.so' >> /etc/pam.d/common-session":
    unless => "grep -c -e 'session required pam_limits.so' /etc/pam.d/common-session",
  }

}
