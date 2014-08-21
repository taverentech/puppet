#######################################################
# OpenDJ

class opendj {
    notice(">>> opendj class <<<")
    notify{"Loading opendj class": }

    include vncserver
    include java::sunjdk6

    $opendjver="2.4.5"

    ##PACKAGES
    #TODO package { "opendj": ensure => installed }

    ##FILES
    file { "init.d_opendj":
      name       =>  "/etc/init.d/opendj",
      source  => "puppet:///modules/opendj/init.d_opendj",
      owner      => root,
      group      => root,
      mode       => 755,
      backup => ".$::timestamp",
      notify     => Service["opendj"],
    }
    file { "/opt/OpenDJ-${opendjver}":
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => 0755,
      #require => Package["opendj"],
    }
    file { "opendj.link":
      path   => "/opt/OpenDJ",
      ensure => link,
      target => "./OpenDJ-${opendjver}",
      #require => Package["opendj"],
    }
    #example Schema, switched this to jenkins control
    #file { "99-example.ldif":
    #  name       =>  "/opt/OpenDJ/config/schema/99-example.ldif",
    #  source  => "puppet:///modules/opendj/99-example.ldif",
    #  owner      => root,
    #  group      => root,
    #  mode       => 444,
    #  backup => ".$::timestamp",
    #  notify     => Service["opendj"],
    #}

    ## Services
    service { "opendj":
      name => $operatingsystem ? {
        Ubuntu => "opendj",
        default => "opendj",
      },
      enable    => true,
      #ensure   => running,	# stop/start under jenkins control
      hasstatus => false,
      require   => [ Package["sun-j2sdk1.6"], File["init.d_opendj"], ],
    }

} # end of class
