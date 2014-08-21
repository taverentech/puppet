################################################################
# Base environment configurations
# runs on precise, maverick
#
#   Things will likely start here, then move to their own module
class base::backuppc {
  notify{"Loading base::backuppc class": }
  notice(">>> base::backuppc client class <<<")

  ###############################################################
  ## PACKAGEs

  ###############################################################
  ## FILEs
  # DO NOT do recursive chmod
  file { "/data/home/backuppc":
    ensure  => directory,
    owner   => backuppc, group => "backuppc", mode => '0755',
    require => [ File["data_home"], User["backuppc"], Group["backuppc"], ],
  }
  file { '/data/home/backuppc/.ssh':
    ensure => directory,
    owner => backuppc, group => backuppc, mode  => '0755',
    require => File["/data/home/backuppc"],
  }
  file { '/data/home/backuppc/.ssh/known_hosts':
    owner => backuppc, group => backuppc, mode  => '0644',
    require => File["/data/home/backuppc/.ssh"],
  }
  file { '/data/home/backuppc/.ssh/authorized_keys':
    content => "#######################\n## Managed by Puppet ##\n#######################\nssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDceG0zDzdD3e3Wce3Sl4HwzqGm1bHiMkdAabacmX13HGTo8h+F94pI6pGpeOEu9Bi1zrJHV9n8opKtccCerGaoC6b7RJh1ptj1LaGB9gccBn3kAI6Jkk5O6oC1KhMfL8slAjmqe9AsOWxQtfpAWbPd5sYtlCsfOjkEJ5MYBkeTmTs7j7lhPCiP4JlllmJ51RH0tMat9xM1WoAC0jJ4Ia15AWeSVl5JcHS5guVzRR8bSMxFvRTIxUoN3AChm6b2Ulwop7JbEP1/3YmMsr6q2jh7n7ZvqZeOiNkcmA3dCT/T65OrjEU3qfdKy5V3RJxALFlHbLRXTxxgF3L+upOIBEO7 backuppc@fs\n",
    owner => backuppc, group => backuppc, mode  => '0644',
    require => File["/data/home/backuppc/.ssh"],
  }
  file { '/data/home/backuppc/.ssh/authorized_keys2':
    ensure => absent,
  }

  ###############################################################
  ## Users & Groups
  user { 'backuppc':
     ensure   => 'present',
     uid=>'4994', gid=>'4994', comment=>'backuppc', home=>'/data/home/backuppc',shell =>'/bin/bash',
  }
  group { 'backuppc':
     ensure   => 'present',
     gid=>'4994',
  }
  # Need to update sshd to Allow backuppc (group) to ssh in
  ssh::addgroup { "backuppc": ; }

  ###############################################################
  ## SERVICEs

  ###############################################################
  ## EXECs

} # end of class base::nscd
