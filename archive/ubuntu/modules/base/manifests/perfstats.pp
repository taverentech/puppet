################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class base::perfstats {
  notify{"Loading base::perfstats class": }
  notice(">>> base::perfstats client class <<<")

  ###############################################################
  ## VARs
  # Set perfstats_server by cluster - used by statsCollector.pl tmpl
  $perfstats_server = $::cluster ? {
    "production" => "perfstats.iad1.prod.example1.com",
    "production-euwest1" => "perfstats.iad1.prod.example1.com",
    "staging" => "perfstats.iad1.staging.example1.com",
    "qe1" => "perfstats.qe1.example1.com",
    "qe1-uswest2" => "perfstats.qe1.example1.com",
    default=> "none",
  }
  notify{"DEBUG: perfstats_server is $perfstats_server": }

  ###############################################################
  ## PACKAGEs
  # done in base::packages

  ###############################################################
  ## FILEs
  file { "example1/misc":
    path    => "/usr/local/example1/misc",
    ensure  => directory,
    owner   => 'root', group   => 'root', mode    => '0644',
    #require => File ["local_example1"],
  }
  file { "example1/misc/stats":
    path    => "/usr/local/example1/misc/stats",
    ensure  => directory,
    owner   => 'root', group   => 'root', mode    => '0755',
    require => File ["example1/misc"],
  }
  file { 'statsCollector.pl':
    path    => '/usr/local/example1/misc/stats/statsCollector.pl',
    source  => 'puppet:///modules/base/statsCollector.pl',
    owner   => 'root', group => 'root', mode => '0755',
    backup => ".$::timestamp",
    require => File ["example1/misc/stats"],
  }
  if ( $perfstats_server == "none" ) {
    file { "cron_stats":
      path => "/etc/cron.d/stats",
      ensure => absent,
    }
  } else {
    file { "cron_stats":
      path => "/etc/cron.d/stats",
      ensure => file,
      content => template("base/stats_cron.d.erb"),
      owner => root, group => root, mode => 644,
      require => File ["statsCollector.pl"],
    }
  }

  ###############################################################
  ## SERVICEs

} # end of class base::perfstats
