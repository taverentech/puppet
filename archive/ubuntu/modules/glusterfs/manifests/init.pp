#######################################################
# GlusterFS

import "*.pp"

class glusterfs {
  notify{"Loading glusterfs class": }

  service { "glusterd":
    enable => true,
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require=> [ Package["glusterfs"], File["/remote"], ],
  }

  package { "glusterfs": 
    ensure => latest,
  }

  file { "/remote":
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }

# Added to fstab
# backups.dc.i.example.com:storage /remote  glusterfs  defaults,_netdev,noatime  0  0

# TODO - finish and use augeas fstab::conf function
# TODO update based on DATACENTER and NODETYPE
  exec { "add_remote_to_fstab":
    command => "echo 'backups.dc.i.example.com:storage /remote  glusterfs  defaults,_netdev,noatime  0  0' >> /etc/fstab",
    unless  => "grep -c /remote /etc/fstab",
  }
  exec { "mount_remote":
    command => "mount /remote",
    unless  => "mount -l |grep -c /remote",
  }


}
