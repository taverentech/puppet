#######################################################
# VSFtpd

class vsftpd {
  notice(">>> vsftpd class <<<")
  notify{"Loading vsftpd class": }

  package { "vsftpd": 
    ensure => installed,
    require => User["ftp"],
  }

  file { "/etc/vsftpd.conf":
    source  => "puppet:///modules/vsftpd/vsftpd.conf",
    require => Package["vsftpd"],
    owner => 'root',
    group => 'root',
    mode  => '0755',
    notify => Service[ "vsftpd" ],
  }

  service { "vsftpd":
    enable => true,
    ensure => running,
    require => File["/etc/vsftpd.conf"],
  }

  user { ftp:
    comment => "Anonymous FTP",
    home    => "/home/ftp",
    shell   => "/bin/false",
    gid     => 2020,
    uid     => 2020,
  }

  file { "/home/ftp":
    ensure  => directory,
    owner   => "root",
    group   => "users",
    mode    => 755,
    require => [ User[ftp], Group[ftp] ],
  }

  group { ftp:
    gid => 2020,
  }

}
