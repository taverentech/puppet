###################################################
# This maps hostname to default server class
###################################################

notice(">>> host nodes created, Auto Generated nodes <<<")  

node basenode {
  include base_server
}

################################################
# example Servers
node /^selmy\..*/ {
  notice(">>> nodes - hostname matched puppetmaster.* <<<")  
  include lamp_server
}
node /^bronn\..*/ {
  notice(">>> nodes - hostname matched puppetmaster.* <<<")  
  include lamp_server
}
node /^varys\..*/ {
  notice(">>> nodes - hostname matched puppetmaster.* <<<")  
  include lamp_server
}
node /^luwin\..*/ {
  notice(">>> nodes - hostname matched puppetmaster.* <<<")  
  include web_server
}

###################################################
# If not matched above will run default base config
###################################################
# default base build
node default inherits basenode {
  notice (">>> default NODE <<<")
}
###################################################
