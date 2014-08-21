#######################################################
# Tight VNC Server

class vncserver {
  notify{"Loading vncserver class": }
  ## Packages
  $vncpackages = [
    "tightvncserver",
    "xterm",
    "fvwm",
  ]
  package { $vncpackages: ensure => installed }
}
