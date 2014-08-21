#######################################################
# Sun Java

class java {
  notify{"Loading java dummy class": }
  notify{"You need to include java::sunjdk6 or java::openjre6": }
}

# We do not need this actually - we install from example repo
class java::sunapt {
  notify{"Loading java::apt class": }

  file { "apt_sun-java.list":
    path    => "/etc/apt/sources.list.d/sun-java.list",
    content => template("java/apt_sun-java.list.erb"),
    owner => 'root',
    group => 'root',
    mode  => '0644',
    notify => Exec["apt-update"],
  }
}

class java::sunjre6 {
  notify{"Loading java::sunjre6 class": }

  ## Packages
  $jrepackages = [
    "sun-java6-jre",
  ]
  package { $jrepackages: ensure => installed }
}

class java::sunjdk6 {
  notify{"Loading java::sunjdk6 class": }

    ## Packages
    $jdkpackages = [
      "sun-j2sdk1.6",
    ]
    package { $jdkpackages: ensure => installed }
}

class java::openjre6 {
  notify{"Loading java::openjre6 class": }

    ## Packages
    $jdkpackages = [
      "openjdk-6-jre",
    ]
    package { $jdkpackages: ensure => installed }
}

class java::openjdk6 {
  notify{"Loading java::openjdk6 class": }

    ## Packages
    $jdkpackages = [
      "openjdk-6-jdk",
    ]
    package { $jdkpackages: ensure => installed }
}
