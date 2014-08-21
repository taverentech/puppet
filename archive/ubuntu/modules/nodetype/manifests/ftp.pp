#######################################################
#  ftp server configs - dns, ldap

class ftp {
  notice(">>> ftp nodetype class <<<")

  include vsftpd
  include apache2

  file { "/etc/cron.d/ftp-cleanup":
    source  => "puppet:///modules/nodetype/ftp_cron.d_ftp-cleanup",
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }

  file { "/home/ftp/upload":
    ensure  => directory,
    owner   => "ftp",
    group   => "users",
    mode    => 377,
    require => File["/home/ftp"],
  }
  file { "/home/ftp/download":
    ensure  => directory,
    owner   => "ftp",
    group   => "users",
    mode    => 575,
    require => File["/home/ftp"],
  }

  if ($::environment == "dev") {
  } elsif ($::environment == "test") {
  } elsif ($::environment == "stage") {
  } elsif ($::environment == "prod") {

    include users::all_ftp_prod_shell

    $STAFF-README = "Any files you put in these directories will be downloaded by the general\npublic. There are little to no security controls on these directories.  \nIf you do not want hackers or competitors getting these files, do not put \nthem here.  If you have a need for specific files to be securely transmitted \nto others, please mail sysadmin@example.com or ask someone in the systems \nor operations group how you would perform such a transfer. The first option \nwould be using Skype, but other methods are available.\n"

    file { "index.html":
      path   => '/home/ftp/index.html',
      ensure  => file,
      mode    => 0644,
      content => "Please use full pathnames, or if you are uncertain what files you're \nlooking for, please contact the staff member who made the files\navailable.\n",
    }
    file { "download/STAFF-README":
      path   => '/home/ftp/download/STAFF-README',
      ensure  => file,
      mode    => 0644,
      content => $STAFF-README,
    }
    file { "upload/STAFF-README":
      path   => '/home/ftp/upload/STAFF-README',
      ensure  => file,
      mode    => 0644,
      content => $STAFF-README,
    }

    apache2::vhost::conf { "ftp.example.com.conf": }

    #file { "sites_enable_ftp":
    #  path   => '/etc/apache2/sites-enabled/ftp',
    #  ensure => 'link',
    #  target => '/etc/apache2/sites-available/ftp',
    #  require => File["sites-available_ftp"],
    #}
    #file { "sites-available_ftp":
    #    path    => "/etc/apache2/sites-available/ftp",
    #    backup => ".$::timestamp",
    #    owner   => root,
    #    group   => root,
    #    mode    => 644,
    #    source  => [
    #      "puppet:///modules/nodetype/apache2/sites-available_$::fqdn",
    #      "puppet:///modules/nodetype/apache2/sites-available_ftp",
    #    ],
    #    require => Package["apache2"],
    #}

  }

}
