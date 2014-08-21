###################################################
# This maps hostname to default server class
###################################################

node basenode {
  include base_server
}

################################################
# Servers

#INVENTORY ONLY - Federa Core 5
node "purple.sjc1.eng.example1.com" { include base::puppet }
#INVENTORY ONLY - CentOS
node "bugzilla.sjc1.eng.example1.com" { include base::puppet }

###################################################
# If not matched above will run default base config
###################################################

# default base build
node default inherits basenode {
  notice (">>> default NODE <<<")
}
###################################################
