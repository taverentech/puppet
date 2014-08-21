#######################################################
# HAProxy heartbeat

class heartbeat {
  notice(">>> heartbeat class <<<")
  sysctl::conf { "net.ipv4.ip_nonlocal_bind": value => 1; }
  #TODO included by haproxy? do all haproxy run heartbeat?
}
