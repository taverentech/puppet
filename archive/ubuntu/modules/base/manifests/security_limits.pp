################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class base::security_limits {
  notice(">>> base::security_limits class <<<")
  notify{"class base::security_limits": }

  # nested class/define
  define conf (
    $domain = "root",
    $type = "soft",
    $item = "nofile",
    $value = "10000"
    ) {

      # guid of this entry
      $key = "$domain/$type/$item"

      # augtool> match /files/etc/security/limits.conf/domain[.="root"][./type="hard" and ./item="nofile" and ./value="10000"]

      $context = "/files/etc/security/limits.conf"

      $path_list  = "domain[.=\"$domain\"][./type=\"$type\" and ./item=\"$item\"]"
      $path_exact = "domain[.=\"$domain\"][./type=\"$type\" and ./item=\"$item\" and ./value=\"$value\"]"

      # NOTE Updates non duplicated values in format /^key = value$/
      augeas { "limits_conf/$key":
         context => "$context",
         onlyif  => "match $path_exact size==0",
         changes => [
           # remove all matching to the $domain, $type, $item, for any $value
           "rm $path_list", 
           # insert new node at the end of tree
           "set domain[last()+1] $domain",
           # assign values to the new node
           "set domain[last()]/type $type",
           "set domain[last()]/item $item",
           "set domain[last()]/value $value",
         ],
       }

  } # end of conf 
  ####################################################################
  # DEFAULT security limit configurations

  security_limits::conf { 
    # maximum number of open files/sockets for root
    "all-nofile-soft": domain => '*', type => soft, item => nofile, value =>  60000;
    "all-nofile-hard": domain => '*', type => hard, item => nofile, value =>  65000;
    "root-nofile-soft": domain => root, type => soft, item => nofile, value =>  60000;
    "root-nofile-hard": domain => root, type => hard, item => nofile, value =>  65000;
  }

} # end of class
