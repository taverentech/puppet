#######################################################
# Systools

class systools {
  notice(">>> systools class <<<")

  include php
  include apache2
  include apache2::openid
  include mysql # server
  include jenkins

  if ($::fqdn == "systools.sjc.example.com") {
    apache2::vhost::conf { "apt.example.com.conf": }
    #apache2::vhost::conf { "apt.example.com-SSL.conf": }
    apache2::vhost::conf { "systools.example.com.conf": }
    apache2::vhost::conf { "systools.example.com-SSL.conf": }
  }
}
