##########################################################
# Dataeng srvadmin - Dell PERC MegaRaid stuff for Internap

class dataeng {
  notice(">>> dataeng class <<<")
  notify{"class dataeng": }
  tag("safe")

  #TODO Swtich to this later if ($::has_megaraid == 'true') {
  if ($::domain == 'sjc2.example.com') and ($::virtual == 'physical') {
    # stop and disable Dell hwraid monitor (Java)
    #     we still have basic snmp nagios check working (not Java)

    package { "megaraid-status": ensure     => latest, }

    service { 'dataeng':
      enable => false,
      ensure => stopped,
      hasstatus => true,
      hasrestart => true,
      require => Package ["megaraid-status"],
    }

  }

}
