#######################################################
#  ftp server config

class ftp {
  notice(">>> ftp nodetype class <<<")

  include vsftpd
  include httpd

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

  #${example-STAFF-README} = "Internal Use only\n"

  file { "index.html":
      path   => '/home/ftp/index.html',
      ensure  => file,
      mode    => 0644,
      content => "Please use full pathnames, or if you are uncertain what files you're \nlooking for, please contact the example staff member who made the files\navailable.\n",
  }
  file { "download/example-STAFF-README":
      path   => '/home/ftp/download/example-STAFF-README',
      ensure  => file,
      mode    => 0644,
      #content => $example-STAFF-README,
    }
    file { "upload/example-STAFF-README":
      path   => '/home/ftp/upload/example-STAFF-README',
      ensure  => file,
      mode    => 0644,
      #content => $example-STAFF-README,
    }

    httpd::vhost::conf { "ftp.example3.net.conf": }

}

