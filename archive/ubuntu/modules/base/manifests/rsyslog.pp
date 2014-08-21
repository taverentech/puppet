################################################################
# Base environment configurations
# runs on precise, maverick
#
# == Class: base::rsyslog  debian
#
# === Parameters
#
# === Authors
#
# Joe DeCello
#
#
class base::rsyslog (
  $logstash_port         =5544,
  $rsyslog_port          =2514,
  $UDPServerAddress      ="127.0.0.1",
  $UDPServerRun          =514,
  $Transform_pri         ='<%pri%>',
) {

  ###############################################################
  ## VARs
  $is_relp_server = $::fqdn ? {
        "fs3.sjc1.eng.example1.com" => yes,
        "fs3.iad1.prod.example1.com" => yes,
        default => no,
  }
  notify{"DEBUG: $::fqdn relp server check: $is_relp_server": }
  $relp_server = $::pop ? {
    "iad1" => "relp.sjc1.eng.example1.com",
    "sjc1" => "relp.sjc1.eng.example1.com",
    "sql1" => "relp.sjc1.eng.example1.com",
    default=> "relp.sjc1.eng.example1.com",
  }
  notify{"DEBUG: relp server is $relp_server": }

  ## PACKAGEs
  ##
  $relpclientpkgs = [
    'rsyslog',
    'rsyslog-relp',
  ]

  package { $relpclientpkgs:
    ensure => installed,
  }

  ## FILEs for rsyslog
  ##
  file { '/etc/rsyslog.d':
    ensure => directory,
    owner => 'root', group => 'root', mode => '0755',
    require => Package['rsyslog'],
  }

  if ($is_relp_server == "yes") {
    #VAR for relp rsyslog servers
    $MMQWorkerThreads       =  32
    $MMQWorkerThreadMinMsgs = 512
    $MMQDequeueBatchSize    = 512
    ## FILEs for relp servers
    ##
    ## TODO
  } else {
    #VAR for relp rsyslog clients
    $MMQWorkerThreads      =  16
    $MMQWorkerThreadMinMsgs= 256
    $MMQDequeueBatchSize   =  64
  }

  ## FILEs
  ##
  file { '/etc/rsyslog.d/60-relp.conf':
      ensure => absent, # remove old client config
  }
  file { '/etc/rsyslog.d/01-global-parameters.conf':
    ensure => file,
    owner => 'root', group => 'root', mode => '0644',
    content => template("base/rsyslog.d/01-global-parameters.conf.erb"),
    backup => ".$::timestamp",
    require => File['/etc/rsyslog.d'],
    notify => Service["rsyslog"],
  }
  file { '/etc/rsyslog.d/10-input-network-local-legacyfmt.conf':
    ensure => file,
    owner => 'root', group => 'root', mode => '0644',
    backup => ".$::timestamp",
    content => template("base/rsyslog.d/10-input-network-local-legacyfmt.conf.erb"),
    require => File['/etc/rsyslog.d'],
    notify => Service["rsyslog"],
  }
  # relp server only
  file { '/etc/rsyslog.d/60-relp-forward-legacyfmt.conf':
    ensure => $is_relp_server ? {
      "yes" => absent,
      default => file,
    },
    owner => 'root', group => 'root', mode => '0644',
    backup => ".$::timestamp",
    content => template("base/rsyslog.d/60-relp-forward-legacyfmt.conf.erb"),
    require => File['/etc/rsyslog.d'],
    notify => Service["rsyslog"],
  }

  ## FILEs for relp both clients and servers
  ##
  ## TODO

  ## SERVICEs
  service { "rsyslog":
    name => $operatingsystem ? {
      Debian => "rsyslog",
      Ubuntu => "rsyslog",
      default => "rsyslog",
    },
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require => Package["rsyslog"],
  }

} # end of base::rsyslog
