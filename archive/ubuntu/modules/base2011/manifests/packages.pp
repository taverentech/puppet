################################################################
# Base environment packages
#   Things will likely start here, then move to their own module

class base::packages {
  notice(">>> packages.pp <<<")
  notify{"class base::packages": }
  tag("safe")

  $rmpackages = [
    "apparmor",
    "joe",
    "ufw",
    "munin-node",
    "munin-common",
  ] 
  package { $rmpackages: ensure => absent }

  #done by installsystem script one time
  #"libapache2-mod-php5 apache2* php5* mysql-* bind9 mysql-*"

  # Optional packages we want installed at build
  $defpackages = [
  "chkconfig",
  "netcat",
  "vim",
  "nano",
  "curl",
  "unzip",
  "socat",
  "vnstat",
  "sysvinit-utils",
  "locate",
  "unrar-free",
  "screen",
  "build-essential",
  "gftp-text",
  "libpcre3-dev",
  "libssl-dev",
  "subversion",
  "autoconf",
  "autoconf2.13",
  "libxml2-dev",
  "libxml-perl",
  "libxml-regexp-perl",
  "libxml-dom-perl",
  "libbz2-dev",
  "zlib1g-dev",
  "libmcrypt-dev",
  "libmhash-dev",
  "libmhash2",
  "libgd2-xpm-dev",
  "libtool",
  "bsd-mailx",
  "zip",
  "bzip2",
  "wget",
  "nmap",
  "mc",
  "git-core",
  "whois",
  "lynx",
  "tshark",
  "traceroute",
  "logtail",
  "bc",
  "xfsprogs",
  "xfsdump",
  "atop",
  "augeas-tools",
  "python-software-properties",
  "libpq-dev",
  "libpq5",
  "ldap-utils",
  "tagcoll",
  "libmysqlclient-dev",
  "libdbi-perl",
  "ngrep",
  "ack-grep",
  ]
  #"libdbd-mysql-perl",	# NOTE: not compatible with Perconal MySQL 5.5 pkgs

  package { $defpackages: ensure => installed }

  # Everything except Debian 5/6
  if ($::lsbdistcodename != "lenny") and
     ($::lsbdistcodename != "squeeze") {
    package { "upstart": ensure => installed, }
    package { "tmux": ensure => installed, }
    package { "debtags": ensure => installed, }
    package { "s3cmd": ensure => installed, }	# http://s3tools.org/s3cmd
  }

  if ($::virtual == "xenu") {
    package { "numactl": ensure => absent }
  } else {
    package { "numactl": ensure => installed }
  }
}
