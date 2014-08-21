# Global default exec paths
Exec { 
  path => [ 
    "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/",
    "/usr/local/bin/", "/usr/local/sbin/",
  ] 
}
notice(">>> fqdn is $::fqdn <<<")
notice(">>> lsbdistcodename is $::lsbdistcodename <<<")

# Define stages to process manifests
stage { 'first': before => Stage['main'] }
stage { 'last': require => Stage['main'] }

#Common example server base_server class
class base_server {
  notice (">>> base_server CLASS <<< ")
  include base
# Include classes outside base module here
  include puppet        # client - tagged puppet
  include nodetype
}

################################################
#  example internal services                  #
################################################
class puppetmaster_server inherits base_server {
  notice (">>> puppetmaster_server class <<< ")
  include puppetmaster
}
class lamp_server inherits base_server {
  notice (">>> lamp_server class <<< ")
  include lamp
}
class  web_server inherits base_server {
  notice (">>>  web_server class <<< ")
  include  web
}

#############################################
############## THE END ######################
#############################################
