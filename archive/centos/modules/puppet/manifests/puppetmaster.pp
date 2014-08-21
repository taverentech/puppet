#######################################################
# Puppetmaser

class puppetmaster {
  notify{"Loading puppetmaser class": }

  ##PACKAGES
  $puppetmasterpkgs = [
    "puppet-server",
  ]
  package { 
    $puppetmasterpkgs: ensure => $operatingsystemrelease ? {
      "5.8" => installed,
      "6.2" => installed,
      "6.3" => installed,
      default => installed,
    },
  }
  #$passengerpkgs = [
  #  "apache2-prefork-dev",
  #  "libapr1-dev",
  #  "libaprutil1-dev",
  #  "libcurl4-openssl-dev",
  #  "ruby1.8-dev",
  #  "rubygems",
  #]
  #package { 
  #  $passengerpkgs: ensure => installed,
  #}

}
