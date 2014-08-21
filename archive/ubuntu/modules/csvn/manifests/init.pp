#######################################################
# Collab SVN Server

class csvn {
  notice(">>> Collab SVN Server - csvn class <<<")
  notify{"Loading csvn class": }

  realize ( Users::Functions::Localuser["csvn"], )

  ## Packages
  package { "sun-j2sdk1.6": 
    ensure => installed,
  }
  package { "subversion-edge-3.1.0": 
    ensure => installed,
    require    => [ Package["sun-j2sdk1.6"],User["csvn"] ],
  }

  ## Files

  ## Services
  service { "csvn":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [ Package["subversion-edge-3.1.0"],User["csvn"] ],
  }
    #require    => [ Exec["csvn-init"],User["csvn"] ],
}
