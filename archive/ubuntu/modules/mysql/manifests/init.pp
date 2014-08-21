#######################################################
# Percona MySQL Server 5.5

class mysql {
  notice(">>> mysql server class <<<")
  notify{"Loading mysql class": }

  #Variables used in my.cnf
  # TODO Percona says this is not relavent on linux
  $thread_concurrency = ($::processorcount * 2)

  package { "xtrabackup": ensure => latest }
  #package { "xtrabackup": ensure => "2.0.1-446.$::lsbdistcodename" }

  if ($::lsbdistcodename == "precise") or
     ($::nodetype == "systools") {
    $mysqlpackages = [
      "percona-server-client-5.5",
      "percona-server-server-5.5",
      "percona-server-common-5.5",
      "irqbalance",
    ]
    package { 
      $mysqlpackages: ensure => installed,
    }

    service { "mysqld":
      name => $operatingsystem ? {
        Ubuntu => "mysql",
        default => "mysql",
      },
      enable => true,
      #ensure => running,  # do NOT want puppet restarting mysql
    }
    file { "/etc/init.d/mysql":
      source  => "puppet:///modules/mysql/init.d_mysql",
      owner => 'root',
      group => 'root',
      mode  => '0755',
      backup     => ".$::timestamp",
      require    => Package ["percona-server-server-5.5","percona-server-common-5.5","numactl"],
      #NOnotify     =>XService["mysq"], # do NOT want puppet restarting mysql
    }
    file { "/etc/mysql":
      ensure => directory,
      owner      => root,
      group      => root,
      mode       => 755,
    }
    file { "my.cnf":
      path       => "/etc/mysql/my.cnf",
      ensure     => file,
      owner      => root,
      group      => root,
      mode       => 644,
      backup     => ".$::timestamp",
      content    => template("mysql/my.cnf.erb"),
      require    => Package ["percona-server-server-5.5","percona-server-common-5.5"],
      #NOnotify     =>XService["mysq"], # do NOT want puppet restarting mysql
    }

    file { ".my.cnf":
      path       => "/root/.my.cnf",
      replace    => no,       # only installs if MISSING, will not overwrite
      ensure     => present,
      owner      => root,
      group      => root,
      mode       => 400,
      backup     => ".$::timestamp",
      content    => template("mysql/.my.cnf.erb"),
      require    => Package ["percona-server-server-5.5","percona-server-common-5.5"],
      #NOnotify     =>XService["mysq"], # do NOT want puppet restarting mysql
    }
    exec { 'mysql_rm_ib_logfiles':
      command => "rm -f /var/lib/mysql/ib_logfile?",
      refreshonly => true,
      subscribe => File[".my.cnf"],
    }

    file { '/var/lib/mysql/tzinfo':
      source => '/etc/timezone',
      require    => Package ["percona-server-server-5.5","percona-server-common-5.5"],
    }
    exec { 'mysql_tzinfo_to_sql':
      command => '/usr/bin/mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql',
      refreshonly => true,
      subscribe => File["/var/lib/mysql/tzinfo"],
    }

  } # end of if precise

} # end mysql server class

class mysql::client {
    $mysqlclientpkgs = [
    #  "percona-server-client",
    #  "percona-server-client-5.5",
    #  "percona-server-common-5.5",
    ]
    package { 
      $mysqlclientpkgs: ensure => installed,
    }
}
