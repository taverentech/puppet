#######################################################
# Apache

class apache2::openid {
  notify{"Loading apache2 openid class": }

  $openidpkgs = [
    "libopkele3",
    "libopkele-dev",
    "libsqlite3-dev",
    "apache2-threaded-dev",
  ]
  package { $openidpkgs: ensure => installed }

}
