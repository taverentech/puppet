#######################################################
# Stor Agent - AACRaid stuff for Softlayer - runs java

class stor_agent {
  notice(">>> stor_agent class <<<")
  notify{"class stor_agent": }
  tag("safe")

  # stop and disable hwraid monitor (Java)
  #     we still have basic snmp nagios check working (not Java)
  if ($::pop != "sjc2") and ($::virtual == "physical") {

    ##PACKAGES
    package { storman: ensure => installed }

    ##FILES
    file { "stor_agent-service-check":
        path    => "/usr/local/sbin/stor_agent-service-check.pl",
        backup => ".$::timestamp",
        owner   => root,
        group   => root,
        mode    => 775,
        source  => [
          "puppet:///modules/base/scripts/stor_agent-service-check.pl",
        ],
    }

    ##SERVICES
    service { "stor_agent":
      ensure   => stopped,
      enable   => false,
      status   => "/usr/local/sbin/stor_agent-service-check.pl",
      require  => Package ["storman"],
    }

    #exec { "stop_stor_agent":
    #  command => "/etc/init.d/stor_agent stop",
      #onlyif  => 'ps axwww | grep java | grep StorMan | grep ManagementAgent',
    #  onlyif  => "/usr/local/sbin/stor_agent-service-check.pl",
    #  require => File["stor_agent-service-check"],
    #}
      #unless  => "/usr/local/sbin/stor_agent-service-check.pl",
  }

}
