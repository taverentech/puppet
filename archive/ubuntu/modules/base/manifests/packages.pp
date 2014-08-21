################################################################
# Base environment packages
# Things will likely start here, then move to their own module

class base::packages {
  notice(">>> packages.pp <<<")
  notify{"class base::packages": }

  $rmpackages = [
    "joe",
    "apparmor",
    "apparmor-utils",
    #"libapparmor1", 	# needed by CloudStack
    "libapparmor-perl",
    #"libatm1",
    #"ppp",
    #"pppconfig",
    #"pppoeconf",
    #"resolvconf",
    #"ufw",
  ]
  package { $rmpackages: ensure => absent }

# Optional packages we want installed at build
  $basepkgs = [
  "augeas-tools",
  "facter",
  "ruby",
  #"rubygems", - WARNING! may cause upgrade of libc-bin libc6 in PRODUCTION
  "vim",
  "vim-common",
  "telnet",
  "tcpdump",
  "chkconfig",
  "curl",
  "unzip",
  "screen",
  "subversion",
  "zip",
  "bzip2",
  "wget",
  "nmap",
  "mc",
  "lynx",
  "traceroute",
  "strace",
  "git",
  "ethtool",
  "whois",
  "tmux",
  "ldap-utils",
  "dstat",
  #added per SD-429
  "libfile-slurp-perl",
  "libjson-any-perl",
  "libwww-perl",
  "libsys-hostname-long-perl",
  #strted using quotas 20140226
  "quota",
  "dos2unix",
  "htop",
  ]

  package { $basepkgs: ensure => installed }

  #if ($::virtual == "physical" and $::lsbdistcodename != "maverick") {
  if ($::virtual == "physical") {
    package { "numactl": ensure => installed }
  } else {
    package { "numactl": ensure => absent }
  }
}
