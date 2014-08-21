######################################################
# Support

class tools-web {
  notice(">>> tools-web class <<<")

  include tools-entitlements

  include apache2
  include apache2::openid

  $toolspackages = [
    "python2.7",
    "libapache2-mod-wsgi",
    "python-dev",
    "libldap2-dev",
    "libsasl2-dev",
  ]
    #"libsqlite3-dev",
    #"libssl-dev", part of base already
    #"libopkele-dev",
    #"libopkele3", part of openid already
  package {
    $toolspackages: ensure => installed,
  }

  if ($::environment == "dev") {

  } elsif ($::environment == "test") {
      # Configure nginux Vhost configs using define

  } elsif ($::environment == "stage") {

  } elsif ($::environment == "prod") {
      # Configure Apache Vhost configs - remove default
      file { "default.link":
        path   => '/etc/nginx/sites-enabled/default',
        ensure => 'absent',
      }
      # Configure nginux Vhost configs using define
      apache2::vhost::conf { "authenticorn.symcpe.com.conf": }
      apache2::vhost::conf { "authenticorn.symcpe.com-SSL.conf": }
  } # end of prod

}
