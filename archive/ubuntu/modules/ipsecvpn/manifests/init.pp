################################################################
# exVPN wrapper - loads server or client depending


# includes other class files in this directory
import "*.pp"

class exvpn {
  notice(">>> exvpn wrapper class <<<")
  notify{"Loading exvpn wrapper class": }
  tag("exvpn")

  # Do not configure expvpn client rabbithole exvpn servers
  if ($::nodetype != "rabbithole") {

    #selectively install for now by (pop)
    #  OR selectively install for now by nodetype or hostname below
    if ($::pop == "sjc2") or 
       ($::pop == "sjc") or
       ($::pop == "dc") or
       ($::nodetype == "bp-fb-battle") or  # gets remote battles servers
       ($::nodetype == "stargate")
    {
        include exvpn::config
        include exvpn::service
    } # end of if/elsif/elsif

  } # end not rabbithole

} #end of wrapper class
