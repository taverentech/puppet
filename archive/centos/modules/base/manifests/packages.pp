################################################################
# Base environment packages
#   Things will likely start here, then move to their own module

class base::packages {
  notice(">>> packages.pp <<<")
  notify{"class base::packages": }
  tag("safe")

  $rmpackages = [
    "joe",
  ] 
  package { $rmpackages: ensure => absent }

  # Optional packages we want installed at build
  $defpackages = [
  "system-config-network-tui",
  "puppet",
  "augeas",
  "facter",
  "ruby",
  "bind-utils",
  "perl-CPAN",
  "perl-YAML",
  "perl-XML-DOM",
  "perl-XML-Parser",
  "rubygems",
  "make",
  "vim-enhanced",
  "vim-common",
  "perl-TimeDate",
  "telnet",
  "tcpdump",
  "chkconfig",
  "curl",
  "unzip",
  "mlocate",
  "man",
  "man-pages",
  "mailx",
  "screen",
  "subversion",
  "autoconf",
  "zip",
  "bzip2",
  "wget",
  "nmap",
  "mc",
  "lynx",
  "traceroute",
  "strace",
  "git",
  ]
#  "httpd-devel openssl-devel gcc-c++ libcurl libcurl-devel", # for ruby/gems

  package { $defpackages: ensure => installed }

  if ($::virtual == "xenu") {
    package { "numactl": ensure => absent }
  } else {
    package { "numactl": ensure => installed }
  }
}
