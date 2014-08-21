##############################################################################
# Base Yum REPO configuration

class yumrepo {
  notice(">>> yumrepo class <<<")
  notify{"class yumrepo": }
  tag("base")

  ##FILES
  file { "yum.repos.d":
    path    => "/etc/yum.repos.d/",
    ensure  => directory,
    source  => "puppet:///modules/base/yum.repos.d",
    recurse => true,
    owner   => root,
    group   => root,
    mode    => 644,
  }

}
##############################################################################
