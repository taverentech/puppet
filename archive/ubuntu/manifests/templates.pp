# Global default exec paths
Exec {
  path => [
    "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/",
    "/usr/local/bin/", "/usr/local/sbin/",
  ]
}
notice(">>> fqdn is $::fqdn <<<")
notice(">>> domain is $::domain <<<")
notice(">>> cluster is $::cluster <<<")
notice(">>> lsbdistcodename is $::lsbdistcodename <<<")

# Define stages to process manifests
stage { 'first': before => Stage['main'] }
stage { 'last': require => Stage['main'] }

################################################
# internal SERVER classes
################################################
#Common server base_server class
class base_server {
  notice (">>> base_server CLASS <<< ")
  include base
}

#############################################
############## THE END ######################
#############################################
