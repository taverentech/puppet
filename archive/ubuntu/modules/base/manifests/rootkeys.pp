################################################################
# Base environment configurations
# runs on precise, maverick
#
#   Things will likely start here, then move to their own module
class base::rootkeys {
  notify{"Loading base::rootkeys class": }
  notice(">>> base::rootkeys client class <<<")

  ###############################################################
  ## PACKAGEs

  ###############################################################
  ## FILEs

  ###############################################################
  ## SERVICEs

  ###############################################################
  ## EXECs

  define managesshkey ($user, $action, $type, $name) {
    $key = $title
    ssh_authorized_key { "${user}_${action}_${type}_${name}":
      ensure => $action,
      key    => $key,
      user   => $user,
      type   => $type,
      name   => $name,
    }
  }

  #ADD Keys to root authorized_keys file

  managesshkey {"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX":
    user => "root", action => "present", type => "rsa", name => "jdecello-20140110", }

  #REMOVE Keys from root authorized_keys file
  managesshkey {"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX":
    user => "root", action => "absent", type => "rsa", name => "backuppc", }

} # end of class
