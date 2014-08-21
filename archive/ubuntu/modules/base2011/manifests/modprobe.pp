################################################################
# Base environment configurations
#   Kernel module loader/unloader

#USE this with
#	modprobe::kern_module { "dummy": ensure => present }

#TODO - test further
class modprobe {
  notify{"class modprobe": }

  define kern_module ($ensure) {
    $modulesfile = $osfamily ? {
      debian => "/etc/modules",
      redhat => "/etc/rc.modules",
    }
    case $osfamily {
      debian: { file { "/etc/rc.modules": ensure => file, mode => 755 } }
      redhat: { file { "/etc/rc.modules": ensure => file, mode => 755 } }
    }
    case $ensure {
      present: {
        exec { "load_module_${name}":
          command => $osfamily ? {
            debian => "modprobe ${name}",
            redhat => "/bin/echo '/sbin/modprobe ${name}' >> '${modulesfile}' ",
          },
          unless => $osfamily ? {
            debian => "modprobe -l ${name}|wc -l",
            redhat => "/bin/grep -q '^/sbin/modprobe ${name}\$' '${modulesfile}'",
          }
        }
        exec { "/sbin/modprobe ${name}": unless => "/bin/grep -q '^${name} ' '/proc/modules'" }
      }
      absent: {
        exec { "/sbin/modprobe -r ${name}": onlyif => "/bin/grep -q '^${name} ' '/proc/modules'" }
        exec { "remove_module_${name}":
          command => $osfamily ? {
            debian => "/usr/bin/perl -ni -e 'print unless /^\\Q${name}\\E\$/' '${modulesfile}'",
            redhat => "/usr/bin/perl -ni -e 'print unless /^\\Q/sbin/modprobe ${name}\\E\$/' '${modulesfile}'",
          },
          onlyif => $osfamily ? {
            debian => "/bin/grep -qFx '${name}' '${modulesfile}'",
            redhat => "/bin/grep -q '^/sbin/modprobe ${name}\$' '${modulesfile}'",
          }
        }
      }
      default: { err ( "unknown ensure value ${ensure}" ) }
    }
  } # end of define

}
