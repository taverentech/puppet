########################################################
# Puppet class users::functions to create User accounts
#   Users are then realized as needed based on servergrp

class users::functions {
  notice(">>> users::functions.pp <<<")

  define localuser ( $gcos, $uid, $shell ) {

    $username = $title

    user { $username:
      comment => "$gcos",
      home    => "/home/$username",
      shell   => "$shell",
      gid     => "100",
      uid     => $uid,
      require => Group["users"],
    }

    # DO NOT do recursive chmod
    #mode    => 755,
    file { "/home/$username":
      ensure  => directory,
      owner   => $username,
      group   => "users",
      require => [ User[$username], Group["users"] ],
    }

    file { "/home/$username/.ssh":
      ensure  => directory,
      owner   => $username,
      group   => "users",
      mode    => 700,
      require => File["/home/$username"],
    }

    # make sure that the ssh key authorized files exists with correct perms
    file { "/home/$username/.ssh/authorized_keys2":
      ensure  => absent,
    }
    file { "/home/$username/.ssh/authorized_keys":
      ensure  => present,
      owner   => $username,
      group   => "users",
      mode    => 600,
      backup => ".$::timestamp",
      source  => "puppet:///modules/users/authorized_keys/$username",
      require => File["/home/$username/.ssh"],
    }

  } # end of define localuser

  define disable ( ) {
    $username = $title
    #1. change u_unix_shell to /bin/false
    exec { "disable_shell_$username":
      command => "usermod --shell /bin/false $username",
      onlyif  => "grep ^$username: /etc/passwd |grep -v -c /bin/false",
    }
    #2. remove sshkeys file(s)
    file { "rm_authorized_keys_$username":
      path => "/home/$username/.ssh/authorized_keys",
      ensure  => absent,
    }
    file { "rm_authorized_keys2_$username":
      path => "/home/$username/.ssh/authorized_keys2",
      ensure  => absent,
    }
    #3. lock password (just in case)
    exec { "lock_pw_$username":
      command => "passwd -l $username",
      onlyif  => "grep ^$username: /etc/shadow |grep -c -v ^$username:\!",
    }
    #4. remove user from any groups (aka sudo)
    exec { "rm_groups_$username":
      command => "usermod -G '' $username",
      onlyif  => "groups $username |awk '{print \$4}' |grep -c --perl-regexp .",
    }
    exec { "rm_group_$username":
      command => "usermod -g 100 $username; groupdel $username",
      onlyif  => "groupmod $username",
    }
    #5. rm screen dir (just in case)
    exec { "rm_screen_$username":
      command => "rm -rf /var/run/screen/S-$username",
      onlyif  => "ls /var/run/screen/S-$username",
    }
  }

} # end class users::functions

class groups::functions {
  # Function to add user to group
  define adduser ( $unique, $gname, $uname ) {
     exec { "$unique-group_add_$uname":
       command => "usermod --append -G $gname $uname",
       onlyif  => "groups $uname |grep -v -c $gname",
       require => [ User["$uname"], Group["$gname"] ],
     }
  }
}
