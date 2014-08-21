#######################################################
# Jenkins - Continuous Integration

class jenkins {
  notify{"Loading jenkins class": }

  include jenkins::user

  if ($::lsbdistcodename == "precise") {
    $jenkinspackages = [
      "jenkins",
      #"jenkins-common",  # first breaks jenkins pkg on precise
      "jenkins-cli",
      "libjenkins-remoting-java",
    ]
  } else {
    $jenkinspackages = [
      "jenkins",
    ]
  }

  package { $jenkinspackages: ensure => installed }
  if ($::lsbdistcodename == "precise") {
  }

}
 
class jenkins::user {

    # DO NOT do recursive chmod
    #mode    => 755,
    file { "/var/lib/jenkins":
    #  ensure  => directory,  # Could be a link
      owner   => "jenkins",
      group   => "nogroup",
      require => [ Package["jenkins"] ],
    }

    file { "/var/lib/jenkins/.ssh":
      ensure  => directory,
      owner   => "jenkins",
      group   => "nogroup",
      mode    => 700,
      require => File["/var/lib/jenkins/"],
    }

    # make sure that the ssh key authorized files exists with correct perms
    file { "/var/lib/jenkins/.ssh/authorized_keys2":
      ensure  => absent,
    }
    file { "/var/lib/jenkins/.ssh/authorized_keys":
      ensure  => present,
      owner   => "jenkins",
      group   => "nogroup",
      mode    => 600,
      backup => ".$::timestamp",
      source  => "puppet:///modules/jenkins/authorized_keys",
      require => File["/var/lib/jenkins/.ssh"],
    }

}
