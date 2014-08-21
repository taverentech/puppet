#######################################################
# Groups

class groups {
  notice(">>> groups class <<<")

  # minimum required.
  #group { "logusers":
  #  ensure => "present",
  #}

  # create a group with a specific GID.
  group { "sudo":
    gid    => 27, 
  }
  group { "www-data":
    gid    => 33, 
  }
  group { "users":
    gid    => 100, 
  }

}
