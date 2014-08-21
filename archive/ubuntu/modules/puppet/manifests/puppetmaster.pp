#######################################################
# Puppetmaser

class puppetmaster {
  notify{"Loading puppetmaser class": }

  ##PACKAGES
  $puppetmasterpkgs = [
    "puppetmaster",
    "puppetmaster-common",
  ]
  package { 
    $puppetmasterpkgs: ensure => $lsbdistcodename ? {
      "precise" => "2.7.11-1ubuntu2",
      "lucid" => "2.7.11-1puppetlabs1",
    },
  }
  $passengerpkgs = [
    "apache2-prefork-dev",
    "libapr1-dev",
    "libaprutil1-dev",
    "libcurl4-openssl-dev",
    "ruby1.8-dev",
    "rubygems",
  ]
  package { 
    $passengerpkgs: ensure => installed,
  }

}
