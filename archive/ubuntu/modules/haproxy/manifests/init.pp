#######################################################
# HAProxy Load Balancer

import "*.pp"

class haproxy {
  notify{"Loading haproxy class": }
  include heartbeat

  #TODO add file: haproxy.cfg_$::nodetype.$::environment

  if ($::environment == "dev") {

  } elsif ($::environment == "stage") {

  } elsif ($::environment == "prod") {

  }

}
