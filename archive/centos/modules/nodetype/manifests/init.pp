#######################################################
# nodetype

import "*.pp"

class nodetype {
  notice(">>> nodetype class <<<")
  notify{"Server nodetype is ${::nodetype}": }
}
