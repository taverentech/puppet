#######################################################
# PostFix

class postfix {
  notice(">>> postfix class <<<")
  notify{"Loading postfix class": }

  #Do not run on mail servers
  if ($::nodetype != "smtp") {

    ## Packages
    package { "postfix": ensure => installed }

    ## Files
    file { "postfix_main.cf":
      name       =>  "/etc/postfix/main.cf",
      content => $::nodetype ? {
        #TODO - verify this is GOOD config before executing
        #smtp        => template("postfix/main.cf_smtp.erb"),
        support-web => template("postfix/main.cf_support.erb"),
        default     => template("postfix/main.cf.erb"),
      },
      #content    => template("postfix/main.cf.erb"),
      owner      => root,
      group      => root,
      mode       => 444,
      backup => ".$::timestamp",
      notify     => Service["postfix"],
      require    => Package["postfix"],
    }
    #/etc/postfix/mailname is DEBIAN only - should be FQDN
    file { "postfix_mailname":
      name       =>  "/etc/mailname",
      content    => "$::fqdn\n",
      owner      => root,
      group      => root,
      mode       => 444,
      backup => ".$::timestamp",
      notify     => Service["postfix"],
    }

    ## Services
    service { "postfix":
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => [ 
        Package["postfix"], 
        File["postfix_mailname"], 
        File["postfix_main.cf"], 
      ],
    }

  }

}
