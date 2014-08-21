################################################################
# Base environment configurations
#   Things will likely start here, then move to their own module

class security {
  notify{"class security": }

  # TODO - this caused a Cannot alias File[security.root.my.cnf] to
  #This fixes perms on existing file - on servers not including mysql
  #file { "security.root.my.cnf":
  #    path       => "/root/.my.cnf",
  #    owner      => root,
  #    group      => root,
  #    mode       => 400,
  #}

}
