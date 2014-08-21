#######################################################
# Mongo DB

import "*.pp"

class mongodb {
  notify{"Loading mongodb class": }
  tag("mongodb")

  # Do on all MongoDB servers
  sysctl::conf { "vm.zone_reclaim_mode": value => 0; }

  realize ( Users::Functions::Localuser["mongodb"], )
  group { "mongodb": gid    => 4003, }

  ##PACKAGES
  # it seems backwarks, but we must pull our init first before package
  package { "mongodb": 
      name   => "mongodb-10gen",
      ensure => installed, 
      require => [ 
        User["mongodb"], 
        Group["mongodb"], 
        File["init.d_mongodb"],
      ],
  }

  ##FILES
  #Pull down standard example init.d/mongodb - all other inits are LINKS to this
  file { "init.d_mongodb":
        path => "/etc/init.d/mongodb",
        source => "puppet:///modules/mongodb/init.d_mongodb",
        owner => 'root',
        group => 'root',
        mode  => '0755',
        backup => ".$::timestamp",
  }
  #add mongodb etc dir for example init wrapper
  file { "etc_mongodb":
      name   => "/etc/mongodb",
      ensure => directory, 
      owner => 'root',
      group => 'root',
      mode  => '0755',
      require => [ 
        User["mongodb"], 
        Group["mongodb"], 
      ],
  }

  ##SERVICES - manage service by nodetype
  #service { "mongodb":
      #enable => true,      #NOTE  not needed on host needing client only
      #ensure => running,   #NOTE will break wrapper init on multi instance
      #hasstatus => true,
      #hasrestart => true,
      #require => Package["mongodb"],
  #}

  #NOTE - this sets up config, init, service for example multi mongo instance
  #  Call this like this: mongo::instance { "config": }
  define instance ( ) {
    $instance = $title
      file { "exp-mongo-${instance}-init":
        path => "/etc/init.d/mongodb-${instance}",
        source => "puppet:///modules/mongodb/init.d_mongodb",
        owner => 'root',
        group => 'root',
        mode  => '0755',
        backup => ".$::timestamp",
      }
      file { "exp-mongo-${instance}":
        path => "/etc/mongodb/mongodb-${instance}",
        source => [
          "puppet:///modules/nodetype/mongodb/mongodb-${instance}_$::nodetype.$::environment",
          "puppet:///modules/nodetype/mongodb/mongodb-${instance}_$::nodetype",
          "puppet:///modules/nodetype/mongodb/mongodb-${instance}",
        ],
        owner => 'root',
        group => 'root',
        mode  => '0644',
        backup => ".$::timestamp",
        require => Package["mongodb-10gen"],
        notify => Service["mongodb-${instance}"],
      }
      service { "mongodb-${instance}":
        enable => true,
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        require => File["exp-mongo-${instance}", "exp-mongo-${instance}-init"],
      }
  }

} # end of class mongodb
